;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This files contains all the routines utilized by
; special_tiles.asm
;
; updated by Joe Smo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Responsible for checking the tileset to see if we should do 
; anything
;
; updated by Joe Smo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tile_check_shortcut:
	.byte %10000000, %01000000, %00100000, %00010000
	.byte %00001000, %00000100, %00000010, %00000001

tile_check_tileset_shortcut:
	.byte 0, 1, 2, 3, 4, 5, 6, 7

tile_check_tileset:
; return Temp_Var1[tile_check_tileset_shortcut[tileset >> 4]] & tile_check_shortcut[tileset & 0x0F]
; Temp_Var1[tile_check_tileset_shortcut[tileset >> 4]]
	LDA tileset
	AND #%11110000
	LSR A
	LSR A 
	LSR A 
	LSR A 
	TAY
	LDA (Temp_Var1), y
	STA Temp_Var1

; tile_check_shortcut[tileset & 0x0F]
	LDA tileset
	AND #$0F 
	TAY
	LDA tile_check_shortcut, y

; return a & b
	AND Temp_Var1

tile_do_00:
tile_do_01:
tile_do_02:
tile_do_03:
tile_do_04:
tile_do_05:
tile_do_06:
tile_do_07:
tile_do_08:
tile_do_09:
tile_do_0A:
tile_do_0B:
tile_do_0E:
tile_do_0F:
tile_do_10:
tile_do_11:
tile_do_12:
tile_do_13:
tile_do_14:
tile_do_15:
tile_do_16:
tile_do_17:
tile_do_18:
tile_do_19:
tile_do_1A:
tile_do_1B:
tile_do_1C:
tile_do_1D:
tile_do_1E:
tile_do_1F:
tile_do_20:
tile_do_21:
tile_do_28:
tile_do_29:
tile_do_2A:
tile_do_2B:
tile_do_2C:
tile_do_2D:
tile_do_2E:
tile_do_2F:
tile_do_30:
tile_do_31:
tile_do_32:
tile_do_33:
tile_do_3B:
tile_do_3C:
tile_do_3D:
tile_do_3E:
tile_do_3F:
tile_do_40:
tile_do_41:
tile_do_42:
tile_do_43:
tile_do_44:
tile_do_45:
tile_do_46:
tile_do_47:
tile_do_48:
tile_do_4D:
tile_do_4E:
tile_do_4F:
tile_do_50:
tile_do_51:
tile_do_52:
tile_do_53:
tile_do_54:
tile_do_57:
tile_do_58:
tile_do_59:
tile_do_5A:
tile_do_5B:
tile_do_5C:
tile_do_5D:
tile_do_5E:
tile_do_5F:
tile_do_60:
tile_do_61:
tile_do_62:
tile_do_63:
tile_do_64:
tile_do_65:
tile_do_67:
tile_do_68:
tile_do_69:
tile_do_6A:
tile_do_6B:
tile_do_6C:
tile_do_6D:
tile_do_6E:
tile_do_6F:
tile_do_70:
tile_do_71:
tile_do_72:
tile_do_73:
tile_do_74:
tile_do_75:
tile_do_76:
tile_do_77:
tile_do_78:
tile_do_79:
tile_do_7A:
tile_do_7B:
tile_do_7C:
tile_do_7F:
tile_do_80:
tile_do_85:
tile_do_86:
tile_do_87:
tile_do_88:
tile_do_89:
tile_do_8A:
tile_do_8B:
tile_do_8C:
tile_do_8D:
tile_do_8E:
tile_do_8F:
tile_do_90:

tile_do_93:
tile_do_94:
tile_do_95:
tile_do_96:
tile_do_97:
tile_do_99:
tile_do_9B:
tile_do_9C:
tile_do_9D:

tile_do_9F:
tile_do_A0:
tile_do_A1:
tile_do_A2:
tile_do_A3:
tile_do_A4:
tile_do_A5:
tile_do_A6:
tile_do_A7:
tile_do_A8:
tile_do_A9:
tile_do_AA:
tile_do_AB:
tile_do_AC:


tile_do_C1:
tile_do_C3:
tile_do_C4:
tile_do_C5:
tile_do_C6:
tile_do_C7:
tile_do_C8:
tile_do_C9:
tile_do_CA:
tile_do_CB:
tile_do_CC:
tile_do_CD:
tile_do_CE:
tile_do_CF:
tile_do_D0:
tile_do_D1:
tile_do_D2:
tile_do_D3:
tile_do_D4:
tile_do_D5:
tile_do_D6:
tile_do_D7:
tile_do_D8:
tile_do_D9:
tile_do_DA:
tile_do_DB:
tile_do_DC:
tile_do_DD:
tile_do_DE:
tile_do_DF:
tile_do_E0:
tile_do_E1:
tile_do_E4:
tile_do_E5:
tile_do_E6:
tile_do_E7:
tile_do_E8:
tile_do_E9:
tile_do_EA:
tile_do_EB:
tile_do_EC:
tile_do_ED:
tile_do_EE:
tile_do_EF:
tile_do_F0:
tile_do_F1:
tile_do_F2:
tile_do_F3:
tile_do_F5:
tile_do_F6:
tile_do_F7:
tile_do_F8:
tile_do_F9:
tile_do_FA:
tile_do_FB:
tile_do_FC:
tile_do_FD:
tile_do_FE:
tile_do_FF:
tile_do_nothing:
	RTS


player_x_offset_for_pipes:
    .byte $08, $04, $04 ; Offset applied to Player_X when: in air or level is sloped, Player is NOT small, Player is small

    ; This table enables certain pipe tiles by tileset
    ; (since some have more pipe tile types than others)
    ; bit 6 enables TILE8_PIPEH3_B (not enterable)
    ; bit 7 enables TILE3_PIPETB5_L/R (takes Player to common exit area)
PipeTile_EnableByTileset:
    ; Indexed by tileset
    .byte %00000000 ;  0 Plains style
    .byte %00000000 ;  1 Mini Fortress style
    .byte %10000000 ;  2 Hills style
    .byte %00000000 ;  3 High-Up style
    .byte %00000000 ;  4 pipe world plant infestation
    .byte %00000000 ;  5 water world
    .byte %00000000 ;  6 Toad House
    .byte %11000000 ;  7 Vertical pipe maze
    .byte %01000000 ;  8 desert levels
    .byte %00000000 ;  9 Airship
    .byte %11000000 ; 10 Giant World
    .byte %00000000 ; 11 Ice level
    .byte %11000000 ; 12 Sky level
    .byte %10000000 ; 13 Underground

Pipe_enter_inputs:
    .byte PAD_RIGHT, PAD_LEFT   ; What to press to enter a horizontal pipe; pad right and left, respectively
    .byte PAD_DOWN, PAD_UP      ; What to press to enter a vertical pipe; pad down and up, respectively

tile_do_AD:
tile_do_AE:
tile_do_AF:
tile_do_B0:
tile_do_B1:
tile_do_B2:
tile_do_B3:
tile_do_B4:
tile_do_B5:
tile_do_B6:
tile_do_B7:
tile_do_B8:
tile_do_B9:
tile_do_BA:
tile_do_BB:
tile_do_BC:
tile_do_BD:
tile_do_BE:

tile_do_9E:
tile_do_BF:

tile_do_91:
tile_do_92:

; A mega routine for all the pipes
tile_do_pipes:
    TXA     ; todo: make this routine dynamic
    PHA

    LDA is_statue
    ORA tail_swipe_counter
    ORA invis_summer_sault
    BEQ +

tile_do_no_pipes:
    PLA
    TAX
    RTS

+
    LDY tileset
    LDA PipeTile_EnableByTileset, y     ; handles custom pipes
    STA pipes_by_tileset

    LDA in_air
    BNE +++

    LDA front_block                     ; Get tile near head...

    LDY is_vertical
    BEQ +                               ; If !vertical then jump
; Is vertical
    LDY #$02
    CMP #TILE8_SCENPIPE_ENDH1B
    BEQ ++  ; If tile near head is TILE8_SCENPIPE_ENDH1B, jump to PRG008_BC87
    LDY #$00

+ ; BC79
    CMP #TILE1_PIPEH1_B
    BEQ ++      ; If tile near head is TILE1_PIPEH1_B, jump to PRG008_BC87

    BIT pipes_by_tileset  ; PipeTile_EnableByTileset value
    BVC +++     ; if TILE8_PIPEH3_B !enabled jump to PRG008_BCAA

; Check TILE8_PIPEH3_B
    LDY #$03
    CMP #TILE8_PIPEH3_B
    BNE +++     ; If tile near head is NOT TILE8_PIPEH3_B, jump to PRG008_BCAA

++ ; BC89

; May be entering a pipe
    LDX #$00     ; X = 0

    LDA player_x
    AND #$0f                        ; lower it to the pixel on the block
    CMP #$08
    BLS +                           ; relative location < 8 aka if on the left jump
    INX     ; x = 1 = right or x = 0 = left
+
    LDA active_inputs
    AND Pipe_enter_inputs, x    ; get if the player is holding left/right for the left/right pipe
    BEQ +++                         ; jump if ~input_held

; We are entering a pipe

    TYA
    BNE +                           ; if !0 then time to enter pipe

    LDY #$01
    LDA horz_scroll_lock
    BEQ +   ; if ~horz_scroll_lock then enter a pipe (basically finds if we are already entering the pipe)
    DEY
+
    JSR PipeEntryPrepare            ; enter pipe time
    PLA
    TAX     ; get x back
    RTS  ; Jump to PRG008_BD4B
-
    PLA
    TAX
    RTS


+++
; Not entering a pipe yet...
    LDX #$02
    LDA left_block

    LDY in_air
    BEQ +                           ; if !in_air then jump

; We are in the air
    LDY hit_ceiling
    BEQ -                           ; if !hit_ceiling then jump backwards

    LDY is_ducking
    BEQ ++                          ; if is_ducking then jump else jump backwards

    JMP -  ; Otherwise, jump to PRG008_BD4B

++ ;PRG008_BCC0:
    INX      ; X = 3
    LDA right_block
+
    STA Temp_Var1                   ; right_block
    STX Temp_Var3                   ; pipe mode

    LDA #TILE1_PIPETB2_R            ; load right pipe tile
    SEC
    SBC Temp_Var1                   ; pipe tile - floor tile
    CMP #$04                        ; if vertical pipe tiles then...

    LDY horz_scroll_lock
    BEQ +  ; If not in a Big Question Block area, jump to PRG008_BCD6

    AND #$01     ; Not sure what they need this for?

+ ;PRG008_BCD6:
    TAY                             ; result + the AND if horz_scroll_lock
    BCC ++                          ; if was a pipe tile jump

; Not a pipe 1 or 2 end tile...
    LDY pipes_by_tileset
    BPL +  ; if TILE3_PIPETB5_L/R disabled jump

; Need to check TILE3_PIPETB5_L/R
    LDA #TILE3_PIPETB5_R
    SEC
    SBC Temp_Var1                   ; if TILE3_PIPETB5_R - right tile then...
    CMP #$02
    LDY #$06
    BCC ++                          ; if in range then jump

+ ;PRG008_BCE8:
    LDA #TILE1_PIPETB4_R
    LDY is_vertical
    BEQ +                           ; if !vertical then jump

    LDA #TILE8_SCENPIPE_ENDVR

+ ;PRG008_BCF1:
    SEC
    SBC Temp_Var1                   ; tile
    CMP #$02
    BCS -                 ; if not in range then we are not entering a pipe
    LDY #$04

++ ;PRG008_BCFA:
    STY Temp_Var1                   ; Temp_Var1 = pipe_type

    AND #$01                        ; if right then 1 else 0
    ASL A
    ASL A
    ASL A
    ASL A                           ; multiply by 16, a table would be better
    STA Temp_Var2                   ; Temp_Var2 = result

; Determine if we are holding the correct buttons to enter a pipe
    LDA active_inputs
    AND Pipe_enter_inputs, x        ; if holding the correct direction for the pipe...
    BEQ -                 ; if ~holding then jump (not entering a pipe)

; Time to enter a pipe
    LDA pipe_movement
    BNE -                 ; if in_pipe then don't enter another pipe

    LDY #$00
    LDA in_air
    ORA is_sloped
    BNE +                           ; if in_air or is_sloped then jump

    INY
    LDA Player_Suit
    BNE +                           ; if !small then jump

    INY                             ; player is small

+ ;PRG008_BD1F:
; if y = 0 then in_air or is_sloped elif y = 1 then player is ~small else player is small
    LDA player_x
    AND #$0f
    PHA                             ; save relative x for later

    CLC
    ADC player_x_offset_for_pipes, y; add offset
    AND #$10    ; Check if on "odd" tile (only true on Player_X 16, 48, 80, etc.) AKA right tile
    BNE +                           ; if odd then jump

    PLA                             ; restore relative x
    ORA #$F0                        ; make negativish
    PHA                             ; save relative x for later

+ ;PRG008_BD30:
    PLA                             ; restore relative x
    CLC
    ADC Temp_Var2                   ; 0 or 16, left or right tile respectively

    SEC
    SBC #3
    CMP #10
    BGE +     ; If Player_X >= 10 after subtracting 3 (??), jump to PRG008_BD4B (no pipe today)

    LDA Temp_Var1                   ; get pipe_type
    LSR A
    TAY
    JSR PipeEntryPrepare            ; prepare entry into pipe!
    JSR PipeMove_SetPlayerFrame     ; update Player frame!
    PLA
    PLA
    PLA
    PLA
    PLA
    PLA     ; We do not want to change the bank back
    JMP Player_Draw29               ; draw Player
; Do not return to caller!! and do not restore x

+
    PLA
    TAX

    PLA
    PLA
    RTS


conveyor_tileset_enabled:
    .byte %01011000, 0, 0, 0, 0, 0, 0, 0

tile_do_34:
left_conveyor:
    LDY #-16
    BNE tile_do_conveyor

tile_do_35:
tile_do_right_conveyor:
    LDY #16

tile_do_conveyor:
    CPX #$00    ; only check the feet
    BEQ +
    CPX #$03
    BEQ +

    LDA in_air
    BNE +       ; if in air then jump (no conveyor)
    LDA pswitch_cnt
    BEQ ++       ; if in air then jump (no conveyor)
+
    RTS
++

; Check what tilesets use conveyors
    LDA tileset
    CMP #$01
    BEQ +
    CMP #$03
    BEQ +
    CMP #$04
    BEQ +
    RTS
+

; Do conveyor action (we are on a conveyor)
    STY player_slide
    RTS

tile_do_7D:
tile_do_7E:
tile_do_spikes_tileset_nine:
    LDA tileset
    CMP #$08
    BEQ tile_do_spikes_main
    RTS

tile_do_0C:
tile_do_0D:
tile_do_spikes_tileset_eight:
    LDA tileset
    CMP #$07
    BEQ tile_do_spikes_main
    RTS

tile_do_E2:
tile_do_E3:
tile_do_spikes_tileset_two:
    LDA tileset
    CMP #$01
    BEQ tile_do_spikes_main
    RTS

tile_do_66:
tile_do_F4:
tile_do_spikes_main:
tile_do_jelectro:
tile_do_muncher:
    LDA is_kuribo
    BEQ +
-
    RTS
+
    LDA hit_ceiling
    BNE -
tile_do_hurt:
    JMP player_get_hurt_alt


tile_do_98:
tile_do_C0:
tile_piranha_alt_tiles:
    LDY #$01
    LDA PatTable_BankSel+1
    CMP #$3e
    BNE tile_prianha_return         ; if neither return
    BEQ tile_prianha_tiles_main

tile_do_9A:
tile_do_C2:
tile_piranha_tiles:
    LDY #$00
    LDA PatTable_BankSel+1
    CMP #$60
    BNE tile_prianha_return  ; If current pattern table is $60, jump to PRG008_BDC9

tile_prianha_tiles_main:
    LDA tileset
    CMP #$04
    BEQ +
tile_prianha_return:
    RTS
+
    CPX #$03
    BEQ tile_prianha_return     ; don't check the third x

; Get hurt
    JMP player_get_hurt_alt   ; Get hurt!

; Quicksand and the icy tiles are used, so we check the head for quicksand and the rest for the tile
tile_do_4A:
    CPX #$00
    BNE +
    JMP tile_do_quick_sand
+
    JMP tile_icy

not_slippery:
    RTS

tile_do_36:
tile_do_37:
tile_do_38:
tile_do_39:
tile_do_3A:
tile_do_55:
tile_do_56:
tile_super_icy:
    LDY #$02
    BNE +

tile_do_22:
tile_do_23:
tile_do_24:
tile_do_4B:
tile_do_4C:
tile_icy:
    LDY #$01
+
    LDA tileset
    CMP #$0B
    BNE not_slippery

    LDA in_air
    BNE not_slippery
    STY slippery_type  ; we are on a slippery tile
    RTS


tile_do_25:
tile_do_26:
tile_do_27:
tile_do_white_tile:
    LDA tileset
    BEQ +       ; only check for white tiles in the plains tileset
-
    LDA #$00
    STA white_block_cnt         ; reset white block counter if not on a white block
    RTS
+
    CPX #$01    ; only check for the tiles the player is above
    BEQ +
    CPX #$02
    BEQ +
    RTS
+
; We are on a white block 
    LDA active_inputs
    AND #PAD_DOWN
    BEQ -                           ; if !down then jump

; We are holding down
    INC white_block_cnt             ; white_block_cnt++
    LDA white_block_cnt
    CMP #$F0
    BNE ++                          ; if white_block_cnt !$F0, jump to ++

; Fall into background...

    LDA #$F0                        ; can remove this, but this allows for changing of the value
    STA is_behind                   ; set player as behind the scene

    LDA #$00
    STA player_y_vel                ; halt player vertically

    LDA player_y
    CLC
    ADC #$06
    STA player_y                    ; force player down by 6 pixels (fall)
    INC in_air                      ; is in air

; Don't register 'A' button
    LDA new_inputs
    AND #<~PAD_A
    STA new_inputs
++
    RTS

quicksand_tileset_enabled:
	.byte %00100000, %00000100, 0, 0, 0, 0, 0, 0

tile_do_49:
tile_do_quick_sand:
	CPX #$00
	BEQ ++ 							; we don't check if the player's head is in the quicksand

; Check what tilesets use quicksand
	LDA #<quicksand_tileset_enabled
	STA Temp_Var1
	LDA #>quicksand_tileset_enabled
	STA Temp_Var1+1
	JSR tile_check_tileset
	BNE +
++
-
	RTS
+
    LDA player_y_vel
    BMI -							; if moving upward do nothing

; Do quick sand logic
    LDA #$00						; disable ducking and sliding
    STA is_ducking
    STA is_sliding

    LDA is_sinking
    BNE +     						; if already sinking then we don't need to get the y position

    LDA player_y        ; Get player_y at initial quicksand hit only...
+
    AND #%11110000
    STA is_sinking  				; player_y high bits

; player_y - is_sinking
    LDA player_y
    SEC
    SBC is_sinking

    LDY #-$20    					; y = -$20 (escape jump vel)
    PHA      						; difference -> x
    AND #%11110000  				; Keep only upper 4 bits
    BNE +  							; if not on top of sand jump

    PLA      						; restore difference
    AND #%00001111
    CMP #$03
    BGE +  							; not close enough so jump

    LDY #-$30    					; almost out of quick sand speed)

+
    LDA new_inputs
    BMI +  							; if Player is pressing 'A', jump to +

    INC is_sinking 					; we are sinking

    LDY #$06     					; y = $06 (sinking vel)
    BNE ++  						; jump

+
; Player is trying to escape!  Play jump sound!
    LDA player_sound_queue
    ORA #SND_PLAYERJUMP
    STA player_sound_queue

++
    STY player_y_vel ; Set Player's Y velocity

; Limit Player's horizontal movement
    LDA player_x_vel
    ASL A
    ROR player_x_vel
    BPL +
    INC player_x_vel
+
    RTS

do_tile_81:
do_tile_82:
do_tile_83:
do_tile_84:
    CPX #$00
	BNE do_tile_84_nothing ; if !head_block do nothing
	LDA tileset
	CMP #ts_toad_house
	BEQ tile_do_toad_house_chest
do_tile_84_nothing:
	RTS

; Determines what x position box you will receive
toad_house_block_location_shortcut:
	.byte $60, $90

; Determines the x position for blocks to change
toad_house_x_locations:    
	.byte $40, $70, $A0

; Used to determine the item received from a toad house 
toad_house_items:
    .byte $00, $01, $02, $00, $01, $02, $00, $01, $02, $00, $01, $02, $00, $01, $02, $00

; Toad House items: 0 Warp Whistle,1 P-Wing,2 Frog Suit,3 Tanooki,4 Hammer,5 Frog,6 Tanooki
; 7 Hammer,8 Mushroom,9 Fire Flower,10 Leaf
toad_house_item_received:
    .byte $0C, $08, $04, $05, $06, $04, $05, $06, $01, $02, $03, $04, $02, $03, $05

toad_house_item_offset:
    .byte $02, $03, $0A, $0A, $0A, $05, $08, $0B, $0E, $11

inventory_row_offsets:
    .byte $15, $0E, $07, $00

inventory_goto_x:
    .byte $48, $60, $78, $90, $A8, $C0, $D8

tile_do_toad_house_chest:
    BIT new_inputs
    BVC do_tile_84_nothing  ; if !holding_b do nothing

    LDY #$00
    LDA player_x
-
    CMP toad_house_block_location_shortcut, y
    BLT + 					; if player_x < location[y] continue
    CPY #$01
    BEQ ++ 					; if made it past last check add an additional y
    INY
    BNE - 					; always branch
++
	INY
+

; Block change is always same height regardless of which box...
    LDA #$80
    STA block_event_lo_y
    LDA #$01
    STA block_event_hi_y
    STA skip_status_bar  	; we need a bigger graphics buffer 
    LDA #$00
    STA block_event_hi_x
; Get the correct x position for the lo x of the chest
    LDA toad_house_x_locations, y
    STA block_event_lo_x
    STA objects_x

; Queue the event we want
    LDA #CHNGTILE_TOADBOXOPEN
    STA block_event_queue

; toad_house_type = 7 is standard random basic item (mushroom, flower, leaf)
    LDY toad_house_type
    DEY
    CPY #$05
    BLS +  ; If (toad_house_type - 1) < 5, jump to +


    LDA cur_random
    AND #$0f
    TAY
    LDA toad_house_items, y 		; get a random item

    LDY toad_house_type
    DEY
    CLC
    ADC toad_house_item_offset, y  	; add the correct offset
    TAY

+
    LDA toad_house_item_received, y
    STA Objects_Frame 				; store item you are getting

    LDA block_event_lo_x
    LSR A
    LSR A
    STA Temp_Var1   				; Temp_Var1 = X position / 4

    LDY cur_player
    BEQ +  							; if Mario skip this step else get Luigi offset
    LDY #luigi_items - mario_items    
+
	TXA
	PHA 							; save the block we are on for later
	LDX #$00
-
    LDA mario_items, y   			; get the current player's items
    BEQ +     						; if slot is empty, jump to +

; Update item slot and count (y and x respectively)
    INY
    INX
    CPX #mario_cards - mario_items - 1
    BLT -  							; continues to increment until we run out of space or we find an empty slot
; Could change what happens when we run out of space by adding code here
+
    STY objects_v1     				; stores inventory index

; index % 7
    TXA
    LDY #$03    					; 4 possible rows of inventory
-
    CMP #$07
    BLT +  							; if index < 7 then jump
    SBC #$07     					; index - 7, y - 1
    DEY
    BNE -							; while y loop
+
    TAX
    LDA inventory_row_offsets, y    ; get base inventory index for this row
    STA objects_v2

; Configure the treasure box item to pop out!
    LDA #OBJSTATE_NORMAL
    STA objects_states
    LDA #OBJ_TOADHOUSEITEM
    STA objects_ids
    LDA #$90
    STA objects_y

; Calculates a good fly rate so item lands in the inventory slot
    LDA inventory_goto_x, x    		; get the row's offset from the % 7
    LSR A
    LSR A
    SEC
    SBC Temp_Var1       			; was objects X / 4
    STA objects_x_velocity

    LDA #-$30
    STA objects_y_velocity

    LDA #$00
    STA objects_x_subpixel

    LDA #$ff
    STA objects_timer
    STA objects_v4

; Play Inventory flip noise
    LDA map_sound_queue
    ORA #SND_MAPINVENTORYFLIP
    STA map_sound_queue

    PLA 						; restore the block we stored
    TAX
    RTS
