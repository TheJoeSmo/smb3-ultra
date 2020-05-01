; Original address was $BABA
; World 2 fortress
    .word W20F_AltL ; Alternate level layout
    .word W20F_AltO ; Alternate object layout
    .byte LEVEL1_SIZE_12 | LEVEL1_YSTART_140
    .byte LEVEL2_BGPAL_02 | LEVEL2_OBJPAL_11 | LEVEL2_XSTART_18
    .byte LEVEL3_TILESET_09 | LEVEL3_VSCROLL_LOCKED | LEVEL3_PIPENOTEXIT
    .byte 9 & %00011111 | LEVEL4_INITACT_NOTHING
    .byte LEVEL5_BGM_FORTRESS | LEVEL5_TIME_300

    .byte $0F, $00, $7F, $16, $00, $61, $17, $00, $62, $18, $00, $63, $19, $00, $64, $1A
    .byte $00, $6F, $11, $1D, $60, $12, $1D, $60, $19, $1E, $61, $11, $21, $60, $12, $21
    .byte $60, $17, $2D, $62, $18, $2C, $63, $19, $2B, $64, $1A, $20, $6F, $11, $3B, $60
    .byte $12, $3B, $60, $11, $3F, $60, $12, $3F, $60, $18, $3D, $60, $19, $3D, $60, $01
    .byte $3E, $73, $05, $3E, $73, $09, $3E, $73, $0D, $3E, $73, $1A, $40, $6F, $00, $40
    .byte $6F, $03, $40, $72, $03, $4C, $60, $04, $4C, $60, $07, $40, $72, $07, $4C, $60
    .byte $08, $4C, $60, $0B, $40, $72, $0B, $4C, $60, $0C, $4C, $60, $0F, $40, $72, $0F
    .byte $4C, $60, $10, $4C, $60, $17, $4C, $61, $18, $4A, $62, $19, $48, $63, $49, $4E
    .byte $FA, $0B, $50, $98, $0F, $50, $90, $13, $50, $90, $17, $50, $90, $01, $5E, $60
    .byte $02, $5E, $60, $07, $59, $60, $09, $58, $60, $0A, $57, $60, $28, $5E, $44, $6A
    .byte $59, $3F, $00, $60, $6F, $01, $62, $60, $02, $62, $60, $09, $68, $6F, $0A, $69
    .byte $6F, $27, $67, $40, $27, $68, $07, $01, $74, $60, $02, $74, $60, $01, $78, $61
    .byte $02, $78, $60, $03, $78, $60, $01, $7C, $73, $03, $7C, $60, $04, $7C, $60, $00
    .byte $80, $66, $01, $8C, $60, $02, $8C, $60, $03, $80, $70, $03, $84, $60, $04, $84
    .byte $60, $03, $88, $60, $04, $88, $60, $03, $8A, $70, $05, $80, $62, $06, $80, $61
    .byte $09, $88, $62, $0A, $89, $66, $00, $8E, $71, $02, $8E, $71, $04, $8E, $71, $06
    .byte $8E, $71, $08, $8E, $71, $07, $8D, $0B, $E8, $68, $20, $0F, $93, $90, $13, $93
    .byte $90, $17, $93, $90, $0F, $9B, $69, $1A, $9B, $69, $10, $9B, $62, $11, $9B, $62
    .byte $12, $9B, $62, $13, $9B, $62, $14, $9B, $62, $15, $9B, $62, $16, $9B, $62, $0F
    .byte $AF, $90, $13, $AF, $90, $17, $AF, $90, $FF
