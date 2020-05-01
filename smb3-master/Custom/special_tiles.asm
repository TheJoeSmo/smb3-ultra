;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; handle_special_tiles
; 
; Updated by Joe Smo
;
; Handles all unique logic for blocks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

handle_special_tiles:
    LDX #$00
    BEQ +

handle_special_specific_tiles:
    CPX #$04
    BEQ ++
    INX
+
; loads the correct address to jump to for a given tile
    LDY head_block, x
    LDA spc_at_block_lo, y
    STA Temp_Var1
    LDA spc_at_block_hi, y
    STA Temp_Var1+1
    LDY #$00

; save return address to the stack
    LDA <handle_special_specific_tiles
    PHA
    LDA >handle_special_specific_tiles
    PHA
; effectively an indirect jsr
    JMP (Temp_Var1)
++
    RTS

; per tileset
spc_at_block_hi:
    import spc_at_block_hi.asm
spc_at_block_lo:
    import spc_at_block_lo.asm




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player_DoSpecialTiles
;
; Handles special tiles unique to level styles:
; Pipe logic, conveyors, spikes, muncher/jelectro, white block,
; quicksand, toad house treasure chests...
; Good place to put custom-by-Tileset tiles!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

player_x_offset_for_pipes:
    .byte $08, $04, $04 ; Offset applied to Player_X when: in air or level is sloped, Player is NOT small, Player is small

Pipe_enter_inputs:
    .byte PAD_RIGHT, PAD_LEFT   ; What to press to enter a horizontal pipe; pad right and left, respectively
    .byte PAD_DOWN, PAD_UP      ; What to press to enter a vertical pipe; pad down and up, respectively

    ; The sliding values applied when Player is touching a conveyor
Conveyor_slide:  .byte 16, -16

    .byte $01, $0F

    ; To check for damage caused by the fully extended piranha
    ; Note that they technically count touching their base pipes
    ; as a damage too!  Careful about that, eh?
Plant_infest_piranha_tiles: .byte TILE5_MUNCHER_2, TILE5_MUNCHER_1
Plant_infest_mini_pipes:  .byte TILE5_MINIPIPE_TOP2, TILE5_MINIPIPE_TOP1

Player_DoSpecialTiles:
; first we are going to determine if we need to enter a pipe
; the y value will determine what type of pipe we will enter, if any

    LDA is_statue
    ORA tail_swipe_counter
    ORA invis_summer_sault
    BNE PRG008_BCA7                     ; if any of the above jump

    LDY tileset
    LDA PipeTile_EnableByTileset, y     ; handles custom pipes
    STA pipes_by_tileset

    LDA in_air
    BNE PRG008_BCAA                     ; If Player is mid air, jump to PRG008_BCAA

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

-:
    JMP PRG008_BD4B  ; Jump to PRG008_BD4B

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

    JMP PRG008_BD4B  ; Otherwise, jump to PRG008_BD4B

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
    BCS PRG008_BD4B                 ; if not in range then we are not entering a pipe
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
    BEQ PRG008_BD4B                 ; if ~holding then jump (not entering a pipe)

; Time to enter a pipe
    LDA pipe_movement
    BNE PRG008_BD4B                 ; if in_pipe then don't enter another pipe

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
    BGE PRG008_BD4B     ; If Player_X >= 10 after subtracting 3 (??), jump to PRG008_BD4B (no pipe today)

    LDA Temp_Var1                   ; get pipe_type
    LSR A
    TAY
    JSR PipeEntryPrepare            ; prepare entry into pipe!
    JSR PipeMove_SetPlayerFrame     ; update Player frame!
    JSR Player_Draw29               ; draw Player
; Do not return to caller!!
    PLA
    PLA
    RTS

PRG008_BD4B:
; We are not entering a pipe ):

; Do conveyor tests
    LDY tileset

    LDA in_air
    BNE +                           ; if in air then jump (no conveyor)
    LDA pswitch_cnt
    BNE +                           ; if in air then jump (no conveyor)

; Eligable for conveyor logic
    LDX #$01     ; X = 1 (check one tile by foot, then check the other!)

- ;PRG008_BD59:
    LDA ConveyorEnable, y
    BEQ +                           ; if ~ConveyorEnable[tileset] then jump (no conveyor)

; We are doing the conveyor belt
    SEC
    SBC left_block, x               ; ConveyorEnable[tileset] - left_block (which tile we are on)
    CMP #$02
    BGE ++      ; if ConveyorEnable[tileset] - left_block >= 2 then jump to (no conveyor on this tile)

; Do conveyor action (we are on a conveyor)
    TAX
    LDA Conveyor_slide, x           ; conveyor speed == accumulator ? 16: -16 (probably could of just add the 7th bit but whatever)
    STA player_slide
    BNE +                           ; jump (since we do not need to do this twice)
++
    DEX
    BPL -                           ; do it one more time for the right block

+ ;PRG008_BD73:
; Spike logic
    LDX #$02     ; X = 2

- ;PRG008_BD75:
    LDA SpikesEnable, y
    CMP #$ff
    BEQ +                           ; if SpikesEnable[tileset] == 0xFF then jump (no spikes)

; Check for spikes
    SEC
    SBC head_block, x               ; either head_block, left_block, or right_block
    CMP #$02
    BLT ++                          ; if SpikesEnable[tileset] - tile < 2 then do spike tile

    DEX
    BPL -                           ; if x >= 0 then loop
    BMI +                           ; else not a spike tile

++ ;PRG008_BD89:

; We hit a spike tile
    LDA is_kuribo
    BEQ ++                          ; if !kuribo jump
    LDA hit_ceiling
    BEQ +                           ; if hit_ceiling (falling) then not a spike

++ ;PRG008_BD93:
; Hit spike
    JMP Get_hurt              ; hurt Player!!

+ ;PRG008_BD96:

; Do muncher/jelectro code
    LDX #$03     ; X = 3

PRG008_BD98:
    LDA left_block, x               ; check lower tiles and the upper and lower tile the player is in
    CMP MuncherJelectroSet, y
    BEQ +                           ; if tile == MuncherJelectroSet[tileset] then jump

    CMP #TILEA_MUNCHER              ; check if we are touching a muncher (again)
    BNE ++  ; If Player is NOT touching a muncher, jump to PRG008_BDB1
+ ;PRG008_BDA4:
    LDA is_kuribo
    BEQ +                           ; if !is_kuribo then jump

    LDA hit_ceiling
    BEQ +++                         ; if !hit_ceiling then jump

+ ;PRG008_BDAE:

; Got hit by the muncher/jelectro
    JMP Get_hurt   ; Get hurt!

++ ;PRG008_BDB1:
    DEX      ; X--
    BPL PRG008_BD98  ; While X >= 0, loop!

+++ ;PRG008_BDB4:
    LDA tileset
    CMP #$05
    BNE ++  ; if not in a pipe world plant infestation, jump to ++

; ALTERNATING PIRANHA HURT LOGIC IN INFESTATION LEVELS

    LDY #$00
    LDA PatTable_BankSel+1
    CMP #$60
    BEQ +  ; If current pattern table is $60, jump to PRG008_BDC9

    INY                             ; alt tile
    CMP #$3e
    BNE ++                 ; if current pattern table is NOT $3E, jump to ++

+ ;PRG008_BDC9:
    LDX #$02     ; X = 2

- ;PRG008_BDCB:
    LDA head_block, x
    PHA                             ; save for later

    SEC
    SBC Plant_infest_piranha_tiles, y
    CMP #$01
    PLA                             ; restore tile
    BLT +                           ; if you just hit the piranha that's fully extended, you get hurt!

    CMP Plant_infest_mini_pipes,Y
    BEQ +                           ; if you even just touched his base pipe, you get hurt!

    DEX
    BPL -                           ;while X >= 0, loop!

    JMP ++  ; Jump to ++

+ ;PRG008_BDE3:

    ; Gonna get hurt!
    LDA is_kuribo
    BNE ++  ; If Player is wearing Kuribo's shoe, jump to ++

    JSR Get_hurt   ; Get hurt!

++

; SLIPPERY, ICY GROUND LOGIC
    LDA #$00
    STA slippery_type  ; slippery_type = 0 (not slippery)

    LDA tileset
    CMP #11
    BNE +  ; If not in an ice level, jump to +

    LDA in_air
    BNE +  ; If Player is in air, jump to +

    LDX #$01     ; X = 1

-
    LDA left_block,X
    TAY      ; Tile -> 'Y'

    SEC
    SBC #TILE12_SNOWBLOCK_UL
    CMP #$03
    BLT ++  ; If Player is on top of snow block, jump to ++

    TYA      ; Restore tile -> 'A'
    SEC
    SBC #TILE12_GROUND_L
    CMP #$03
    BGE +++  ; If Player is not on bottom ground, jump to +++

++
    INC slippery_type  ; slippery_type = 1 (bottom ground is a little slippery!)
    JMP +     ; Jump to +

+++:
    TYA      ; Restore tile -> 'A'
    SEC
    SBC #TILE12_LARGEICEBLOCK_UL
    CMP #$05
    BLT PRG008_BE26  ; If Player is touching any of the small or large ice blocks, jump to PRG008_BE26

    CPY #TILE12_FROZENCOIN
    BEQ PRG008_BE26  ; If Player is touching frozen coin blocks, jump to PRG008_BE26

    CPY #TILE12_FROZENMUNCHER
    BNE PRG008_BE2E  ; If Player is NOT touching frozen muncher blocks, jump to PRG008_BE2E

PRG008_BE26:
    LDA #$02
    STA slippery_type  ; slippery_type = 2 (ground is REALLY slippery!)

    JMP +  ; Jump to +

PRG008_BE2E:
    DEX      ; X--
    BPL -  ; While X >= 0, loop!

+
    LDA tileset
    CMP #$00
    BNE ++      ; If Player is NOT in a Plains style skip white block check

    LDY #$01

-:
    LDA left_block,Y

    SEC
    SBC #TILE1_WBLOCKTH
    CMP #$03
    BLT +       ; If Player is on a big white block, jump to +

    DEY
    BPL -                           ; did not find a white block...

; Not on a white block or not holding down
-:
    LDA #$00
    STA white_block_cnt             ; reset white block counter if not on a white block
    BEQ ++                          ; jump to after the white block code

+
    LDA active_inputs
    AND #PAD_DOWN
    BEQ -                           ; if !down then jump

    INC white_block_cnt             ; white_block_cnt++

    LDA white_block_cnt
    CMP #$F0
    BNE ++                          ; if white_block_cnt !$F0, jump to ++

; Count max reached!  Fall into background...

    LDA #$F0
    STA is_behind                   ; set player as behind the scene...

    ; To make Player fall, do everything in our power to make sure
    ; the Player doesn't get a chance to jump or anything else :)
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

++:
    LDA tileset
    CMP #$02
    BEQ PRG008_BE81  ; If level is Hills style, jump to PRG008_BE81

    CMP #$0d
    BNE PRG008_BEE5  ; If level is NOT underground style, jump to PRG008_BEE5

PRG008_BE81:

    ; QUICKSAND LOGIC

    ; Hills & Underground...

    LDA player_y_vel
    BMI PRG008_BEE5  ; If Player is moving upward, jump to PRG008_BEE5

    LDX #$03     ; X = 3

PRG008_BE87:
    LDA left_block,X    ; Get tile

    ; If tile is TILE3_QUICKSAND_TOP or TILE3_QUICKSAND_MID, jump to PRG008_BE9D
    CMP #TILE3_QUICKSAND_TOP
    BEQ PRG008_BE9D
    CMP #TILE3_QUICKSAND_MID
    BEQ PRG008_BE9D

    DEX      ; X--
    BPL PRG008_BE87  ; While X >= 0, loop!

    LDA #$00
    STA Player_SandSink  ; Player is not sinking in sand!

    JMP PRG008_BEE5  ; Jump to PRG008_BEE5

PRG008_BE9D:

    ; Sinking in quicksand!!

    LDA #$00
    STA Player_IsDucking     ; Player is not ducking
    STA Player_Slide     ; Player is not sliding

    LDA Player_SandSink
    BNE PRG008_BEAC     ; If Player was already sinking in quicksand, jump to PRG008_BEAC

    LDA player_y        ; Get player_y at initial quicksand hit only...

PRG008_BEAC:
    AND #%11110000      ; Keep only upper 4 bits
    STA Player_SandSink  ; Set as Player_SandSink value

    LDA player_y
    SEC
    SBC Player_SandSink  ; Get difference between player_y and top of quicksand

    LDY #-$20    ; Y = -$20 (escape jump vel)
    TAX      ; difference -> 'X'
    AND #%11110000   ; Keep only upper 4 bits
    BNE PRG008_BEC7  ; If Player is not at top of sand, jump to PRG008_BEC7

    ; Player must be close to top of sand...
    TXA      ; difference back to 'A'
    AND #%00001111   ; Keep only lower 4 bits
    CMP #$03
    BGE PRG008_BEC7  ; If still at least 3 pixels under, jump to PRG008_BEC7

    LDY #-$30    ; Otherwise, Y = -$30 (escape jump vel, almost out!)

PRG008_BEC7:
    LDA new_inputs
    BMI PRG008_BED2  ; If Player is pressing 'A', jump to PRG008_BED2

    INC Player_SandSink ; Set bit 0 of Player_SandSink (sinking)

    LDY #$06     ; Y = $06 (sinking vel)
    BNE PRG008_BEDA  ; Jump (technically always) to PRG008_BEDA

PRG008_BED2:
    ; Player is trying to escape!  Play jump sound!
    LDA Sound_QPlayer
    ORA #SND_PLAYERJUMP
    STA Sound_QPlayer

PRG008_BEDA:

    STY player_y_vel ; Set Player's Y velocity

    ; Limit Player's horizontal movement
    LDA Player_XVel
    ASL A
    ROR Player_XVel
    BPL PRG008_BEE5
    INC Player_XVel
PRG008_BEE5:

    LDY tileset
    CPY #$06
    BNE PRG008_BF03  ; If level is not a Toad House, jump to PRG008_BF03 (RTS)

    BIT new_inputs
    BVC PRG008_BF03  ; If Player is not pressing 'B', jump to PRG008_BF03 (RTS)

    JSR PChg_C000_To_29     ; Change page @ C000 to 29
    JSR ToadHouse_ChestPressB   ; Attempt to open a chest!
    JSR PChg_C000_To_0      ; Change page @ C000 to 0

    TXA      ; X -> A
    BEQ PRG008_BF03  ; If no treasure box opened, jump to PRG008_BF03 (RTS)

    DEX      ; X-- (fix to proper inventory index)

    LDA Level_BlockChgXLo
    JSR ToadHouse_GiveItem  ; Pop out item!

PRG008_BF03:
    RTS      ; Return
