;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Could put into a macro .macro _tile and put .endm at the end
; then every instance of a horizontal run, you can simply insert the same code
;
; Block can go go from 1x1 to 256x256
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_tile = $00

large_xy_block_run:
_tile_address = Temp_Var1
_width = Temp_Var3
_height = Temp_Var4
__width = Temp_Var5

    LDY #$00
    LDA (tile_layout_address), y                            ; get next byte
    STA _width

    LDA #$01
    ADD_WORD tile_layout_address, tile_layout_address+1     ; tile_layout_address++

; Backup tile_address
    LDA tile_address
    STA _tile_address
    LDA tile_address+1
    STA _tile_address+1

    LDA block_size
    STA _height

    LDA _width
    STA __width

    LDY tile_address_offset     ; Y = tile_address_offset
-
    LDA _tile
    STA (tile_address), y       ; set the correct tile

    JSR LoadLevel_NextColumn    ; go one to the right

    DEC __width
    LDA __width
    CMP #-1
    BNE -                       ; if __width !-1, loop

; Did one row of width
    DEC _height     ; _height--
    BPL +           ; While _height >= 0, jump to +

    RTS      ; Return

+
; Restore from backup
    LDA _tile_address
    STA tile_address
    LDA _tile_address+1
    STA Map_Tile_AddrH

; Do some 16 bit math and transfer to y
    LDA tile_address_offset
    CLC
    ADC #16
    STA tile_address_offset
    TAY
    LDA tile_address+1
    ADC #$00
    STA tile_address+1
    STA _tile_address+1     ; Update backup of tile_address+1

    LDA _width
    STA __width             ; restore width
    BNE -