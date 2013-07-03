/*
 * Copyright (c) 2013 Andrew G. Crowell (Overkill / Bananattack)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of squish nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL SQUISH CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>
#include "squish.h"

int main(int argc, char **argv) {
    uint8_t* src;
    uint8_t* compressed;
    uint8_t* decompressed;
    size_t src_size;
    size_t compressed_size;
    size_t decompressed_size;

    FILE* f;

    f = fopen("squish.c", "rb");
    if(!f) {
        fputs("failed to open", stderr);
        return 1;
    }

    fseek(f, 0, SEEK_END);
    src_size = ftell(f);
    fseek(f, 0, SEEK_SET);

    src = malloc(src_size);
    compressed = malloc(src_size);
    decompressed = malloc(src_size);
    if(!src || !compressed || !decompressed) {
        fputs("failed to allocate buffer memory", stderr);
        return 1;
    }
    fread(src, 1, src_size, f);
    fclose(f);

    compressed_size = squish_pack(src, src_size, compressed, src_size);
    f = fopen("squish.compressed.c", "wb");
    if(!f) {
        fputs("failed to open compressed file for writing", stderr);
        return 1;
    }
    fwrite(compressed, 1, compressed_size, f);
    fclose(f);

    decompressed_size = squish_unpack(compressed, compressed_size, decompressed, src_size);
    f = fopen("squish.decompressed.c", "wb");
    if(!f) {
        fputs("failed to open decompressed file for writing", stderr);
        return 1;
    }
    fwrite(decompressed, 1, decompressed_size, f);
    fclose(f);

    printf("src: %u byte(s)\n", (uint32_t) src_size);
    printf("compressed: %u byte(s)\n", (uint32_t) compressed_size);
    printf("ratio: %u%% of original size\n\n", (uint32_t) (compressed_size * 100 / src_size));
    printf("decompressed: %u byte(s)\n", (uint32_t) decompressed_size);

    return 0;
}
