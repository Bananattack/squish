squish
======
**by Andrew G. Crowell (Overkill / Bananattack)**

A simple lossless data compression library with very low memory footprint.

* Compress files of up to 64K. (Designed with embedded systems with 16-bit address space in mind.)
* Libraries for C, D, JavaScript, 6502 and GBZ80.
* Mixes simplistic compression algorithms that require very little intermediate state during decompression.

Specification
-------------

* The **squish** compression format is a stream containing 0 or more sequences of the following data:  
  ```<header> <payload>```
* Each *header* is an 8-bit byte that contains a 6-bit *length* component and a 2-bit *command* component:  
  ```<header> = ((<command> & 3) << 6) | (<length> & 0x3F)```    
* The *payload* format is determined by the *command* in the header:
  * `raw = 0` - Sequence of uncompressed bytes of indicated *length*.
  * `rle8 = 1` - Single byte, to be unpacked *length* times.
  * `rle16 = 2` - Two-byte pattern, to be unpacked *length* times.
  * `ref = 3` - Reference to data earlier in the unpacked stream, a two-byte value specifying an offset in bytes from the beginning of the stream. The amount of bytes being referenced is of the indicated *length*.
* A header byte that has a *length* of zero is considered an end-of-file marker.

License
-------


    Copyright (c) 2013 Andrew G. Crowell (Overkill / Bananattack)
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
    3. Neither the name of squish nor the names of its contributors may be
       used to endorse or promote products derived from this software without
       specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL SQUISH CONTRIBUTORS BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

