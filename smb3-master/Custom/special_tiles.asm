;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; handle_special_tiles
; 
; Updated by Joe Smo
;
; Handles all unique logic for blocks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

handle_special_tiles:
handle_special_specific_tiles:
; Do some stuff to update every frame

    LDX #$00
    STX slippery_type  ; slippery_type = 0 (not slippery)
    STX is_sinking

    LDA active_inputs
    AND #PAD_DOWN
    BNE +
    LDA #$00
    STA white_block_cnt             ; reset white block counter if not on a white block

    BEQ +

handle_special_tiles_check:
    INX
    CPX #$04
    BEQ ++
+
; loads the correct address to jump to for a given tile
    LDY head_block, x
    LDA spc_at_block_lo, y
    STA Temp_Var1
    LDA spc_at_block_hi, y
    STA Temp_Var1+1
    LDY #$00

; save return address to the stack
    LDA #>handle_special_tiles_check
    PHA
    LDA #<handle_special_tiles_check-1
    PHA
; effectively an indirect jsr
    JMP (Temp_Var1)
++
    RTS

    .include Custom/tile_interaction/tile_main.asm
; per tileset
spc_at_block_hi:
    .include Custom/tile_interaction/spc_at_block_hi.asm
spc_at_block_lo:
    .include Custom/tile_interaction/spc_at_block_lo.asm