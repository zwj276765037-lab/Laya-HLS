// M007 strict S128 frontend. Native model/tokenizer/recipe sources are read-only.
// No ModelExecutor, forward pass, XRT or device-success path exists here.
#include "questions.h"
#include "recipe.h"
#include "sequence.h"
#include "ggmlc/pipeline/tokenizer.h"
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

namespace laya { JsonValue answer_to_json(const Answer&); }

// Generated from the pinned original engine.cpp member body, without arithmetic
// edits. Only its local function signature and recipe/has_act parameters differ.
#include "native_decode_generated.inc"

namespace {
using namespace laya;
using ggmlc::pipeline::BPETokenizer;
struct Failure : std::runtime_error {
    std::string code;
    Failure(std::string kind, std::string text) : std::runtime_error(text), code(std::move(kind)) {}
};

const JsonValue& member(const JsonValue& value, const char* key) {
    const auto* result = value.get(key);
    if (!result) throw Failure("JSON_ERROR", std::string("missing field: ") + key);
    return *result;
}

int integer(const JsonValue& value, const std::string& name) {
    if (!value.is_number() || !std::isfinite(value.n) || std::floor(value.n) != value.n ||
        value.n < std::numeric_limits<int>::min() || value.n > std::numeric_limits<int>::max())
        throw Failure("JSON_ERROR", "integer field: " + name);
    return static_cast<int>(value.n);
}

std::vector<std::string> strings(const JsonValue& value) {
    if (!value.is_array()) throw Failure("IDENTITY_ERROR", "expected tokenizer string array");
    std::vector<std::string> out;
    for (const auto& item : value.arr) {
        if (!item.is_string()) throw Failure("IDENTITY_ERROR", "tokenizer string element");
        out.push_back(item.s);
    }
    return out;
}

template<class T> JsonValue numbers(const std::vector<T>& items) {
    JsonValue result = JsonValue::array();
    for (auto item : items) result.arr.push_back(JsonValue::number(item));
    return result;
}

uint32_t float_bits(float value) { uint32_t bits; std::memcpy(&bits, &value, 4); return bits; }
float bits_float(uint32_t bits) { float value; std::memcpy(&value, &bits, 4); return value; }

JsonValue raw_answer(const Answer& answer) {
    JsonValue result = JsonValue::object();
    result.set("question_id", JsonValue::string(answer.id));
    result.set("qtype", JsonValue::number(static_cast<int>(answer.type)));
    result.set("choice", JsonValue::string(answer.choice));
    result.set("score_u32", JsonValue::number(float_bits(answer.score)));
    result.set("noul_u32", JsonValue::number(float_bits(answer.noul)));
    result.set("confidence_u32", JsonValue::number(float_bits(answer.confidence)));
    result.set("act_probability_u32", JsonValue::number(float_bits(answer.act_probability)));
    JsonValue probabilities = JsonValue::array(), legend = JsonValue::array();
    for (const auto& pair : answer.probabilities) {
        JsonValue p = JsonValue::object();
        p.set("label", JsonValue::string(pair.first));
        p.set("u32", JsonValue::number(float_bits(pair.second)));
        probabilities.arr.push_back(p);
    }
    for (const auto& text : answer.legend) legend.arr.push_back(JsonValue::string(text));
    result.set("probabilities", probabilities);
    result.set("legend", legend);
    return result;
}

class Frontend {
public:
    BPETokenizer tokenizer;
    DecisionRecipe recipe;

    explicit Frontend(const JsonValue& bundle) {
        ggmlc::SerializedModelGraph graph;
        for (const auto& pair : member(bundle, "metadata_int").obj)
            graph.metadata_int[pair.first] = integer(pair.second, pair.first);
        for (const auto& pair : member(bundle, "metadata_str").obj) {
            if (!pair.second.is_string()) throw Failure("IDENTITY_ERROR", "metadata string");
            graph.metadata_str[pair.first] = pair.second.s;
        }
        if (graph.metadata_str.count("ggmlc.decision"))
            throw Failure("IDENTITY_ERROR", "unexpected baked recipe");
        recipe.load_from_graph(graph, member(bundle, "model_path").s);
        if (!recipe.loaded || recipe.baked || recipe.kind != "laya" || recipe.max_opts != 16 ||
            recipe.temperature.size() != 3 || !recipe.has_qtype_input || !recipe.has_act)
            throw Failure("IDENTITY_ERROR", "unsupported explicit Laya compatibility recipe");
        for (float value : recipe.temperature)
            if (!std::isfinite(value) || value <= 0) throw Failure("IDENTITY_ERROR", "invalid model temperature");
        for (const auto& pair : recipe.temperature_by_options)
            if (!std::isfinite(pair.second) || pair.second <= 0) throw Failure("IDENTITY_ERROR", "invalid bucket temperature");
        const auto& meta = member(bundle, "tokenizer");
        const auto tokens = strings(member(meta, "tokenizer.ggml.tokens"));
        const auto merges = strings(member(meta, "tokenizer.ggml.merges"));
        if (tokens.size() != 50368 || merges.size() != 50009)
            throw Failure("IDENTITY_ERROR", "tokenizer vocabulary/merge count");
        tokenizer.init(tokens, merges,
            integer(member(meta, "tokenizer.ggml.bos_token_id"), "bos"),
            integer(member(meta, "tokenizer.ggml.eos_token_id"), "eos"),
            integer(member(meta, "tokenizer.ggml.padding_token_id"), "pad"),
            integer(member(meta, "tokenizer.ggml.unknown_token_id"), "unk"),
            member(meta, "tokenizer.ggml.pre").s,
            meta.get("tokenizer.chat_template") ? meta.get("tokenizer.chat_template")->s : "");
    }

    static std::string replace_mask(std::string text, const std::string& mask) {
        if (mask.empty()) return text;
        size_t position = 0;
        while ((position = text.find(mask, position)) != std::string::npos) {
            text.replace(position, mask.size(), " ");
            ++position;
        }
        return text;
    }

    EncodedQuestion strict_sequence(const std::string& state, const Question& question) const {
        const auto cfg = SequenceConfig::from_recipe(recipe);
        const auto options = render_options(question, recipe);
        if (options.empty() || options.size() > 16 ||
            (question.type == QType::Noul && options.size() != 2))
            throw Failure("CANDIDATE_ERROR", "candidate count outside original business rules");
        auto mask_text = tokenizer.decode({cfg.mask_id}, false);
        if (mask_text.empty()) mask_text = "[MASK]"; // original mask_token_str behavior
        EncodedQuestion encoded;
        encoded.qtype = question.type;
        encoded.ids.push_back(cfg.cls_id);
        auto append = [&](const std::vector<int32_t>& part) {
            encoded.ids.insert(encoded.ids.end(), part.begin(), part.end());
        };
        append(tokenizer.encode(std::string(qtype_name(question.type)) + " question: " +
            replace_mask(question.instructions, mask_text), 0, false, false));
        encoded.ids.push_back(cfg.sep_id);
        for (const auto& option : options) {
            encoded.markers.push_back(static_cast<int32_t>(encoded.ids.size()));
            encoded.ids.push_back(cfg.mask_id);
            append(tokenizer.encode(" " + replace_mask(option, mask_text), 0, false, false));
        }
        encoded.ids.push_back(cfg.sep_id);
        append(tokenizer.encode(replace_mask(state, mask_text), 0, false, false));
        encoded.ids.push_back(cfg.sep_id);
        if (encoded.ids.size() > 128)
            throw Failure("LENGTH_ERROR", "complete untruncated sequence has " +
                std::to_string(encoded.ids.size()) + " tokens; S128 supports at most 128");
        for (auto token : encoded.ids)
            if (token < 0 || token >= 50368) throw Failure("TOKEN_ERROR", "token outside model vocabulary");
        return encoded;
    }

    JsonValue encode(const JsonValue& command) const {
        const auto& definitions = member(command, "questions");
        std::string parameter;
        const auto message = validate_questions_json(definitions, &parameter);
        if (!message.empty()) throw Failure("QUESTION_ERROR", parameter + ": " + message);
        const auto state = serialize_state(member(command, "state"));
        const auto questions = questions_from_json(definitions);
        JsonValue output = JsonValue::array();
        for (const auto& question : questions) {
            const auto encoded = strict_sequence(state, question);
            std::vector<int32_t> ids, positions, types, decide;
            std::vector<float> attention, valid;
            // Safe to reuse original padding only after proving no truncation.
            pad_encoded_batch({encoded}, recipe, 1, 128, ids, attention, positions, valid, types, decide);
            JsonValue item = JsonValue::object();
            item.set("question_id", JsonValue::string(question.id));
            item.set("token_ids", numbers(ids));
            item.set("attention_mask", numbers(attention));
            item.set("markers", numbers(positions));
            item.set("marker_mask", numbers(valid));
            item.set("qtype", JsonValue::number(static_cast<int>(question.type)));
            item.set("candidate_count", JsonValue::number(encoded.markers.size()));
            item.set("live_tokens", JsonValue::number(encoded.ids.size()));
            output.arr.push_back(item);
        }
        JsonValue result = JsonValue::object();
        result.set("questions", output);
        result.set("serialized_state", JsonValue::string(state));
        result.set("recipe_mode", JsonValue::string("explicit_native_laya_compat"));
        return result;
    }

    JsonValue decode(const JsonValue& command) const {
        JsonValue definitions = JsonValue::object();
        const auto id = member(command, "question_id").s;
        definitions.set(id, member(command, "question"));
        std::string parameter;
        const auto error = validate_questions_json(definitions, &parameter);
        if (!error.empty()) throw Failure("QUESTION_ERROR", parameter + ": " + error);
        const auto question = question_from_json(id, member(command, "question"));
        if (integer(member(command, "qtype"), "qtype") != static_cast<int>(question.type))
            throw Failure("IDENTITY_ERROR", "question qtype mismatch");
        const auto& bits = member(command, "logits_u32");
        const auto& mask = member(command, "marker_mask");
        if (!bits.is_array() || bits.arr.size() != 18 || !mask.is_array() || mask.arr.size() != 16)
            throw Failure("FRAME_ERROR", "18 logits and 16 mask slots required");
        std::vector<float> all, selected;
        for (const auto& item : bits.arr) {
            if (!item.is_number() || !std::isfinite(item.n) || std::floor(item.n) != item.n ||
                item.n < 0 || item.n > 4294967295.0) throw Failure("FRAME_ERROR", "logit bit domain");
            const float value = bits_float(static_cast<uint32_t>(item.n));
            if (!std::isfinite(value)) throw Failure("NUMERIC_ERROR", "nonfinite logit; no uniform fallback");
            all.push_back(value);
        }
        for (size_t i = 0; i < 16; ++i) {
            const int active = integer(mask.arr[i], "marker_mask");
            if (active != 0 && active != 1) throw Failure("CANDIDATE_ERROR", "nonbinary marker mask");
            if (active) selected.push_back(all[i]);
        }
        const auto expected = render_options(question, recipe).size();
        if (selected.empty() || selected.size() > 16 || selected.size() != expected ||
            (question.type == QType::Noul && selected.size() != 2))
            throw Failure("CANDIDATE_ERROR", "question/marker candidate count mismatch");
        float temperature = 1.0f;
        if (!recipe.temperature_baked) {
            temperature = recipe.temperature[static_cast<int>(question.type) % 3];
            auto found = recipe.temperature_by_options.find(temp_bucket(question.type, selected.size()));
            if (found != recipe.temperature_by_options.end()) temperature = found->second;
        }
        const float t = std::max(temperature, 1e-3f);
        const float maximum = *std::max_element(selected.begin(), selected.end());
        for (float value : selected) {
            const float shifted = value - maximum;
            const float scaled = shifted / t;
            if (!std::isfinite(shifted) || !std::isfinite(scaled))
                throw Failure("NUMERIC_ERROR", "candidate softmax intermediate overflow");
        }
        const float act_maximum = std::max(all[16], all[17]);
        if (!std::isfinite(all[16] - act_maximum) || !std::isfinite(all[17] - act_maximum))
            throw Failure("NUMERIC_ERROR", "ACT softmax intermediate overflow");
        const auto answer = decode_original_adapter(recipe, true, question,
            selected.data(), static_cast<int>(selected.size()), all.data() + 16);
        if (!std::isfinite(answer.confidence) || !std::isfinite(answer.act_probability) ||
            !std::isfinite(answer.score) || !std::isfinite(answer.noul))
            throw Failure("NUMERIC_ERROR", "nonfinite decoded answer");
        for (const auto& pair : answer.probabilities)
            if (!std::isfinite(pair.second)) throw Failure("NUMERIC_ERROR", "nonfinite decoded probability");
        JsonValue result = JsonValue::object();
        result.set("answer", answer_to_json(answer));
        result.set("raw", raw_answer(answer));
        result.set("temperature_u32", JsonValue::number(float_bits(temperature)));
        return result;
    }
};
} // namespace

#ifndef M007_FRONTEND_LIBRARY
int main(int argc, char** argv) {
    try {
        if (argc != 2) throw std::runtime_error("usage: native_frontend METADATA_BUNDLE_JSON");
        std::ifstream stream(argv[1], std::ios::binary);
        if (!stream) throw std::runtime_error("cannot read verified metadata bundle");
        const std::string source((std::istreambuf_iterator<char>(stream)), {});
        Frontend frontend(laya::JsonParser::parse_string(source));
        std::cout << "{\"status\":\"NATIVE_FRONTEND_READY\",\"device\":\"NOT_RUN\"}" << std::endl;
        std::string line;
        while (std::getline(std::cin, line)) {
            try {
                const auto command = laya::JsonParser::parse_string(line);
                const auto op = member(command, "op").s;
                auto result = (op == "encode") ? frontend.encode(command) :
                    (op == "decode") ? frontend.decode(command) :
                    throw Failure("JSON_ERROR", "unknown operation");
                result.set("status", laya::JsonValue::string("OK"));
                result.set("device", laya::JsonValue::string("NOT_RUN"));
                std::cout << laya::json_dumps(result) << std::endl;
            } catch (const Failure& error) {
                auto result = laya::JsonValue::object();
                result.set("status", laya::JsonValue::string("ERROR"));
                result.set("code", laya::JsonValue::string(error.code));
                result.set("message", laya::JsonValue::string(error.what()));
                std::cout << laya::json_dumps(result) << std::endl;
            } catch (const std::exception& error) {
                auto result = laya::JsonValue::object();
                result.set("status", laya::JsonValue::string("ERROR"));
                result.set("code", laya::JsonValue::string("JSON_ERROR"));
                result.set("message", laya::JsonValue::string(error.what()));
                std::cout << laya::json_dumps(result) << std::endl;
            }
        }
        return 0;
    } catch (const std::exception& error) {
        std::cerr << "NATIVE_FRONTEND_ERROR: " << error.what() << '\n';
        return 1;
    }
}
#endif
