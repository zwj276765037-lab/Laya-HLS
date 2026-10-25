#!/usr/bin/env bash
set -euo pipefail
at=$1;cd "$at/work"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -Wno-unknown-pragmas -I"$at/frozen_source" "$at/frozen_source/attention_exp_bits.cpp" "$at/frozen_source/attention_exp_cpu.cpp" -lm -o exp_cpu
./exp_cpu "$at/fixture/shift.bin" "$at/fixture/exp.bin" "$at/fixture/exp_directed_x.bin" "$at/fixture/exp_directed_gold.bin"
