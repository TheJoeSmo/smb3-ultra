; Original address was $A7F7
; King's Room W3
    .word W3Airship_IntroL  ; Alternate level layout
    .word WAirship_IntroO   ; Alternate object layout
    .byte LEVEL1_SIZE_01 | LEVEL1_YSTART_170
    .byte LEVEL2_BGPAL_01 | LEVEL2_OBJPAL_10 | LEVEL2_XSTART_70 | LEVEL2_UNUSEDFLAG
    .byte LEVEL3_TILESET_10 | LEVEL3_VSCROLL_LOCKED | LEVEL3_PIPENOTEXIT
    .byte 22 & %00011111 | LEVEL4_INITACT_NOTHING
    .byte LEVEL5_BGM_THRONEROOM | LEVEL5_TIME_300

    .byte $00, $00, $03, $E0, $63, $20, $FF
