// Copyright (c) 2013 Andrew G. Crowell (Bananattack)
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

private enum SQUISH_LENGTH_MASK = 0x3F;
private enum SQUISH_LENGTH_BITS = 6;
private enum SQUISH_COMMAND_RAW = 0x0;
private enum SQUISH_COMMAND_RLE8 = 0x1;
private enum SQUISH_COMMAND_RLE16 = 0x2;
private enum SQUISH_COMMAND_REF = 0x3;

private bool flush_raw(in ubyte[] raw, ref size_t raw_length, ref size_t output_position, ubyte[] dest)
{
    if(raw_length > 0)
    {
        if(output_position + 1 + raw_length > dest.length)
        {
            return false;
        }

        dest[output_position++] = cast(ubyte) (raw_length | (SQUISH_COMMAND_RAW << SQUISH_LENGTH_BITS));
        for(size_t i = 0; i < raw_length; i++)
        {  
            dest[output_position++] = raw[i];
        }
        raw_length = 0;
    }
    return true;
}

size_t pack(in ubyte[] src, ubyte[] dest)
{
    ubyte[SQUISH_LENGTH_MASK] raw;
    size_t raw_length = 0;

    size_t input_position = 0;
    size_t output_position = 0;
    while(input_position < src.length)
    {
        size_t rle8_length = 0;
        size_t j = 0;
        while(input_position + j < src.length
        && j < SQUISH_LENGTH_MASK
        && src[input_position + j] == src[input_position])
        {
            rle8_length++;
            j++;
        }

        size_t rle16_length = 0;
        j = 0;
        while(input_position + j + 1 < src.length
        && j < SQUISH_LENGTH_MASK
        && src[input_position + j] == src[input_position]
        && src[input_position + j + 1] == src[input_position + 1])
        {
            rle16_length++;
            j += 2;
        }

        size_t ref_index = 0;
        size_t ref_length = 0;
        for(size_t i = 0; i < input_position; ++i)
        {
            j = 0;
            while(i + j < input_position
            && input_position + j < src.length
            && j < SQUISH_LENGTH_MASK
            && src[i + j] == src[input_position + j])
            {
                j++;
            }
            if(j > ref_length)
            {
                ref_index = i;
                ref_length = j;
            }
        }

        if(ref_length > 2 && ref_length > rle16_length && ref_length > rle8_length)
        {
            if(!flush_raw(raw, raw_length, output_position, dest))
            {
                return 0;
            }
            if(output_position + 3 > dest.length)
            {
                return 0;
            }
            dest[output_position++] = cast(ubyte) (ref_length | (SQUISH_COMMAND_REF << SQUISH_LENGTH_BITS));
            dest[output_position++] = cast(ubyte) (ref_index >> 8);
            dest[output_position++] = ref_index & 0xFF;

            input_position += ref_length;
        }
        else if(rle16_length > 2)
        {
            if(!flush_raw(raw, raw_length, output_position, dest))
            {
                return 0;
            }
            if(output_position + 3 > dest.length)
            {
                return 0;
            }

            dest[output_position++] = cast(ubyte) (rle16_length | (SQUISH_COMMAND_RLE16 << SQUISH_LENGTH_BITS));
            dest[output_position++] = src[input_position];
            dest[output_position++] = src[input_position + 1];

            input_position += rle16_length * 2;
        }
        else if(rle8_length > 1)
        {
            if(!flush_raw(raw, raw_length, output_position, dest))
            {
                return 0;
            }
            if(output_position + 2 > dest.length)
            {
                return 0;
            }

            dest[output_position++] = cast(ubyte) (rle8_length | (SQUISH_COMMAND_RLE8 << SQUISH_LENGTH_BITS));
            dest[output_position++] = src[input_position];

            input_position += rle8_length;
        }
        else
        {
            raw[raw_length++] = src[input_position++];
            if(raw_length == SQUISH_LENGTH_MASK)
            {
                if(!flush_raw(raw, raw_length, output_position, dest))
                {
                    return 0;
                }
            }
        }
    }
    if(!flush_raw(raw, raw_length, output_position, dest))
    {
        return 0;
    }
    if(output_position + 1 > dest.length)
    {
        return 0;
    }
    dest[output_position++] = 0;

    return output_position;
}

size_t unpack(in ubyte[] src, ubyte[] dest)
{
    size_t input_position = 0;
    size_t output_position = 0;

    while(input_position < src.length)
    {
        size_t length = src[input_position] & SQUISH_LENGTH_MASK;
        ubyte command = src[input_position++] >> SQUISH_LENGTH_BITS;

        if(length == 0)
        {
            return output_position;
        }
        switch(command)
        {
            case SQUISH_COMMAND_RAW:
                if(output_position + length > dest.length)
                {
                    return 0;
                }
                for(size_t i = 0; i < length; i++)
                {
                    dest[output_position++] = src[input_position++];
                }
                break;
            case SQUISH_COMMAND_RLE8:
                if(output_position + length > dest.length)
                {
                    return 0;
                }
                for(size_t i = 0; i < length; i++)
                {
                    dest[output_position++] = src[input_position];
                }
                input_position++;
                break;
            case SQUISH_COMMAND_RLE16:
                if(output_position + length * 2 > dest.length)
                {
                    return 0;
                }
                for(size_t i = 0; i < length; i++)
                {
                    dest[output_position++] = src[input_position];
                    dest[output_position++] = src[input_position + 1];
                }
                input_position += 2;
                break;
            case SQUISH_COMMAND_REF:
                if(output_position + length > dest.length)
                {
                    return 0;
                }
                size_t offset = src[input_position] << 8 | src[input_position + 1];
                for(size_t i = 0; i < length; i++)
                {
                    dest[output_position++] = dest[offset + i];
                }
                input_position += 2;
                break;
            default: assert(0);
        }
    }
    return output_position;
}


