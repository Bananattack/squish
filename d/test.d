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

static import std.stdio;
static import squish;

void main()
{
    ubyte[4096] src;
    ubyte[] compressed = new ubyte[4096];
    ubyte[] decompressed = new ubyte[4096];
    size_t compressed_size;
    size_t decompressed_size;
    size_t i;

    auto f = std.stdio.File("a.chr", "rb");
    f.rawRead(src);

    compressed_size = squish.pack(src, compressed);
    compressed.length = compressed_size;
    f = std.stdio.File("a.compressed.chr", "wb");
    f.rawWrite(compressed);

    decompressed_size = squish.unpack(compressed, decompressed);
    decompressed.length = decompressed_size;
    f = std.stdio.File("a.decompressed.chr", "wb");
    f.rawWrite(decompressed);

    std.stdio.writefln("src: %s byte(s)", src.length);
    std.stdio.writefln("compressed: %s byte(s)", compressed_size);
    std.stdio.writefln("ratio: %s%% of original size", compressed_size * 100 / src.length);
    std.stdio.writefln("decompressed: %s byte(s)", decompressed_size);
}