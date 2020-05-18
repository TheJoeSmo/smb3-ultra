;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Could put into a macro .macro _tile and put .endm at the end
; then every instance of a horizontal run, you can simply insert the same code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_tile = $00 ; The tile that you want to appear

simple_horz_block_run:
    LDA block_size
    AND #$0f
    TAX      ; X = lower 4 bits of block_size
    LDY tile_address_offset

-
    LDA #_tile
    STA (tile_address), y       ; set tile_addres + tile_address_offset to our tile
    JSR LoadLevel_NextColumn    ; get next column
    DEX
    BPL -         ; While X >= 0, loop!

    RTS      ; Return