"""Generate C++ wire constants and an SV package from the single schema."""
from pathlib import Path
from .contract import CONSTANTS, OFFSETS, SCHEMA, SCHEMA_SHA256


def outputs() -> dict[str, str]:
    magic_le = int.from_bytes(bytes.fromhex(SCHEMA["magic_hex"]), "little")
    heading = "// Generated from schema.json; do not edit.\n"
    heading += "// Host/SV wire contract only; XRT register mapping NOT_BOUND.\n"
    h = [heading, "#pragma once\n#include <array>\n#include <cstdint>\n",
         "namespace laya::m007 {\n",
         f'inline constexpr char SCHEMA_SHA256[] = "{SCHEMA_SHA256}";\n',
         f'inline constexpr unsigned SCHEMA_VERSION = {SCHEMA["version"]};\n',
         f'inline constexpr std::uint64_t MAGIC_LE = 0x{magic_le:016x}ULL;\n',
         f'inline constexpr unsigned METADATA_BYTES = {SCHEMA["metadata_bytes"]};\n']
    s = [heading, "package laya_m007_host_tail_pkg;\n",
         f"  localparam logic [255:0] SCHEMA_SHA256 = 256'h{SCHEMA_SHA256};\n",
         f'  localparam integer SCHEMA_VERSION = {SCHEMA["version"]};\n',
         f"  localparam logic [63:0] MAGIC_LE = 64'h{magic_le:016x};\n",
         f'  localparam integer METADATA_BYTES = {SCHEMA["metadata_bytes"]};\n']
    for name, value in CONSTANTS.items():
        h.append(f"inline constexpr unsigned {name} = {value};\n")
        s.append(f"  localparam integer {name} = {value};\n")
    for name, offset in OFFSETS.items():
        h.append(f"inline constexpr unsigned OFF_{name.upper()} = {offset};\n")
        s.append(f"  localparam integer OFF_{name.upper()} = {offset};\n")
    for name, kind, count in SCHEMA["fields"]:
        size = (1 if kind == "bytes" else {"u8": 1, "u16": 2, "u32": 4,
                                           "i32": 4, "u64": 8}[kind]) * count
        s.append(f"  localparam integer BYTES_{name.upper()} = {size};\n")
    h.extend(["using Metadata = std::array<std::uint8_t, METADATA_BYTES>;\n",
              "static_assert(H0_BYTES == TOKENS * HIDDEN * 4);\n",
              "static_assert(TAIL_BYTES == TAIL_ROWS * HIDDEN * 4);\n",
              "} // namespace laya::m007\n"])
    s.append("endpackage\n")
    return {"wire_generated.h": "".join(h), "laya_m007_host_tail_pkg.sv": "".join(s)}


def main() -> None:
    for name, data in outputs().items():
        Path(__file__).with_name(name).write_text(data)


if __name__ == "__main__":
    main()
