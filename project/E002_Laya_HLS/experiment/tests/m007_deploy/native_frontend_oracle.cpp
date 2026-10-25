// Test-only independent native loader/BPE/legacy sequence and original member
// decode oracle. No M007 production helper is imported and no forward is run.
#include "questions.h"
#include "recipe.h"
#include "sequence.h"
#include "gguf.h"
#include <cmath>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace laya {
JsonValue answer_to_json(const Answer&);
class OriginalDecodeOracle {
public:
    DecisionRecipe recipe_;
    bool has_act_ = true;
    Answer decode_answer(const Question&, const float*, int, const float*) const;
};
}
// Unmodified original member body and arguments, with only class qualification
// rebound to the test-only class above. This is explicit source adaptation.
#include "oracle_decode_generated.inc"

namespace {
using namespace laya;
const JsonValue& get(const JsonValue& object, const std::string& key) {
    auto* p = object.get(key); if (!p) throw std::runtime_error("missing oracle input: " + key); return *p;
}
uint32_t as_bits(float value) { uint32_t out; std::memcpy(&out, &value, 4); return out; }
float as_float(uint32_t value) { float out; std::memcpy(&out, &value, 4); return out; }
template<class T> JsonValue array(const std::vector<T>& values) {
    auto out = JsonValue::array(); for (auto value : values) out.arr.push_back(JsonValue::number(value)); return out;
}
JsonValue raw(const Answer& answer) {
    auto out = JsonValue::object();
    out.set("question_id", JsonValue::string(answer.id));
    out.set("qtype", JsonValue::number(static_cast<int>(answer.type)));
    out.set("choice", JsonValue::string(answer.choice));
    out.set("score_u32", JsonValue::number(as_bits(answer.score)));
    out.set("noul_u32", JsonValue::number(as_bits(answer.noul)));
    out.set("confidence_u32", JsonValue::number(as_bits(answer.confidence)));
    out.set("act_probability_u32", JsonValue::number(as_bits(answer.act_probability)));
    auto p = JsonValue::array(), legend = JsonValue::array();
    for (const auto& entry : answer.probabilities) {
        auto item = JsonValue::object(); item.set("label", JsonValue::string(entry.first));
        item.set("u32", JsonValue::number(as_bits(entry.second))); p.arr.push_back(item);
    }
    for (const auto& text : answer.legend) legend.arr.push_back(JsonValue::string(text));
    out.set("probabilities", p); out.set("legend", legend); return out;
}
}

int main(int argc, char** argv) {
    using namespace laya;
    try {
        if (argc != 2) throw std::runtime_error("native oracle GGUF");
        gguf_init_params params{true, nullptr};
        auto* context = gguf_init_from_file(argv[1], params);
        if (!context) throw std::runtime_error("native GGUF metadata load");
        ggmlc::SerializedModelGraph graph;
        for (int64_t i = 0; i < gguf_get_n_kv(context); ++i) {
            const std::string key = gguf_get_key(context, i);
            if (key.rfind("laya.", 0) != 0 && key.rfind("ggmlc.decision", 0) != 0) continue;
            switch (gguf_get_kv_type(context, i)) {
                case GGUF_TYPE_INT32: graph.metadata_int[key] = gguf_get_val_i32(context, i); break;
                case GGUF_TYPE_UINT32: graph.metadata_int[key] = gguf_get_val_u32(context, i); break;
                case GGUF_TYPE_INT64: graph.metadata_int[key] = gguf_get_val_i64(context, i); break;
                case GGUF_TYPE_UINT64: graph.metadata_int[key] = gguf_get_val_u64(context, i); break;
                case GGUF_TYPE_STRING: graph.metadata_str[key] = gguf_get_val_str(context, i); break;
                default: throw std::runtime_error("unexpected decisive native metadata type");
            }
        }
        ggmlc::pipeline::BPETokenizer tokenizer;
        if (!tokenizer.init_from_gguf_ctx(context)) throw std::runtime_error("native tokenizer init");
        gguf_free(context);
        DecisionRecipe recipe; recipe.load_from_graph(graph, argv[1]);
        OriginalDecodeOracle oracle; oracle.recipe_ = recipe;
        std::cout << "{\"status\":\"ORACLE_READY\"}" << std::endl;
        std::string line;
        while (std::getline(std::cin, line)) {
            const auto command = JsonParser::parse_string(line);
            const auto op = get(command, "op").s;
            auto out = JsonValue::object();
            if (op == "tokenize") {
                out.set("tokens", array(tokenizer.encode(get(command, "text").s, 0, false, false)));
            } else if (op == "legacy-encode") {
                const auto definitions = get(command, "questions");
                std::string param;
                if (!validate_questions_json(definitions, &param).empty()) throw std::runtime_error("oracle question domain");
                const auto state = serialize_state(get(command, "state"));
                auto items = JsonValue::array();
                for (const auto& question : questions_from_json(definitions)) {
                    const auto encoded = build_sequence(tokenizer, recipe, state, question);
                    std::vector<int32_t> ids, markers, qtype, decide;
                    std::vector<float> attention, marker_mask;
                    pad_encoded_batch({encoded}, recipe, 1, 128, ids, attention, markers, marker_mask, qtype, decide);
                    auto item = JsonValue::object();
                    item.set("question_id", JsonValue::string(question.id));
                    item.set("token_ids", array(ids)); item.set("attention_mask", array(attention));
                    item.set("markers", array(markers)); item.set("marker_mask", array(marker_mask));
                    item.set("qtype", JsonValue::number(static_cast<int>(question.type)));
                    item.set("candidate_count", JsonValue::number(encoded.markers.size()));
                    item.set("live_tokens", JsonValue::number(encoded.ids.size()));
                    item.set("raw_ids", array(encoded.ids));
                    item.set("raw_markers", array(encoded.markers));
                    auto options = JsonValue::array();
                    for (const auto& text : render_options(question, recipe)) options.arr.push_back(JsonValue::string(text));
                    item.set("rendered_options", options); items.arr.push_back(item);
                }
                out.set("questions", items); out.set("serialized_state", JsonValue::string(state));
            } else if (op == "decode") {
                const auto question = question_from_json(get(command, "question_id").s, get(command, "question"));
                std::vector<float> logits;
                for (const auto& value : get(command, "candidate_u32").arr)
                    logits.push_back(as_float(static_cast<uint32_t>(value.n)));
                float act[2];
                act[0] = as_float(static_cast<uint32_t>(get(command, "act_u32").arr[0].n));
                act[1] = as_float(static_cast<uint32_t>(get(command, "act_u32").arr[1].n));
                const auto answer = oracle.decode_answer(question, logits.data(), logits.size(), act);
                out.set("raw", raw(answer)); out.set("answer", answer_to_json(answer));
            } else throw std::runtime_error("unknown oracle op");
            out.set("status", JsonValue::string("OK"));
            std::cout << json_dumps(out) << std::endl;
        }
        return 0;
    } catch (const std::exception& error) {
        std::cerr << "NATIVE_ORACLE_ERROR: " << error.what() << '\n'; return 1;
    }
}
