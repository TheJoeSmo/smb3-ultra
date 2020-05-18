LoadLevel_NextColumn:
    INY         ; move one tile to the right
    TYA
    AND #$0f
    BNE +       ; if we did not loop over (down 1)

; Otherwise, move to the next screen (+$1B0)
    ADD_WORD_BIG tile_address, tile_address+1, $01B0

; Get tile_address_offset and only keep the row, but clear 'Y' lower bits since
; we're going to column 0 on the same row, new screen...
    LDA tile_address_offset
    AND #$f0
    TAY
+
    RTS      ; Return
