; Copyright (c) 2013 Andrew G. Crowell (Overkill / Bananattack)
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. Neither the name of squish nor the names of its contributors may be
;    used to endorse or promote products derived from this software without
;    specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL SQUISH CONTRIBUTORS BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

SQUISH_LENGTH_MASK      EQU $3F
SQUISH_LENGTH_BITS      EQU 6
SQUISH_COMMAND_RAW      EQU $0
SQUISH_COMMAND_RLE8     EQU $1
SQUISH_COMMAND_RLE16    EQU $2
SQUISH_COMMAND_REF      EQU $3

; squish_unpack previously packed source data at [hl] into the given destination buffer at [de].
; Arguments:
;   hl = source
;   de = dest
squish_unpack:
    ; Read header.
    ld a, [hl]

    ; extract command bits in c.
    ld c, a
    REPT SQUISH_LENGTH_BITS
        srl c
    ENDR

    ; length = 0 indicates EOF.
    and a, SQUISH_LENGTH_MASK
    or a, a
    ret z

    ; b = length
    ; a = command
    ld b, a
    ld a, c
    ; Is this a raw chunk of binary data?
.check_raw:
    cp a, SQUISH_COMMAND_RAW
    ; If not, skip.
    jr nz, .check_rle8
.raw_loop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .raw_loop

    jr squish_unpack

    ; Is this an 8-bit RLE value?
.check_rle8:
    cp a, SQUISH_COMMAND_RLE8
    ; If not, skip.
    jr nz, .check_rle8
.rle8_loop:
    ld a, [hl]
    ld [de], a
    inc de
    dec b
    jr nz, .rle8_loop

    inc hl
    jr squish_unpack

    ; Is this a 16-bit RLE value?
.check_rle16:
    cp a, SQUISH_COMMAND_RLE16
    ; If not, skip.
    jr nz, .handle_ref
.rle16_loop:
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl-]
    ld [de], a
    inc de
    dec b
    jr nz, .rle16_loop

    inc hl
    inc hl
    jr squish_unpack

    ; This is an LZ77-style backref.
.handle_ref:
    push hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
.ref_loop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .ref_loop

    pop hl
    inc hl
    inc hl
    jr squish_unpack

