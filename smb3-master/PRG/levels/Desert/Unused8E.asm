; Original address was $B221
; Empty/unused
    .word Unused8L  ; Alternate level layout
    .word Empty_ObjLayout   ; Alternate object layout
    .byte LEVEL1_SIZE_06 | LEVEL1_YSTART_140
    .byte LEVEL2_BGPAL_00 | LEVEL2_OBJPAL_08 | LEVEL2_XSTART_18
    .byte LEVEL3_TILESET_08 | LEVEL3_VSCROLL_LOCKED | LEVEL3_PIPENOTEXIT
    .byte 9 & %00011111 | LEVEL4_INITACT_NOTHING
    .byte LEVEL5_BGM_OVERWORLD | LEVEL5_TIME_300

    .byte $FF
