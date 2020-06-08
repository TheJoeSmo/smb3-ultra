Tile_Attributes_TS0:
    ; These are defining base ranges to check if a tile is "enterable" on the map
    ; Essentially, for a given "range" of tile on the map ($00, $40, $80, $C0),
    ; the corresponding value is indexed (take the previous value >> 6) and returns
    ; a "quick failure", i.e. "You're standing on a tile in [that range] and it
    ; has a value less than [retrieved from below]; you can't possibly enter it!"

    ; NOTE: The pool and star are both "enterable"...
    .byte TILE_PANEL1, TILE_FORT, TILE_POOL, TILE_WORLD5STAR

    ; These values (equivalent to above) also pulled in via tileset_alt_LUT??
    .byte TILE_PANEL1, TILE_FORT, TILE_POOL, TILE_WORLD5STAR

    .byte $20, $0E, $A4, $4C, $B7, $97



Map_Tile_ColorSets:
    .byte $00, $01, $00, $03, $04, $05, $06, $07, $02

Map_Object_ColorSets:
    .byte $08, $08, $08, $08, $08, $08, $08, $09, $08

reversed_bit_array:
    .byte $80, $40, $20, $10, $08, $04, $02, $01

world_replacable_blocks:
    .byte TILE_ROCKBREAKH, TILE_ROCKBREAKV, TILE_LOCKVERT, TILE_FORT, TILE_ALTFORT, TILE_ALTLOCK, TILE_LOCKHORZ, TILE_RIVERVERT
world_replaceable_blocks_end: ; marker to calculate size -- allows user expansion of world_replacable_blocks

world_replacable_block_to:
    ; These specify tiles that coorespond to the tile placed when the above is removed
    ; (NOTE: First two are for rock; see also PRG026 RockBreak_Replace)
    ; NOTE: Must have as many elements as world_replacable_blocks!
    .byte TILE_HORZPATH, TILE_VERTPATH, TILE_VERTPATH, TILE_FORTRUBBLE, TILE_ALTRUBBLE, TILE_HORZPATHSKY, TILE_HORZPATH, TILE_BRIDGE

world_completable_tiles:
    ; These tiles are simply marked with the M/L
    ; NOTE: The Dancing Flower is a "completable tile"...
    .byte TILE_TOADHOUSE, TILE_SPADEBONUS, TILE_HANDTRAP, TILE_DANCINGFLOWER, TILE_ALTTOADHOUSE
world_completable_tiles_end: ; marker to calculate size -- allows user expansion of world_completable_tiles

world_player_completed_tiles:
    .byte TILE_MARIOCOMP_P, TILE_LUIGICOMP_P, TILE_MARIOCOMP_O, TILE_LUIGICOMP_O
    .byte TILE_MARIOCOMP_G, TILE_LUIGICOMP_G, TILE_MARIOCOMP_R, TILE_LUIGICOMP_R

world_bottom_boarder_by_world:
    ; This defines which tile covers the bottom horizontal border, per world
    .byte TILE_BORDER1, TILE_BORDER1, TILE_BORDER1, TILE_BORDER1, TILE_BORDER2
    .byte TILE_BORDER1, TILE_BORDER1, TILE_BORDER3, TILE_BORDER1

Tile_Mem_Clear:
clear_world_blocks:
    ; The following loop clears all of the tile memory space to $02 (an all-black tile)
    LDY #$00
-
    LDA #$02    ; Black default tiles
    JSR Tile_Mem_ClearB
    JSR Tile_Mem_ClearA ; Clear all the tiles
    CPY #$f0
    BNE -
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Map_Reload_with_Completions
;
; This very important subroutine actually loads in the map layout
; data and sets level panels which have been previously completed
; to their proper state (e.g. M/L for level panels, crumbled fort)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Map_Reload_with_Completions:
    JSR clear_world_blocks

world_default = $02
world_top_boarder = $4E
world_top_left_start = $30
world_data_pointer = Temp_Var1
_temp_screen_width = Temp_Var3
    ; Fill 16x tile $4E every $1B0 (upper horizontal border)
    LDA #world_top_left_start
    STA _temp_screen_width
    TAY
-
    LDA _temp_screen_width

;for i, screen in enumerate(screens):
;   screen[0xC0 + i] = blank_block
;
    LDA #world_default
    JSR Tile_Mem_ClearB

;Go down one row 
    LDA #$10
    CLC
    ADC _temp_screen_width
    TAY
    LDA #world_top_boarder
    JSR Tile_Mem_ClearB

    INC _temp_screen_width
    LDY _temp_screen_width
    CPY #$40
    BNE -

; Get the block offset + #$110
    ADD_WORD_BIG_TO_VAR horizontal_horizontal_block_offset, horizontal_horizontal_block_offset+1, tile_address, tile_address+1, #$0110

; FIXME: Change how world layouts are loaded
; Temp_Var1/2 will form an address pointing at the beginning of this world's map tile layout...
    LDA world_idx
    ASL A
    TAY      ; Y = world_idx << 1 (index into Map_Tile_Layouts)
    LDA Map_Tile_Layouts, y
    STA world_data_pointer
    LDA Map_Tile_Layouts+1, y
    STA world_data_pointer+1

; This loop loads the layout data into the Tile_Mem
; Note that it COULD terminate early via an $FF
; at any time, but this is never used...
-
    LDY #$00
--
    LDA (world_data_pointer), y       ; get block data
    CMP #$FF
    BEQ +break
    STA (tile_address), y              ; store to level memory
    INY

; 144 supports a 16x9 map screen (the left and right columns
; each contain a normally invisible-until-scrolled tile)
    CPY #144
    BNE --

    TYA
    ADD_WORD world_data_pointer, world_data_pointer+1 ; Add index (y) to pointer
    ADD_WORD_BIG tile_address, tile_address+1, #$01B0 ; Add offset to get to the next screen
    BNE -

; Data is loaded!
+break
    world_bottom_left_start = $E0

    LDY #world_bottom_left_start
    LDX world_idx
    LDA world_bottom_boarder_by_world, x        ; get bottom row for each world
-
    JSR Tile_Mem_ClearB
    INY
    CPY #$F0                                    ; do $10 times
    BNE -

; TODO: Fix palettes to be better editable
    LDA world_idx
    TAY
    LDA Map_Tile_ColorSets, y
    STA PalSel_Tile_Colors      ; Store which colors to use on map tiles
    LDA Map_Object_ColorSets, y
    STA PalSel_Obj_Colors       ; Store which colors to use on map objects


get_completion_tiles:
_completion_byte = Temp_Var1
_completion_bit = Temp_Var2
_screen_to_block_memory_offset = Temp_Var3
_world_mario_block_attr = Temp_Var4
_world_mario_block_offset = Temp_Var5

    LDY #$00
    STY _completion_byte  ; Temp_Var1 = $00 (current completion column we're checking)

world_check_completion_byte:
    LDA #$80
    STA _completion_bit  ; Temp_Var2 = $80 (current completion bit/row we're checking)

world_check_completion_bit:
    LDY _completion_byte
    LDA world_stored, y         ; world_stored[idx // 8] & _completion_bit >> idx % 8
    AND _completion_bit
    BNE +
    JMP world_do_not_store_new_block_to_block_memory

; Row completion on specified bit
+ 
    TYA
    AND #b00110000
    LSR A
    LSR A
    LSR A
    TAX     ; 0000 0110

    ; Get the correct screen + 1 block
    LDA horizontal_horizontal_block_offset, x
    STA tile_address
    LDA horizontal_horizontal_block_offset+1, x
    STA tile_address+1
    INC tile_address+1

    ; The following loop determines what "index" corresponds to this completion bit
    ; that we're working with (only one!)
    LDX #$07
-
    LDA _completion_bit      ; Current complete bit
    CMP reversed_bit_array, x
    BEQ +
    DEX
    BNE -

+
    TXA
    ASL A
    ASL A
    ASL A
    ASL A
    CLC
    ADC #$10        ; Thus: 16, 32, 48, 64, 80, 96, 112, 144; each row is another 16 bytes!
    STA _screen_to_block_memory_offset

    TYA
    AND #$0F        ; Get the x position of where we are relative to our screen
    ORA _screen_to_block_memory_offset      ; screen + screen offset
    TAY

_PRG012_A524:
    LDA (tile_address), y                   ; get correct block

    STY _world_mario_block_offset
    STA world_mario_block

    ; Get tile quadrant -> 'X'
    AND #$C0
    CLC
    ROL A
    ROL A
    ROL A
    TAX

    ; Check if this tile is one of the completable event tiles
    ; $50 = Toad house  $E8 = Spade panel  $E6 = Hand trap (works anywhere!)  $BD = Enterable flower??  $E0 = Red Toad House
    LDY #world_completable_tiles_end-world_completable_tiles-1
    LDA world_mario_block
-
    CMP world_completable_tiles, y
    BEQ +flippable_block        ; if block match, jump
    DEY
    BPL -

; Tile didn't match, loop finished...
    CMP #TILE_FORT
    BEQ +fort_block
    CMP #TILE_ALTFORT
    BEQ +fort_block

    CMP Tile_Attributes_TS0, x
    BGE +flippable_block    ; If this tile is a completable tile, jump

+fort_block:
    LDX #world_replaceable_blocks_end-world_replacable_blocks-1
-
    CMP world_replacable_blocks, x
    BEQ +
    DEX
    BPL -
    BMI ++                                  ; if matched nothing, jump

+
    LDA world_replacable_block_to, x        ; get the replacement tile
    JMP world_store_new_block_to_block_memory

++
    LDA _completion_bit
    CMP #$01
    BNE world_do_not_store_new_block_to_block_memory  ; If Temp_Var2 (current completion bit) <> 1, jump to world_do_not_store_new_block_to_block_memory

; Completion bit 1 appears one row lower than the other adjacent bits
    LDY _world_mario_block_offset
    CPY #$90
    BGE world_do_not_store_new_block_to_block_memory
    TYA
    CLC
    ADC #16
    TAY

    JMP _PRG012_A524

; Just about any "flippable" tile goes here, produces M/L
+flippable_block:
    TXA             ; Block attributes << 1
    ASL A
    STA _world_mario_block_attr

    LDA _completion_byte
    AND #$40
    BEQ +  ; If this is completion bit 6, jump to +

    INC _world_mario_block_attr         ; if completion_byte & 0b0100_0000 then attr++;
+
    LDX _world_mario_block_attr         ; X = (tile quadrant * 2) + 0/1

    LDA world_player_completed_tiles, x     ; Get proper completion tile

world_store_new_block_to_block_memory:
    LDY _world_mario_block_offset
    STA (tile_address), y               ; set proper completion tile!

world_do_not_store_new_block_to_block_memory:
    LSR _completion_bit
    BEQ +
    JMP world_check_completion_bit      ; jump to world_check_completion_bit

+
; Get next completion byte
    INC _completion_byte
    LDA _completion_byte
    CMP #$80
    BEQ +rts    ; if Temp_Var1 = 80 (completed through all column bytes), jump
    JMP world_check_completion_byte     ; otherwise, jump back around again...

+rts
    RTS

Map_Tile_Layouts:
    ; This points to the layout data for each world's map tile layout
    .word W1_Map_Layout, W2_Map_Layout, W3_Map_Layout, W4_Map_Layout, W5_Map_Layout
    .word W6_Map_Layout, W7_Map_Layout, W8_Map_Layout, W9_Map_Layout


    ; Each world's layout; very simple data, specifies a linear list of tile bytes.
    ; Every 144 bytes form a 16x9 single screen of world map.
    ; The stream is terminated by $FF
W1_Map_Layout:  .include "PRG/maps/World1L.asm"
W2_Map_Layout:  .include "PRG/maps/World2L.asm"
W3_Map_Layout:  .include "PRG/maps/World3L.asm"
W4_Map_Layout:  .include "PRG/maps/World4L.asm"
W5_Map_Layout:  .include "PRG/maps/World5L.asm"
W6_Map_Layout:  .include "PRG/maps/World6L.asm"
W7_Map_Layout:  .include "PRG/maps/World7L.asm"
W8_Map_Layout:  .include "PRG/maps/World8L.asm"
W9_Map_Layout:  .include "PRG/maps/World9L.asm"

    ; Each of these has an entry PER WORLD (0-8, Worlds 1-9)

    ; This table specifies a lookup for the world that supplies an initial
    ; offset value for the following table based on the "XHi" position the
    ; Player was on the map.  Obviously for many worlds there is no valid
    ; offset value on some of the higher map screens...
world_horizontal_high:
    .word W1_InitIndex, W2_InitIndex, W3_InitIndex, W4_InitIndex, W5_InitIndex, W6_InitIndex, W7_InitIndex, W8_InitIndex, W9_InitIndex

    ; This table is initially indexed by the initial offset supplied by world_horizontal_high
    ; and provides a series of map row locations (upper 4 bits) and level tileset (lower 4 bits)
world_horizontal_lookup:
    .word W1_ByRowType, W2_ByRowType, W3_ByRowType, W4_ByRowType, W5_ByRowType, W6_ByRowType, W7_ByRowType, W8_ByRowType, W9_ByRowType

    ; This table just maps the column positions of enterable level tiles
world_vertical_lookup:
    .word W1_ByScrCol, W2_ByScrCol, W3_ByScrCol, W4_ByScrCol, W5_ByScrCol, W6_ByScrCol, W7_ByScrCol, W8_ByScrCol, W9_ByScrCol

    ; This table maps the relevant object layout pointers for the levels
world_obj_set:
    .word W1_ObjSets, W2_ObjSets, W3_ObjSets, W4_ObjSets, W5_ObjSets, W6_ObjSets, W7_ObjSets, W8_ObjSets, W9_ObjSets

    ; This tbale maps the relevant level layout pointers for the levels
world_level_pointer:
    .word W1_LevelLayout, W2_LevelLayout, W3_LevelLayout, W4_LevelLayout, W5_LevelLayout, W6_LevelLayout, W7_LevelLayout, W8_LevelLayout, W9_LevelLayout

    ; "Structure" data files -- contains data that links levels to
    ; their layout and objects by the rows and columns
    .include "PRG/maps/World1S.asm"
    .include "PRG/maps/World2S.asm"
    .include "PRG/maps/World3S.asm"
    .include "PRG/maps/World4S.asm"
    .include "PRG/maps/World5S.asm"
    .include "PRG/maps/World6S.asm"
    .include "PRG/maps/World7S.asm"
    .include "PRG/maps/World8S.asm"
    .include "PRG/maps/World9S.asm"

; FIXME: Anybody want to claim this? Is this part of the above?
; $B0F3
    .byte $4A, $44, $47, $48, $AE, $AF, $B5, $B6, $DE, $D9, $DC, $DD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Map_PrepareLevel
;
; Based on what spot of the map you entered, figure out which "level"
; you're entering ("level" means any enterable spot on the map including
; bonus games, etc.)
;
; The ultimate output is properly configured
; Level_ObjPtr_AddrL/H and Level_ObjPtrOrig_AddrL/H (object list pointer)
; Level_LayPtr_AddrL/H and Level_LayPtrOrig_AddrL/H (tile layout pointer)
; tileset_alt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
world_init:
Map_PrepareLevel:
    LDX cur_player  ; X = cur_player
    LDA falling_to_king_flag, x ; A = falling_to_king_flag
    BEQ +     ; If falling_to_king_flag = 0 (not falling into king's room), jump to +
    JMP world_do_king_room     ; Otherwise, jump to world_do_king_room

+
_horizontal_lookup = Temp_Var1
_horizontal_hi_lookup = Temp_Var9
_vertical_lookup = Temp_Var3
_pointer_obj_set = Temp_Var5
_pointer_level_pointer = Temp_Var7
_page_change = Temp_Var15

    LDA world_idx
    ASL A
    TAY         ; Y = world_idx << 1 (2 bytes per world)

; TODO; TODO; TODO; FIXME; Edit this bit
; Get a pointer for the int16 positions of enterable levels
    LDA world_horizontal_lookup, y
    STA _horizontal_lookup
    LDA world_horizontal_lookup+1, y
    STA _horizontal_lookup+1
    LDA world_vertical_lookup, y
    STA _vertical_lookup
    LDA world_vertical_lookup+1, y
    STA _vertical_lookup+1

    ; Temp_Var6/5 form an address to world_obj_set
    LDA world_obj_set, y
    STA _pointer_obj_set
    LDA world_obj_set+1, y
    STA _pointer_obj_set+1

    ; Temp_Var8/7 form an address to world_level_pointer
    LDA world_level_pointer, y
    STA _pointer_level_pointer
    LDA world_level_pointer+1, y
    STA _pointer_level_pointer+1

    ; Temp_Var10/9 form an address to world_horizontal_high
    LDA world_horizontal_high, y
    STA _horizontal_hi_lookup
    LDA world_horizontal_high+1, y
    STA _horizontal_hi_lookup+1


    LDX cur_player
    LDY world_x_hi, x
    LDA (_horizontal_hi_lookup), y
    TAY     ; y = index to provide correct offset for corresponding x hi positions

    LDA #$00
    STA _page_change

    LDX cur_player
; Loops through each index that corresponds to the y position until it is equal
-
    LDA (_horizontal_lookup), y
    AND #$F0            ; Get the block, not pixel
    CMP world_y_lo, x   ; If player y == row, jump
    BEQ +
    INY                 ; Else go to index in the screen
    BNE -

; Didn't find any matching position!
    INC _horizontal_lookup+1            ; Move to the next page
    INC _page_change                    ; We had to move another page
    BEQ -

; Found a match
+
; Add the corresponding hi value to the vertical lookup 
    LDA _vertical_lookup+1
    CLC
    ADC _page_change
    STA _vertical_lookup+1

    LDA #$00
    STA _page_change

_player_x_pos = Temp_Var9
    LDA world_x_lo, x
    LSR A
    LSR A
    LSR A
    LSR A
    STA _corrected_x_pos
    LDA world_x_hi, x
    ASL A
    ASL A
    ASL A
    ASL A
    ORA _corrected_x_pos

-
    CMP (_vertical_lookup), y   ; See if this position matches
    BEQ +
    INY
    BNE -

    INC _vertical_lookup+1  ; Go up another page
    INC _page_change
    BEQ -

+
; Correct horizontal lookup to give us the correct address!
    LDA _horizontal_lookup+1
    CLC
    ADC _page_change
    STA _horizontal_lookup+1

; World 9 Hijack
    LDA world_idx
    CMP #$08
    BNE +

    LDA (_horizontal_lookup), y
    AND #$0F

    STA world_to_warp
    RTS 

+
    LDA (_horizontal_lookup), y
    AND #$0F
    STA tileset_alt

; Add the page change (if any) to Temp_Var6 (applies same page change here)
    LDA _pointer_obj_set+1
    CLC
    ADC _page_change
    STA _pointer_obj_set+1

    TYA
    TAX      ; X = Y (our sought after offset)
    ASL A
    TAY      ; Y <<= 1
    LDA _pointer_obj_set
    ADC #$00
    STA _pointer_obj_set

    LDA (_pointer_obj_set), y
    STA level_object_pointer
    STA level_object_pointer
    INY
    LDA (_pointer_obj_set), y
    STA level_object_pointer+1
    STA level_object_pointer+1

    ; Add the page change (if any) to Temp_Var6 (applies same page change here)
    LDA _pointer_level_pointer+1
    CLC
    ADC _page_change
    STA _pointer_level_pointer+1
    TXA
    ASL A
    TAY      ; Y = X (the backed up index) << 1
    LDA _pointer_level_pointer+1
    ADC #$00
    STA _pointer_level_pointer+1

    STY Temp_Var16      ; Keep index in Temp_Var16

    ; Store address of object set into Level_LayPtr_AddrL/H and Level_LayPtrOrig_AddrL/H
    LDA (_pointer_level_pointer), y
    STA tile_layout_address
    STA level_generator_address
    INY
    LDA (_pointer_level_pointer), y
    STA tile_layout_address+1
    STA level_generator_address+1

    LDA world_custom_enter
    BNE do_world_custom_enter

; Regular level, no silly business
    LDA tileset_alt
    CMP #15
    BNE +  ; If tileset_alt <> 15 (Bonus Game intro), jump to +

    JMP world_do_bonus_game  ; Otherwise, jump to world_do_bonus_game

+
    LDA #$03
    STA World_EnterState
    RTS      ; We are entering a level!


do_world_custom_enter:
    ; Most "entry" on the world map uses your map position to pick out a
    ; pointer to a level.  Simple stuff.

    ; But certain things like the airship, coin ship, white toad house, etc.
    ; must "override" the map placement to go to something specific; that's
    ; where Map_EnterViaID comes in; if set to a value, it jumps to a
    ; PARTICULAR place regardless of map placement.

    ; Not all map objects go anywhere special though...

    JSR DynJump

    ; THESE MUST FOLLOW DynJump FOR THE DYNAMIC JUMP TO WORK!!
    .word world_do_nothing      ; 0: (Not used, normal panel entry)
    .word world_do_nothing      ; 1: HELP (can't be "entered")
    .word world_do_airship      ; 2: Airship
    .word world_do_nothing      ; 3: Hammer Bro battle
    .word world_do_nothing      ; 4: Boomerang Bro battle
    .word world_do_nothing      ; 5: Heavy Bro battle
    .word world_do_nothing      ; 6: Fire Bro battle
    .word world_do_nothing      ; 7: World 7 Plant
    .word world_do_nothing      ; 8: Unknown marching glitch object
    .word world_do_n_spaade     ; 9: N-Spade game
    .word world_do_white_toad_house     ; 10: Anchor/P-Wing house
    .word MO_CoinShip           ; 11: Coin ship
    .word world_do_nothing      ; 12: Unknown white colorization of World 8 Airship
    .word world_do_nothing      ; 13: World 8 Battleship
    .word world_do_nothing      ; 14: World 8 Tank
    .word world_do_nothing      ; 15: World 8 Airship
    .word world_do_nothing      ; 16: Canoe (can't be "entered")

king_rooms_per_world:
    .word KNG1L ; World 1
    .word KNG2L ; World 2
    .word KNG3L ; World 3
    .word KNG4L ; World 4
    .word KNG5L ; World 5
    .word KNG6L ; World 6
    .word KNG7L ; World 7
    .word KNG1L ; World 8 (??)

king_room_objects:
    .word Empty_ObjLayout


world_do_king_room:
    LDA world_idx
    ASL A
    TAX

    LDA king_rooms_per_world, x
    STA tile_layout_address
    LDA king_rooms_per_world+1, x
    STA tile_layout_address+1

    LDA king_room_objects
    STA alt_level_object_pointer
    LDA king_room_objects+1
    STA alt_level_object_pointer+1

    LDA #$02
    STA tileset_alt

    RTS

    ; Airship jump addresses for the map object version
airship_generators:
    .word W1AirshipL
    .word W2AirshipL
    .word W3AirshipL
    .word W4AirshipL
    .word W5AirshipL
    .word W6AirshipL
    .word W7AirshipL
    .word W8AirshipL

Airship_Objects:
    .word W1AirshipO
    .word W2AirshipO
    .word W3AirshipO
    .word W4AirshipO
    .word W5AirshipO
    .word W6AirshipO
    .word W7AirshipO
    .word W8AirshipO


world_do_airship:
    LDA world_idx
    ASL A
    TAY

    LDA airship_generators, y
    STA tile_layout_address
    LDA airship_generators+1, y
    STA tile_layout_address+1
    LDA Airship_Objects, y
    STA alt_level_object_pointer
    LDA Airship_Objects+1, y
    STA alt_level_object_pointer+1

    LDA #10
    STA tileset_alt

world_do_nothing:
    RTS

; White Toad House layouts
world_white_toad_house_layout:
    .word TOAD_SpecL
    .word TOAD_SpecL
    .word TOAD_SpecL
    .word TOAD_SpecL
    .word TOAD_SpecL
    .word TOAD_SpecL
    .word TOAD_SpecL
    .word TOAD_SpecL

; White Toad House configuration
; NOTE: This is NOT actually an object layout pointer (which is always fixed in Toad Houses),
; this just defines what is in the lone chest in white Toad Houses (P-Wing / Anchor)
world_white_to_house_item:
    .word $0200
    .word $0A00
    .word $0200
    .word $0A00
    .word $0200
    .word $0A00
    .word $0200
    .word $0A00

world_do_white_toad_house:
    LDA world_idx
    ASL A
    TAY

    LDA world_white_toad_house_layout, y
    STA tile_layout_address
    LDA world_white_toad_house_layout+1, y
    STA tile_layout_address+1
    LDA world_white_to_house_item, y
    STA alt_level_object_pointer
    LDA world_white_to_house_item+1, y
    STA alt_level_object_pointer+1

    LDA #$07
    STA tileset_alt

    RTS

    ; Possibly thinking of having per-world coin ships?
coinship_generators:
    .word CoinShipL
    .word CoinShipL
    .word CoinShipL
    .word CoinShipL
    .word CoinShipL
    .word CoinShipL
    .word CoinShipL
    .word CoinShipL

coinship_objects:
    .word CoinShipO
    .word CoinShipO
    .word CoinShipO
    .word CoinShipO
    .word CoinShipO
    .word CoinShipO
    .word CoinShipO
    .word CoinShipO

MO_CoinShip:
    LDA world_idx
    ASL A
    TAY

    LDA coinship_generators, y
    STA tile_layout_address
    LDA coinship_generators+1, y
    STA tile_layout_address+1
    LDA coinship_objects, y
    STA alt_level_object_pointer
    LDA coinship_objects+1, y
    STA alt_level_object_pointer+1

    LDA #10
    STA tileset_alt

    RTS

world_do_bonus_game:
    ; Level_Tileset = 15 (Bonus Game intro!)
    LDY cur_player
    LDA world_y_lo, y
    STA world_last_y, y
    LDA world_x_hi, y
    STA world_last_x_hi, y
    LDA world_x_lo, y
    STA world_last_x_lo, y

    LDA #15
    STA tileset_alt

    LDY Temp_Var16      ; Index of level entered

    ; Set Bonus_GameType (always 1 in actual game)
    LDA (_pointer_obj_set), y
    STA Bonus_GameType

    ; Set Bonus_KTPrize (always irrelevant in actual game)
    LDA (Temp_Var7),Y
    STA Bonus_KTPrize

    INY      ; Y++

; Set Bonus_GameHost (always 0 in actual game)
    LDA (_pointer_obj_set), y
    STA Bonus_GameHost
    LDA (_pointer_level_pointer), y
    ASL A
    TAY
    BEQ +
    BNE +
    
world_do_n_spaade:
    ; Level_Tileset = 15 (Bonus game intro)
    LDA #15
    STA tileset_alt

    LDA #$02 ; Bonus_GameType = 2 (N-Spade)
    STA bonus_game_to_play

    LDY #$00
    STY bonus_game_host     ; atandard Toad Host

+
    ; Bonus game layout
    LDA Bonus_LayoutData, y
    STA tile_layout_address
    LDA Bonus_LayoutData+1, y
    STA tile_layout_address+1

    LDA #$03
    STA World_EnterState

    RTS