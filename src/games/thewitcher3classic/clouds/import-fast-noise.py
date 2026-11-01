"""Reproduce fast_noise.hpp from EA's pinned noise.zip; see sampling.md."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import argparse
import hashlib
from pathlib import Path
import struct
import zipfile
import zlib

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("archive", type=Path)
args = parser.parse_args()
assert hashlib.sha256(args.archive.read_bytes()).hexdigest() == "35fe2ce496a837186931acc5afedcdf53ef22d1aaf6d01ad1dcd416c5ff68cea"
result = bytearray()
with zipfile.ZipFile(args.archive) as archive:
    for frame in range(32):
        png = archive.read(f"noise/real/temporal/exp/real_uniform_gauss1_0_exp0101_separate05_{frame}.png")
        assert png[:8] == b"\x89PNG\r\n\x1a\n"
        pos, packed = 8, bytearray()
        while pos < len(png):
            length = struct.unpack(">I", png[pos:pos + 4])[0]
            kind, data = png[pos + 4:pos + 8], png[pos + 8:pos + 8 + length]
            pos += length + 12
            if kind == b"IHDR":
                assert struct.unpack(">IIBBBBB", data) == (128, 128, 8, 6, 0, 0, 0)
            if kind == b"IDAT":
                packed += data
        raw, previous = zlib.decompress(packed), bytearray(512)
        assert len(raw) == 128 * 513
        for y in range(128):
            filter_type = raw[y * 513]
            row = bytearray(raw[y * 513 + 1:(y + 1) * 513])
            for x in range(512):
                left, above, corner = (row[x - 4] if x >= 4 else 0), previous[x], (previous[x - 4] if x >= 4 else 0)
                prediction = left + above - corner
                a, b, c = abs(prediction - left), abs(prediction - above), abs(prediction - corner)
                paeth = left if a <= b and a <= c else above if b <= c else corner
                row[x] = (row[x] + (0, left, above, (left + above) // 2, paeth)[filter_type]) & 255
            assert all(row[x] == row[x + 1] == row[x + 2] for x in range(0, 512, 4))
            result += row[0::4]
            previous = row
assert hashlib.sha256(result).hexdigest() == "76471f8e2659ca0ff1e85173835a818c23c9a05d9dc89410c37934782bfb87a5"
with Path(__file__).with_name("fast_noise.hpp").open("w", newline="\n") as output:
    output.write("// EA SEED FAST mask, BSD-3-Clause. See LICENSE.fastnoise and sampling.md.\n"
                 "// Generated: original R channel, frame-major, without resampling.\n"
                 "#pragma once\n#include <cstdint>\nnamespace witcher3classic::clouds {\n"
                 "inline constexpr uint8_t fast_noise[128*128*32] = {\n")
    for i in range(0, len(result), 32):
        output.write("  " + ",".join(str(value) for value in result[i:i + 32]) + ",\n")
    output.write("};\n}\n")
