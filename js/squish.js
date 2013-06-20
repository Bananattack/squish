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

var squish = (function(lib) {
    var SQUISH_LENGTH_MASK = 0x3F;
    var SQUISH_LENGTH_BITS = 6;
    var SQUISH_COMMAND_RAW = 0x0;
    var SQUISH_COMMAND_RLE8 = 0x1;
    var SQUISH_COMMAND_RLE16 = 0x2;
    var SQUISH_COMMAND_REF = 0x3;

    function flush_raw(raw, dest) {
        if(raw.length > 0) {
            dest.push(raw.length | (SQUISH_COMMAND_RAW << SQUISH_LENGTH_BITS));
            for(var i = 0; i < raw.length; i++) {
                dest.push(raw[i]);
            }
            raw.length = 0;
        }
    }

    lib.pack = function(src) {
        var dest = [];
        var raw = [];

        var input_position = 0;
        while(input_position < src.length) {
            var rle8_length = 0;
            var j = 0;
            while(input_position + j < src.length
            && j < SQUISH_LENGTH_MASK
            && src[input_position + j] == src[input_position]) {
                rle8_length++;
                j++;
            }

            var rle16_length = 0;
            j = 0;
            while(input_position + j + 1 < src.length
            && j < SQUISH_LENGTH_MASK
            && src[input_position + j] == src[input_position]
            && src[input_position + j + 1] == src[input_position + 1]) {
                rle16_length++;
                j += 2;
            }

            var ref_index = 0;
            var ref_length = 0;
            for(var i = 0; i < input_position; ++i) {
                j = 0;
                while(i + j < input_position
                && input_position + j < src.length
                && j < SQUISH_LENGTH_MASK
                && src[i + j] == src[input_position + j]) {
                    j++;
                }
                if(j > ref_length) {
                    ref_index = i;
                    ref_length = j;
                }
            }

            if(ref_length > 2 && ref_length > rle16_length && ref_length > rle8_length) {
                flush_raw(raw, dest);
                dest.push((ref_length | (SQUISH_COMMAND_REF << SQUISH_LENGTH_BITS)) & 0xFF);
                dest.push((ref_index >> 8) & 0xFF);
                dest.push(ref_index & 0xFF);

                input_position += ref_length;
            } else if(rle16_length > 2) {
                flush_raw(raw, dest);
                dest.push((rle16_length | (SQUISH_COMMAND_RLE16 << SQUISH_LENGTH_BITS)) & 0xFF);
                dest.push(src[input_position] & 0xFF);
                dest.push(src[input_position + 1] & 0xFF);

                input_position += rle16_length * 2;
            } else if(rle8_length > 1) {
                flush_raw(raw, dest);
                dest.push((rle8_length | (SQUISH_COMMAND_RLE8 << SQUISH_LENGTH_BITS)) & 0xFF);
                dest.push(src[input_position] & 0xFF);

                input_position += rle8_length;
            } else {
                raw.push(src[input_position++] & 0xFF);
                if(raw.length == SQUISH_LENGTH_MASK) {
                    flush_raw(raw, dest);
                }
            }
        }
        flush_raw(raw, dest);
        dest.push(0);

        return dest;
    }

    lib.unpack = function(src) {
        var dest = [];
        var input_position = 0;

        while(input_position < src.length) {
            var length = src[input_position] & SQUISH_LENGTH_MASK;
            var command = (src[input_position++] & 0xFF) >> SQUISH_LENGTH_BITS;

            if(length == 0) {
                return dest;
            }
            switch(command) {
                case SQUISH_COMMAND_RAW:
                    for(var i = 0; i < length; i++) {
                        dest.push(src[input_position++] & 0xFF);
                    }
                    break;
                case SQUISH_COMMAND_RLE8:
                    for(var i = 0; i < length; i++) {
                        dest.push(src[input_position] & 0xFF);
                    }
                    input_position++;
                    break;
                case SQUISH_COMMAND_RLE16:
                    for(var i = 0; i < length; i++) {
                        dest.push(src[input_position] & 0xFF);
                        dest.push(src[input_position + 1] & 0xFF);
                    }
                    input_position += 2;
                    break;
                case SQUISH_COMMAND_REF:
                    var offset = (src[input_position] & 0xFF) << 8 | (src[input_position + 1] & 0xFF);
                    for(var i = 0; i < length; i++) {
                        dest.push(dest[offset + i] & 0xFF);
                    }
                    input_position += 2;
                    break;
                default: assert(0);
            }
        }
        return dest;
    }


    return lib;
})({});