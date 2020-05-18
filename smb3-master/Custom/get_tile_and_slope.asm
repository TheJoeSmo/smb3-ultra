
    ; Offsets used for tile detection in non-sloped levels
    ; +16 if moving downward
    ; +8 if on the right half of the tile
TileAttrAndQuad_OffsFlat:
    ;     Yoff Xoff

    ; Not small or ducking moving downward - Left half
    .byte $20, $04  ; Ground left
    .byte $20, $0B  ; Ground right
    .byte $1B, $0E  ; In-front lower
    .byte $0E, $0E  ; In-front upper

    ; Not small or ducking moving downward - Right half
    .byte $20, $04  ; Ground left
    .byte $20, $0B  ; Ground right
    .byte $1B, $01  ; In-front lower
    .byte $0E, $01  ; In-front upper

    ; Not small or ducking moving upward - Left half
    .byte $06, $08  ; Ground left
    .byte $06, $08  ; Ground right
    .byte $1B, $0E  ; In-front lower
    .byte $0E, $0E  ; In-front upper

    ; Not small or ducking moving upward - Right half
    .byte $06, $08  ; Ground left
    .byte $06, $08  ; Ground right
    .byte $1B, $01  ; In-front lower
    .byte $0E, $01  ; In-front upper


TileAttrAndQuad_OffsFlat_Sm:
    ; Small or ducking moving downward - Left half
    .byte $20, $04  ; Ground left
    .byte $20, $0B  ; Ground right
    .byte $1B, $0D  ; In-front lower
    .byte $14, $0D  ; In-front upper

    ; Small or ducking moving downward - Right half
    .byte $20, $04  ; Ground left
    .byte $20, $0B  ; Ground right
    .byte $1B, $02  ; In-front lower
    .byte $14, $02  ; In-front upper

    ; Small or ducking moving upward - Left half
    .byte $10, $08  ; Ground left
    .byte $10, $08  ; Ground right
    .byte $1B, $0D  ; In-front lower
    .byte $14, $0D  ; In-front upper

    ; Small or ducking moving upward - Right half
    .byte $10, $08  ; Ground left
    .byte $10, $08  ; Ground right
    .byte $1B, $02  ; In-front lower
    .byte $14, $02  ; In-front upper



    ; Offsets used for tile detection in sloped levels
TileAttrAndQuad_OffsSloped:
    ; Offsets pushed into Player_GetTileAndSlope
    ;    Yoff Xoff

    ; Not small or ducking - Left half
    .byte $20, $08  ; feet
    .byte $05, $08  ; head
    .byte $18, $03  ; in-front lower
    .byte $0C, $03  ; in-front upper

    ; Not small or ducking - Right half
    .byte $20, $08  ; feet
    .byte $05, $08  ; head
    .byte $18, $0D  ; in-front lower
    .byte $0C, $0D  ; in-front upper

TileAttrAndQuad_OffsSloped_Sm:
    ; Small or ducking - Left half
    .byte $20, $08  ; feet
    .byte $12, $08  ; head
    .byte $18, $03  ; in-front lower
    .byte $17, $03  ; in-front upper

    ; Small or ducking - Right half
    .byte $20, $08  ; feet
    .byte $12, $08  ; head
    .byte $18, $0D  ; in-front lower
    .byte $17, $0D  ; in-front upper

    ; Explicitly for walking off an edge in a sloped area
TileAttrAndQuad_OffsSlopeEdge:
    .byte $20, $04  ; Right half
    .byte $20, $0B  ; Left half

PlayerY_HeightOff:  .byte $12, $05  ; Left value is player_y offset for small/ducking, right for otherwise
PRG008_B3AC:
    .byte $02, $0E  ; Left/Right half, not small
    .byte $03, $0D  ; Left/Right half, small

PRG008_B3B0:    .byte $04, $0D

    ; If $01, this is treated as a "not floor" tile, which means to watch out
    ; for the Player to hit his head rather than track the sloped floor...
Slope_IsNotFloorShape:
    .byte $01, $00, $00, $00, $00, $01, $01, $00    ; $00-$07
    .byte $01, $01, $00, $01, $00, $00, $00, $00    ; $08-$0F
    .byte $01, $01, $01, $01, $01           ; $10-$14

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player_GetTileAndSlope
;
; Gets tile and attribute of tile for either non-vertical or
; vertical levels based on Player's position
;
; Temp_Var10 is a Y offset (e.g. 0 for Player's feet, 31 for Player's head)
; Temp_Var11 is an X offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_y_offset = Temp_Var10
_x_offset = Temp_Var11

Player_GetTileAndSlope:

    LDA #$00
    STA temp_17

    LDA is_vertical
    BNE +is_vertical  ; If level is vertical, jump to +

    LDA player_partition_detection
    BEQ +no_parition  ; if no partition detection jump

; Bottom two tile rows forced detection enabled when Player Y >= 160...
    LDA is_above_level
    BNE +no_parition

    LDA player_y
    CLC
    ADC _y_offset
    SEC
    SBC alt_level_scroll_lo    ; relative to vertical scroll (the player needs to be on the bottom of the screen)

    CMP #160
    BLT +no_parition  ; if result < 160, jump we do not detect anything

; Player is low enough to the visual floor... detect the bottom two rows of tiles!
_temp_y_w_offset = Temp_Var14
_temp_y_hi_w_offset = Temp_Var13
_temp_x_with_offset = Temp_Var16
_temp_x_with_hi_offset = Temp_Var15
    SBC #16
    AND #$F0    ; align to tile grid
    STA _temp_y_w_offset

    LDA #$01
    STA _temp_y_hi_w_offset       ; the player is on the bottom of the level
    STA temp_17

    BNE +               ; jump

+no_parition
    LDA player_y_hi
    STA _temp_y_hi_w_offset

    LDA _y_offset
    CLC
    ADC player_y
    STA _temp_y_w_offset         ; _temp_y_w_offset = _y_offset + player_y

    BCC +               ; if no carry don't add 1 to the high byte
    INC _temp_y_hi_w_offset
+

    LDA _temp_y_hi_w_offset
    BEQ +               ; if high y or carry = 0, jump to +
; When carry exists..

    CMP #$01
    BNE ++

    LDA _temp_y_w_offset
    CMP #$b0
    BLT +               ; if _temp_y_w_offset < $B0, jump to +

++
    ; under the level?
    LDA #$00
    STA player_slope
    RTS

+
    LDA player_x_hi
    STA _temp_x_with_hi_offset

    LDA _x_offset
    BPL +           ; if _x_offset >= 0 jump
    DEC _temp_x_with_hi_offset

+
    LDA player_x
    CLC
    ADC _x_offset
    STA _temp_x_with_offset     ; _temp_x_with_offset = player_x + _x_offset
    BCC +
    INC _temp_x_with_hi_offset

+

; So in total we've calculated:
; _temp_y_hi_w_offset and _temp_y_w_offset -- Y Hi and Lo
; _temp_x_with_hi_offset and _temp_x_with_offset -- X Hi and Lo

; X/Y were not modified, so as inputs:
; X = 0 (going down) or 1 (going up)
; Y = player_y_vel

    STY _y_offset  ; _y_offset = player_y_vel
    STX _x_offset  ; _x_offset = 0 or 1

    JSR player_get_tile_and_slope    ; Set Level_Tile and player_slope

    LDX _x_offset           ; going up or down
    LDY pipe_movement
    BNE +
    JSR correct_for_p_switch     ; if not in pipe movement
+
    LDY _y_offset
    RTS


+is_vertical
    LDA player_y_hi
    STA _temp_y_hi_w_offset     ; _temp_y_hi_w_offset = player_y_hi

    LDA _y_offset
    CLC
    ADC player_y
    STA _temp_y_w_offset        ; _temp_y_w_offset = _y_offset + player_y
    BCC +                       ; if no carry
    INC _temp_y_hi_w_offset
+

    LDA _temp_y_hi_w_offset
    BPL +                       ; if _temp_y_hi_w_offset >= 0, jump to +

; Under the level?
    LDA #$00
    RTS                         ; no tile

+
    LDA player_x
    CLC
    ADC _x_offset
    STA _temp_x_with_offset     ; _temp_x_with_offset = player_x + _x_offset

    STY _y_offset               ; _y_offset = Y

    JSR player_get_tile_vertical  ; Get tile, set Level_Tile

    LDY pipe_movement   ; Y = pipe_movement
    BNE PRG008_B46C     ; If pipe_movement <> 0, jump to PRG008_B46C

    JSR PSwitch_SubstTileAndAttr     ; Otherwise, substitute tile if effected by P-Switch

PRG008_B46C:
    LDY #$00
    STY _temp_x_with_hi_offset  ; _temp_x_with_hi_offset = 0

    LDY _y_offset  ; Y = _y_offset
    RTS      ; Return


; ALTERNATE VERTICAL SCREEN

; Each "screen" (stacked vertically) is made up of 15 rows of tiles
; which amounts to $F0 bytes per screen; the following split LUT defines tile memory
; offsets gapped by $F0... not sure why they had to make the address lookup into two LUTs
; like they did, but whatever... 16 vertical screens available

; High bytes are separate from low
Tile_MemH = >Tile_Mem

; Vertical low byte, per screen
vertical_tile_memory_lo_offset:
    .byte $00, $F0, $E0, $D0, $C0, $B0, $A0, $90, $80, $70, $60, $50, $40, $30, $20, $10

; Vertical high byte, per screen
vertical_tile_memory_hi_offset:
    .byte Tile_MemH+$0, Tile_MemH+$0, Tile_MemH+$1, Tile_MemH+$2
    .byte Tile_MemH+$3, Tile_MemH+$4, Tile_MemH+$5, Tile_MemH+$6
    .byte Tile_MemH+$7, Tile_MemH+$8, Tile_MemH+$9, Tile_MemH+$A
    .byte Tile_MemH+$B, Tile_MemH+$C, Tile_MemH+$D, Tile_MemH+$E


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; player_get_tile_vertical
;
; Gets tile in vertical level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
player_get_tile_vertical:    ; $9E3C

; _temp_y_hi_w_offset, _temp_y_w_offset -- Y Hi, Y Lo
; _temp_x_with_hi_offset, _temp_x_with_offset -- X Hi, YLo

    LDA _temp_y_hi_w_offset
    PHA                     ; save it for later
    TAY

    LDA _temp_y_w_offset
    PHA                     ; save it for later

    JSR get_corrected_vertical_y_values
    STA _temp_y_w_offset

    ; Select root offset into tile memory
    LDA vertical_tile_memory_lo_offset, y
    STA tile_address
    LDA vertical_tile_memory_hi_offset, y
    STA tile_address+1

; Combine positions into _temp_x_with_hi_offset to form tile mem offset
    LDA _temp_y_w_offset
    AND #$f0
    STA _temp_x_with_hi_offset
    LDA _temp_x_with_offset
    LSR A
    LSR A
    LSR A
    LSR A
    ORA _temp_x_with_hi_offset

    TAY      ; Offset -> 'Y'

    PLA      ; Restore original value for _temp_y_w_offset
    STA _temp_y_w_offset
    PLA      ; Restore original value for _temp_y_hi_w_offset
    STA _temp_y_hi_w_offset

    LDA (tile_address), y   ; Get tile
    STA temp_tile  ; Store into temp_tile

    RTS      ; Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; player_get_tile_and_slope
;
; Get tile and slope for given position and offset
; for non-vertical ("normal") levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tile_Mem_Addr:
;    ; This breaks up the overall "tile" layout memory into screen-based chunks
;    ; With a screen width of 256 pixels, that makes 16 blocks across every "screen",
;    ; NTSC res of 224, two screens tall, is 448 / 16px-per-tile = 28 POTENTIAL rows per screen
;    ; but the status bar occludes one, so only 27 rows are stored...
;    ; Up to 15 screens!
;    .word Tile_Mem,       Tile_Mem+$01B0, Tile_Mem+$0360, Tile_Mem+$0510, Tile_Mem+$06C0, Tile_Mem+$0870, Tile_Mem+$0A20, Tile_Mem+$0BD0
;    .word Tile_Mem+$0D80, Tile_Mem+$0F30, Tile_Mem+$10E0, Tile_Mem+$1290, Tile_Mem+$1440, Tile_Mem+$15F0, Tile_Mem+$17A0

player_get_tile_and_slope:  ; $9E9D

    ; Clear slope array
    LDA #$00
    STA player_slope

    LDA _temp_x_with_offset
    LSR A
    LSR A
    LSR A
    LSR A
    STA tile_memory_offset   ; current column player is in

    LDA _temp_x_with_hi_offset
    AND #$0f
    ASL A                   ; we are searching for words
    TAX

; Set x to appropriate screen based on player's position
    LDA Tile_Mem_Addr,X
    STA tile_address
    LDA Tile_Mem_Addr+1,X
    STA tile_address+1

    LDA _temp_y_hi_w_offset
    BEQ +                   ; if _temp_y_hi_w_offset (Y Hi) = 0, jump to +
    INC tile_address+1 ; Otherwise, go to second half of screen

+
    LDA _temp_y_w_offset
    AND #$f0
    ORA tile_memory_offset   ; y in hi 4 bits, x in lo 4 bits

; tile_memory_offset is now Player's current offset in Tile Mem from the selected pointer
_tile_memory_offset_lo = Temp_Var12

    STA _tile_memory_offset_lo      ; ... and copied into _tile_memory_offset_lo

    TAY
    LDA (tile_address), y           ; get the tile!
    STA temp_tile

    LDY tileset_alt
    CPY #3
    BEQ +  ; if tileset_alt = 3 (Hills style), jump to +
    CPY #14
    BNE +no_slopes  ; if tileset_alt <> 14 (Underground), jump to +no_slopes

+
    LDA temp_tile
    if_semi_solid           ; custom macro for determining if something is solid
    BLT +no_slopes              ; if air jump

; Get slopes
    TYA
    ASL A
    TAX      ; x = tile quadrant << 1

_Level_SlopeQuadXX = Temp_Var3
    LDA Level_SlopeSetByQuad, x
    STA _Level_SlopeQuadXX
    LDA Level_SlopeSetByQuad+1, x
    STA _Level_SlopeQuadXX+1

    LDA temp_tile
    SEC
    SBC Tile_AttrTable, y    ; Subtract the root tile value
    TAY

    LDA (_Level_SlopeQuadXX), y     ; _Level_SlopeQuadXX[temp_tile - Tile_AttrTable[tile_quad]]
    STA player_slope                ; store into player_slope

+no_slopes:
    LDA temp_tile   ; A = Level_Tile (the tile retrieved)
    RTS


; This is basically a lookup for any given "Player Y Hi" shifted up 4 bits
shifted_hi_y_lookup:
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0

; Translates the Player position into appropriate "high" value
; as Vertical describes it ($0(00), $0(F0), $1(E0), ...)
get_corrected_vertical_y_values:
; Y = player_yHi
; A = player_y

    CPY #$00
    BLS +return     ; if player is under the level return

    CLC
    ADC shifted_hi_y_lookup, y   ; player_y += player_yHi[Y]
    BCS ++          ; If carry set jump

    CMP #$f0
    BLT +return     ; if result is < $F0, return

++
; Add $10 and roll over 'Y' (Considered in the lower vertical half)
    CLC
    ADC #$10
    INY

+return
    RTS      ; Return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PSwitch_SubstTileAndAttr
;
; P-Switch substitution function for tiles which it effects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Parallel arrays which for a given tile in the accumulator,
    ; if it matches one of the ones in p_tile_to_check is replaced
    ; with the attribute and tile from the other arrays...
p_tile_to_check:     .byte TILEA_COIN,   TILEA_BRICK,    TILEA_MUNCHER,  TILEA_PSWITCHCOIN   ; P-Switch inactive
p_tile_alt:    .byte TILEA_BRICK,  TILEA_COIN,     TILEA_COIN,     TILEA_COIN          ; P-Switch active
p_tile_alt_attribute:    .byte $03,          $00,            $00,            $00

PSwitch_SubstTileAndAttr:
    LDY Level_PSwitchCnt    ; Y = Level_PSwitchCnt
    BEQ +     ; If P-Switch not active, jump to + (RTS)

    LDY #p_tile_alt - p_tile_to_check - 1
-
    CMP p_tile_to_check,Y
    BNE ++     ; If this is not a match, jump to ++

    LDA p_tile_alt_attribute,Y   ; Get replacement attribute
    STA Player_Slopes  ; Store into Player_Slopes

    LDA p_tile_alt,Y   ; Get replacement tile
    RTS      ; Return

++
    DEY      ; Y--
    BPL -  ; While Y >= 0, loop!

+
    RTS      ; Return


    ; This defines 4 values per Level_Tileset, with each of those values
    ; belonging to a tile "quadrant" (i.e. tiles beginning at $00, $40,
    ; $80, and $C0), and defines the beginning tile which should be
    ; classified as "underwater" (Minimum Tile Under Water By Quad)
    ; A value of $FF is used to indicate that no tile in that quadrant
    ; is underwater (and for the first three quads is unreachable!)
water_by_quad_by_tileset:
    ; 4 values per Level_TilesetIdx, which is basically (Level_Tileset - 1)
    ; Listing by valid Level_Tileset values for consistency...
    .byte $FF, $FF, $FF, $DA    ;  1 Plains style
    .byte $FF, $FF, $FF, $DA    ;  2 Mini Fortress style
    .byte $FF, $FF, $FF, $C1    ;  3 Hills style
    .byte $FF, $FF, $FF, $DA    ;  4 High-Up style
    .byte $FF, $FF, $FF, $DA    ;  5 pipe world plant infestation
    .byte $02, $3F, $8A, $C0    ;  6 water world
    .byte $FF, $FF, $FF, $DA    ;  7 Toad House
    .byte $FF, $FF, $8A, $DA    ;  8 Vertical pipe maze
    .byte $FF, $FF, $FF, $DA    ;  9 desert levels
    .byte $FF, $FF, $FF, $DA    ; 10 Airship
    .byte $FF, $FF, $FF, $DA    ; 11 Giant World
    .byte $FF, $FF, $FF, $DA    ; 12 Ice level
    .byte $FF, $FF, $FF, $DA    ; 13 Sky level
    .byte $FF, $FF, $FF, $C1    ; 14 Underground


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Level_CheckIfTileUnderwater
;
; This checks if the given tile in Temp_Var1/2 (depending on 'X')
; is "underwater", based on Temp_Var3 (Level_TilesetIdx << 2) and
; the tile's "quadrant", which index "water_by_quad_by_tileset"
;
; The result can be overridden if the proper bit in
; is_above_below_water is set, which will force the
; report to say underwater...
;
; CARRY: The "carry flag" will be set and the input tile not
; otherwise tested if the tile is in the "solid floor" region!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bit which must be set in FloatLevel_PlayerWaterStat to override
; system and assume that we're underwater no matter what tile detected
;
; $80 - check if beneath top of water
; $40 - check if beneath bottom of water
;
check_bottom_or_top_of_water:
    .byte $40, $80

Level_CheckIfTileUnderwater:
_head_block = Temp_Var1
_left_block = Temp_Var2
_tile_quad = Temp_Var3
_underwater_status = Temp_Var15
    ; X = 0 or 1 (going up or down)
    ; Determines if we check the head or bottom block

    LDY #$01
    STY _underwater_status  ; _underwater_status = 1 (Indicates underwater)

; UNDERWATER OVERRIDE (for "floating" levels that have fixed water at the bottom)
    LDA is_above_below_water
    AND check_bottom_or_top_of_water, x
    BNE +not_solid_or_water  ; If bit is set, jump to +not_solid_or_water

    LDA _head_block, x
    if_semi_solid
    BGE +return             ; if tile is solid floor, return

    CMP #TILEA_PSWITCH_PRESSED
    BNE +eligable_for_underwater  ; if not pressed P-Switch, jump

    LDY #$00     ; Y = 0
    BEQ +store_water_status  ; we are not underwater

+eligable_for_underwater
; _tile_quad is (Level_TilesetIdx << 2), which is OR'ed into 'Y' here
; So the value is expected to be in the range of 0 to (4 * 15) = 60
; Basically there are 4 values per tileset, one for each tile quadrant
    TYA
    ORA _tile_quad
    TAY

; Get the minimum tile value for this quadrant which is considered
; underwater (NOTE: If there are no underwater tiles in this quadrant,
; the mostly unreachable value of $FF is what we get here)
    LDA water_by_quad_by_tileset, y
    LDY #$00

    CMP _head_block, x   ; Note: this is inconsistent with the way Nintendo typically does these cmps...  They accumulator and tile are swapped in this instance, so BPL = BGE and vises versus
    BGE +store_water_status  ; if not water

; Underwater
    INY

; Check if we are in a waterfall
    LDA _head_block, x
    CMP #TILE1_WFALLTOP
    BEQ +in_a_waterfall
    CMP #TILE1_WFALLMID
    BNE +store_water_status

+in_a_waterfall:
    INY      ; Y = 2 (In waterfall)

+store_water_status
; 0 = Not under water, 1 = Underwater, 2 = Waterfall
    STY _underwater_status  ; Store Y -> _underwater_status (0, 1, or 2)

+not_solid_or_water:
    CLC      ; Clear carry (tile was not in the solid floor region)

+return:
    RTS      ; Return


; When Player hits water, splash!
make_water_splash:
_y_offset = Temp_Var1
    LDA player_sprite_y
    CMP #$b8
    BGE +return  ; If sprite Y >= $B8, return

    LDA player_splash_disable
    BNE +spash_disabled  ; If player_splash_disable > 0 , jump

    STA _y_offset   ; Temp_Var1 = 0

    LDA active_powerup
    BEQ +small_offset  ; If Player is small, jump to +small_offset
    LDA Player_IsDucking
    BEQ +big_offset  ; If Player is not ducking, jump to +big_offset

+small_offset:
; Player is small or ducking
    LDA #10
    STA _y_offset   ; Temp_Var1 = 10

+big_offset:
    LDA #$01
    STA splash_counter   ; splash_counter = 1 (begin splash)

    LSR A
    STA splash_y_flag     ; splash_y_flag = 0 (splash Y is relative to screen scroll)

    LDA horizontal_scroll_settings
    BEQ +               ; if no auto scroll effects are occurring, jump to +

; Auto scroll effect active...
    LDA player_sprite_y
    CMP #136
    BLT +               ; if player_sprite_y < 136, jump to +

    LDA #147
    STA splash_y_flag    ; splash_y_flag = 147 (splash Y is not relative to screen scroll, appropriate for fixed water at bottom)

    BNE ++              ; jump

+
    LDA player_y
    CLC
    ADC _y_offset  ; Y offset
    AND #$F0    ; align to grid
    CLC
    ADC #$02    ; +2

++
    STA splash_y_pos     ; 147 or above formula -> splash_y_pos

    LDA player_x
    STA splash_x_pos     ; splash_x_pos = player_x

+spash_disabled:
    LDA player_y_vel
    BMI +return  ; if player going up return

    LDA #$00
    STA player_y_vel    ; stop vertical movement

    LDY in_air
    BEQ +make_bubbles

    STA player_x_vel    ; stop horizontal speed if we are landing into water

+make_bubbles

; When Player hits water, a bubble is made
    LDY #$02

-
    LDA bubbles_count, y
    BEQ +make_bubble    ; if this bubble slot is free, jump to +make_bubble

bubble_or_splash_loop:
    DEY
    BPL -               ; while Y >= 0, loop!

+return:
    RTS

    ; Y offsets
splash_bubble_y_offset:  .byte 16, 22, 19

    ; X offsets
splash_bubble_x_offset:  .byte  0,  4, 11

+make_bubble:
    LDA cur_random, y       ; Get random number
    ORA #$10
    STA bubbles_count, y    ; Store into bubble counter

    ; Set Bubble Y
    LDA player_y
    ADC splash_bubble_y_offset, y
    STA bubble_y, y
    LDA player_yHi
    ADC #$00
    STA bubble_y_hi, y

    ; Set Bubble X
    LDA player_x
    ADC splash_bubble_x_offset, y
    STA bubble_x, y
    LDA player_x_hi
    ADC #$00
    STA bubble_x_hi, y

    JMP bubble_or_splash_loop  ; Jump to bubble_or_splash_loop
