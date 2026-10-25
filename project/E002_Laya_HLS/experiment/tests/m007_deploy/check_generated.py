#!/usr/bin/env python3
"""Generate, check deterministic schema projections and compile Host constants."""
import argparse
import hashlib
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "host"))
from m007_deploy.generate import main as generate, outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    generate()
    for name, value in outputs().items():
        path = ROOT / "host/m007_deploy" / name
        assert path.read_text() == value, "deterministic schema projection " + name
        print(name + " SHA256=" + hashlib.sha256(path.read_bytes()).hexdigest())
    source = args.output / "generated_header_test.cpp"
    source.write_text('''#include "wire_generated.h"
#include <iostream>
using namespace laya::m007;
static_assert(METADATA_BYTES == 512);
static_assert(SCHEMA_VERSION == 1 && MAGIC_LE == 0x0000374d4159414cULL);
static_assert(OFF_REQUEST_ID == 16 && OFF_GENERATION == 24);
static_assert(OFF_MODEL == 80 && OFF_GRAPH == 112);
static_assert(OFF_MARKERS == 368 && OFF_MARKER_MASK == 432);
static_assert(TAIL_BYTES == 69632 && H0_BYTES == 524288);
int main() { Metadata frame{}; if (frame.size() != 512) return 1;
std::cout << "M007_GENERATED_HEADER_PASS metadata=512 tail=69632\\n"; }
''')
    print(subprocess.check_output(["c++", "--version"], text=True))
    binary = args.output / "generated_header_test"
    command = ["c++", "-std=c++17", "-Wall", "-Wextra", "-Werror", "-pedantic",
               "-I" + str(ROOT / "host/m007_deploy"), str(source), "-o", str(binary)]
    print("compile_command=" + repr(command), flush=True)
    subprocess.run(command, check=True)
    subprocess.run([str(binary)], check=True)
    print("M007_SCHEMA_PROJECTIONS_PASS cpp_compile=1 sv_package_generated=1 sv_simulation=NOT_RUN", flush=True)


if __name__ == "__main__":
    main()
