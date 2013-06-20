// Copyright (c) 2013 Andrew G. Crowell (Overkill / Bananattack)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Neither the name of squish nor the names of its contributors may be
//    used to endorse or promote products derived from this software without
//    specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL SQUISH CONTRIBUTORS BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include <stdio.h>
#include "squish.h"

int main(int argc, char **argv) {
    uint8_t src[4096];
    uint8_t compressed[sizeof(src)];
    uint8_t decompressed[sizeof(src)];
    size_t compressed_size;
    size_t decompressed_size;
    size_t i;

    FILE* f;
    
    f = fopen("a.chr", "rb");
    fread(src, 1, sizeof(src), f);
    fclose(f);

    compressed_size = squish_pack(src, sizeof(src), compressed, sizeof(compressed));
    f = fopen("a.compressed.chr", "wb");
    fwrite(compressed, 1, compressed_size, f);
    fclose(f);

    decompressed_size = squish_unpack(compressed, compressed_size, decompressed, sizeof(decompressed));
    f = fopen("a.decompressed.chr", "wb");
    fwrite(decompressed, 1, decompressed_size, f);
    fclose(f);

    printf("src: %u byte(s)\n", (uint32_t) sizeof(src));
    printf("compressed: %u byte(s)\n", (uint32_t) compressed_size);
    printf("ratio: %u%% of original size\n\n", (uint32_t) (compressed_size * 100 / sizeof(src)));
    printf("decompressed: %u byte(s)\n", (uint32_t) decompressed_size);

    return 0;
}