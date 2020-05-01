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
	.byte %00000001, %00000010, %00000100, %00001000
	.byte %00010000, %00100000, %01000000, %10000000

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
tile_do_nothing:
	RTS

spc_at_blocks:
	.word tile_do_49 				; 49
	.word tile_do_4A 				; 4A
	.word do_tile_81 				; 81
	.word do_tile_82 				; 82
	.word do_tile_83 				; 83
	.word do_tile_84 				; 84


quicksand_tileset_enabled:
	.byte %00100000, %00000100, 0, 0, 0, 0, 0, 0

tile_do_49:
tile_do_4A:
tile_do_quick_sand:
	CPX #$00
	BEQ ++ 							; we don't check if the player's head is in the quicksand

; Check what tilesets use quicksand
	LDA <quicksand_tileset_enabled
	STA Temp_Var1
	LDA >quicksand_tileset_enabled
	STA Temp_Var1+1
	LDA tile_check_tileset
	BNE +
++
-
	RTS
+
    LDA player_y_vel
    BMI -							; if moving upward do nothing

; Do quick sand logic
	TXA
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
    TAX      						; difference -> x
    AND #%11110000  				; Keep only upper 4 bits
    BNE +  							; if not on top of sand jump

    TXA      						; restore difference
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
    PLA
    TAX
    RTS

do_tile_81:
do_tile_82:
do_tile_83:
do_tile_84:
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

toad_house_item_offset:
    .byte $02, $03, $0A, $0A, $0A, $05, $08, $0B, $0E, $11

; Toad House items: 0 Warp Whistle,1 P-Wing,2 Frog Suit,3 Tanooki,4 Hammer,5 Frog,6 Tanooki
; 7 Hammer,8 Mushroom,9 Fire Flower,10 Leaf
toad_house_item_received:
    .byte $0C, $08, $04, $05, $06, $04, $05, $06, $01, $02, $03, $04, $02, $03, $05

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
; X = 5 if random super suit (frog, tanooki, hammer)
; X = 6 if standard random basic item
    LDA cur_random
    AND #$0f
    TAY
    LDA toad_house_items, y 		; get a random item

    LDY toad_house_type
    CLC
    ADC toad_house_item_offset, y  	; add the correct offset
    STA Objects_Frame 				; store item you are getting

+
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
