;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player_Control
;
; Pretty much all controllable Player actions like ducking,
; sliding, tile detection response, doors, vine climbing, and
; including basic power-up / suit functionality (except the actual
; throwing of fireballs / hammers for some reason!)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Player_Control:
player_control:
    LDA player_direction
    STA last_player_direction
    
    LDA in_air
    STA last_in_air

    LDA end_level_counter
    BNE +disable_inputs

    LDA is_shaking_counter
    BEQ +regular_inputs
    DEC is_shaking_counter

+disable_inputs
    LDA #$00
    STA player_x_vel
    STA active_inputs
    STA new_inputs

+regular_inputs
    LDA is_sliding
    BEQ +not_sliding

    LDA new_inputs
    AND #<~PAD_B
    STA new_inputs

+not_sliding
    LDA Level_Objects+1
    CMP #OBJ_TOADANDKING
    BNE +not_in_message

    LDA active_inputs
    AND #<~(PAD_LEFT | PAD_RIGHT | PAD_UP | PAD_DOWN)
    STA active_inputs    ; Otherwise, disable all directional inputs

+not_in_message
    LDY active_powerup
    BEQ +disable_ducking
    CPY #PLAYERSUIT_FROG
    BEQ +disable_ducking
    LDA is_holding
    ORA is_sliding
    ORA is_kuribo
    BNE +disable_ducking

    LDA in_air
    BEQ +on_ground     

    LDA in_water
    BEQ +not_in_water

+disable_ducking
    LDA #$00
    STA is_ducking
    BEQ +not_ducking

+not_in_water
    LDA is_ducking
    BNE +ducking_by_power_up
    BEQ +not_ducking

+on_ground
    LDA #$00
    STA is_ducking

    LDA is_sloped
    BEQ +sloped_level_ducking

    LDA sliding_x_vel
    BNE +not_ducking

+sloped_level_ducking
    LDA active_inputs
    AND #PAD_LEFT | PAD_RIGHT | PAD_UP | PAD_DOWN
    CMP #PAD_DOWN
    BNE +not_ducking

+ducking_by_power_up
    STY is_ducking    ; Set ducking flag (uses non-zero suit value)

+not_ducking
    LDY #20

    LDA active_powerup
    BEQ +ducking_or_small   ; if small jump
    LDA is_ducking
    BNE +ducking_or_small

    LDY #10     ; ducking or small

+ducking_or_small:
_y_offset = Temp_Var10
_x_offset = Temp_Var11
_head_block = Temp_Var1
_left_block = Temp_Var2
_underwater_status = Temp_Var15

    STY _y_offset   ; 10 or 20
    LDA #$08
    STA _x_offset     ; _x_offset (X offset) = 8

    JSR Player_GetTileAndSlope ; Get tile above Player
    STA head_block
    STA _head_block

    LDA left_block
    STA _left_block

    LDA is_behind
    STA is_behind_enabled
    BEQ +                   ; if Player is not behind the scenes, jump to +

    LDA tick_counter
    LSR A
    BCC ++                  ; decrease one every other frame

    DEC is_behind

++
    LDY #$00

; If tile behind Player's head is $41 or TILE1_SKY, jump to ++
    LDA _head_block
    CMP #$41
    BEQ ++
    CMP #TILE1_SKY
    BEQ ++

    INY                 ; enable "behind the scenes"
    LDA is_behind
    BNE ++

    STY is_behind

++
    STY is_behind_En    ; store whether Player is actually behind scenery

+
    LDA _head_block
    if_solid
    BLT +  ; jump if air

    LDA in_air
    ORA in_water
    ORA pipe_movement
    BNE +     ; If Player is mid air, in water, or moving in a pipe, jump to +

; Solid tile at Player's head; Player is stuck in a low clearance (or worse stuck in the wall!)

; Stop Player horizontally, disable controls (accumulator = 0)
    STA player_x_vel
    STA new_inputs

    AND #<~PAD_A
    STA new_inputs  ; ?? it's still zero?

; This makes the Player "slide" when he's in a space too narrow
    LDA #$01
    STA is_stuck_in_wall
    ADD_WORD player_x, player_x_hi

    ; This will be used in Level_CheckIfTileUnderwater
    ; as bits 2-3 of an index into Level_MinTileUWByQuad
    LDA tileset
    ASL A
    ASL A
    STA Temp_Var3   ; Temp_Var3 = tileset << 2

    LDX #$00    ; Checks Temp_Var1 for tile and $40 override bit in UNK_584
    JSR Level_CheckIfTileUnderwater

    ; Carry is set by Level_CheckIfTileUnderwater if tile was in the
    ; "solid floor" region regardless of being "underwater"
    BCS +is_solid  ; If carry set (tile was in solid region), jump to +is_solid

    ; 'Y' is the result of Level_CheckIfTileUnderwater:
    ; 0 = Not under water, 1 = Underwater, 2 = Waterfall
    TYA
    BNE +is_underwater  ; If Y !0 (somehow under water), jump to +is_underwater

+is_solid

    ; NOT underwater!

    LDA in_water
    BEQ +not_entering_water  ; if not exiting water, jump

    LDA in_air
    BNE +in_mid_air          ; if Player is mid air, jump

; Player is NOT flagged as mid air...
    BCS +not_entering_water  ; if floor is solid, jump
    BCC +jump_out_of_water  ; If tile was NOT in the floor solid region, jump to +jump_out_of_water

+in_mid_air

    ; Player is known as mid air!

    BCS +  ; If tile was in floor solid region, jump to +

    LDA player_y_vel
    BMI +check_if_jumping_out_of_water  ; if player is moving upward, jump

+
_temp_solid_carry = Temp_Var16
; Player is falling down or on top of a solid tile
    ROR A
    STA _temp_solid_carry   ; store solid carry

    LDX #$01                ; check the bottom tile if it is underwater
    JSR Level_CheckIfTileUnderwater

    BCS +  ; If tile was in the floor solid region, jump to +

    TYA
    BEQ +jump_out_of_water  ; If Y = 0 (Not underwater), jump to +jump_out_of_water

+
    LDA _temp_solid_carry
    BMI +is_underwater  ; If we had a floor solid tile in the last check, jump to +is_underwater

; Hit a water tile
+check_if_jumping_out_of_water:
    LDY player_y_vel
    CPY #-$0C
    BGS +  ; If player_y_vel >= -$0C, jump to +

; Prevent player_y_vel from being less than -$0C
    LDY #-$0C

+
; Dampen velocity
    LDA tick_counter
    AND #$07
    BNE +

    INY      ; 1:8 chance velocity will be dampened just a bit

+
    STY player_y_vel

    LDA new_inputs
    AND #<~PAD_A
    STA new_inputs   ; strip out 'A' button press

    LDA active_inputs
    TAY

    AND #<~PAD_UP
    STA active_inputs ; strip out 'Up'

    TYA             ; A = original active_inputs
    AND #PAD_UP | PAD_A
    CMP #PAD_UP | PAD_A
    BNE +not_entering_water  ; if not holding buttons, stay in water

; Player wants to exit water!
    LDA #-$34
    STA player_y_vel ; player_y_vel = -$34 (exit velocity from water)

+jump_out_of_water
; Player NOT marked as "in air" and last checked tile was NOT in the solid region
; OR second check tile was not underwater

    LDY #$00
    STY swim_counter    ; swim_counter = 0
    BEQ +               ; Jump (technically always) to +

+is_underwater
; Solid floor tile at head last check

    LDY _underwater_status
    CPY in_water
    BEQ +not_entering_water    ; If in_water = underwater status, jump +not_entering_water

+
; Player's underwater flag doesn't match the water he's in...

    TYA
    ORA in_water
    STY in_water                ; Merge water flag status
    CMP #$02
    BEQ +not_entering_water     ; If it equals 2, jump to +not_entering_water

    JSR Player_WaterSplash   ; Hit water; splash!

+not_entering_water:

    ; Player not flagged as "under water"
    ; Player not flagged as "mid air" and last checked tile was in solid region

    LDA player_direction
    AND #%01111111
    STA player_direction     ; Clear vertical flip on sprite

    LDY tileset     ; Y = tileset

    LDA #TILEA_DOOR2
    SEC
    SBC Temp_Var1
    BEQ PRG008_A83F  ; If tile is DOOR2's tile, jump to PRG008_A83F

    ; Only fortresses can use DOOR1
    CPY #$01
    BNE PRG008_A86C  ; If tileset <> 1 (fortress style), jump to PRG008_A86C

    CMP #$01
    BNE PRG008_A86C  ; If tile is not DOOR1, jump to PRG008_A86C

PRG008_A83F:

    ; DOOR LOGIC

    LDA new_inputs
    AND #PAD_UP
    BEQ PRG008_A86C  ; If Player is not pressing up in front of a door, jump to PRG008_A86C

    LDA in_air
    BNE PRG008_A86C  ; If Player is mid air, jump to PRG008_A86C

    ; If Level_PipeNotExit is set, we use Level_JctCtl = 3 (the general junction)
    ; Otherwise, a value of 1 is used which flags that pipe should exit to map

    LDY #$01    ; Y = 1

    LDA Level_PipeNotExit
    BEQ PRG008_A852  ; If pipe should exit to map, jump to PRG008_A852

    LDY #$03     ; Otherwise, Y = 3

PRG008_A852:
    STY Level_JctCtl ; Set appropriate value to Level_JctCtl

    LDY #0
    STY Map_ReturnStatus     ; Map_ReturnStatus = 0

    STY player_x_vel     ; player_x_vel = 0

    LDA player_x
    AND #$08
    BEQ PRG008_A864  ; If Player is NOT halfway across door, jump to PRG008_A864

    LDY #16      ; Otherwise, Y = 16

PRG008_A864:
    TYA
    CLC
    ADC player_x    ; Add offset to player_x if needed
    AND #$F0     ; Lock to nearest column (place directly in doorway)
    STA player_x    ; Update player_x

PRG008_A86C:

    ; VINE CLIMBING LOGIC

    LDA in_water
    ORA is_holding
    ORA is_kuribo
    BNE PRG008_A890  ; If Player is in water, holding something, or in Kuribo's shoe, jump to PRG008_A890

    LDA Temp_Var1
    CMP #TILE1_VINE
    BNE PRG008_A890  ; If tile is not the vine, jump to PRG008_A890

    LDA Player_IsClimbing
    BNE PRG008_A898  ; If climbing flag is set, jump to PRG008_A898

    LDA active_inputs
    AND #PAD_UP | PAD_DOWN
    BEQ PRG008_A890  ; If Player is not pressing up or down, jump to PRG008_A890

    LDY in_air
    BNE PRG008_A898  ; If Player is in the air, jump to PRG008_A898

    AND #%00001000
    BNE PRG008_A898  ; If Player is pressing up, jump to PRG008_A898

PRG008_A890:
    LDA #$00
    STA Player_IsClimbing    ; Player_IsClimbing = 0 (Player is not climbing)

    JMP PRG008_A8F9  ; Jump to PRG008_A8F9

PRG008_A898:
    LDA #$01
    STA Player_IsClimbing    ; Player_IsClimbing = 1 (Player is climbing)

    ; Kill Player velocities
    LDA #$00
    STA player_x_vel
    STA player_y_vel

    LDY #$10    ; Y = $10 (will be Y velocity down if Player is pressing down)

    LDA active_inputs
    AND #PAD_UP | PAD_DOWN
    BEQ +not_a_vine  ; If Player is not pressing up or down, jump to +not_a_vine

    ; Player is pressing UP or DOWN...

    AND #PAD_UP
    BEQ +  ; If Player is NOT pressing UP, jump to +

    ; Player is pressing UP...

    LDY #16     ; Y = 16

    LDA active_powerup
    BEQ PRG008_A8B7  ; If Player is small, jump to PRG008_A8B7

    LDY #0      ; Otherwise, Y = 0

PRG008_A8B7:
    STY _y_offset  ; _y_offset = 16 or 0 (if small) (Y Offset for Player_GetTileAndSlope)

    LDA #$08
    STA _x_offset  ; _x_offset = 8 (X Offset for Player_GetTileAndSlope)

    JSR Player_GetTileAndSlope  ; Get tile

    CMP #TILE1_VINE
    BNE +not_a_vine  ; If tile is NOT another vine, jump to +not_a_vine

    LDY #-$10
    STY in_air ; Flag Player as "in air"

+
    STY player_y_vel  ; Set Player's Y Velocity

+not_a_vine:
    LDY #$10     ; Y = $10 (rightward X velocity)

    LDA active_inputs
    AND #PAD_LEFT | PAD_RIGHT
    BEQ PRG008_A8DA  ; If Player is NOT pressing LEFT or RIGHT, jump to PRG008_A8DA

    AND #PAD_LEFT
    BEQ PRG008_A8D8  ; If Player is NOT pressing LEFT, jump to PRG008_A8D8

    LDY #-$10    ; Y = -$10 (leftward X velocity)

PRG008_A8D8:
    STY player_x_vel ; Set Player's X Velocity

PRG008_A8DA:
    LDA Player_IsClimbing
    BEQ PRG008_A8EC  ; If Player is NOT climbing, jump to PRG008_A8EC

    ; Player is climbing...

    LDA in_air
    BNE PRG008_A8EC  ; If Player is in air, jump to PRG008_A8EC

    LDA active_inputs
    AND #PAD_UP | PAD_DOWN
    BNE PRG008_A8EC  ; If Player is pressing UP or DOWN, jump to PRG008_A8EC

    STA Player_IsClimbing    ; Set climbing flag

PRG008_A8EC:

    ; Apply Player's X and Y velocity for the vine climbing
    JSR Player_ApplyXVelocity
    JSR Player_ApplyYVelocity

    JSR Player_DoClimbAnim   ; Animate climbing
    JSR Player_Draw29    ; Draw Player
    RTS      ; Return

PRG008_A8F9:

    ; Player not climbing...

    LDA sliding_x_vel
    BEQ PRG008_A906  ; If Player sliding rate is zero, jump to PRG008_A906

    ; Otherwise, apply it
    LDA player_x_vel
    CLC
    ADC sliding_x_vel
    STA player_x_vel

PRG008_A906:
    JSR Player_ApplyXVelocity    ; Apply Player's X Velocity

    LDA sliding_x_vel
    BEQ PRG008_A916  ; If Player is not sliding, jump to PRG008_A916

    ; Otherwise, apply it AGAIN
    LDA player_x_vel
    SEC
    SBC sliding_x_vel
    STA player_x_vel

PRG008_A916:

    LDA #$00
    STA sliding_x_vel     ; sliding_x_vel = 0 (does not persist)

    LDY #$02     ; Y = 2 (moving right)

    LDA player_x_vel
    BPL PRG008_A925  ; If Player's X Velocity is rightward, jump to PRG008_A925

    JSR Negate   ; Negate X Velocity (get absolute value)

    DEY      ; Y = 1 (moving left)

PRG008_A925:
    BNE PRG008_A928  ; If Player's X Velocity is not zero (what is intended by this check), jump PRG008_A928

    ; Player's velocity is zero
    TAY      ; And thus, so is Y (not moving left/right)

PRG008_A928:
    STA Temp_Var3   ; Temp_Var3 = absolute value of Player's X Velocity

    STY Player_MoveLR   ; Set Player_MoveLR appropriately

    LDA in_air
    BEQ PRG008_A940  ; If Player is not mid air, jump to PRG008_A940

    LDA Player_YHi
    BPL PRG008_A93D  ; If Player is on the upper half of the screen, jump to PRG008_A93D

    ; Player is mid air, lower half of screen...

    LDA Player_Y
    BMI PRG008_A93D  ; If Player is beneath the half point of the lower screen, jump to PRG008_A93D

    LDA player_y_vel
    BMI PRG008_A940  ; If Player is moving upward, jump to PRG008_A940

PRG008_A93D:
    JSR Player_ApplyYVelocity    ; Apply Player's Y velocity

PRG008_A940:
    JSR Player_CommonGroundAnims     ; Perform common ground animation routines

    LDA is_kuribo
    BEQ PRG008_A94C  ; If Player is not wearing Kuribo's shoe, jump to PRG008_A94C

    ; If in Kuribo's shoe...

    LDA #14      ; A = 14 (Kuribo's shoe code pointer)
    BNE PRG008_A956  ; Jump (technically always) to PRG008_A956

PRG008_A94C:
    LDA active_powerup

    LDY in_water
    BEQ PRG008_A956  ; If Player is not under water, jump to PRG008_A956

    CLC
    ADC #$07     ; Otherwise, add 7 (underwater code pointers)

PRG008_A956:
    ASL A        ; 2-byte pointer
    TAY      ; -> Y

    ; MOVEMENT LOGIC PER POWER-UP / SUIT

    ; NOTE: If you were ever one to play around with the "Judgem's Suit"
    ; glitch power-up, and wondered why he swam in the air and Kuribo'ed
    ; in the water, here's the answer!


    ; Get proper movement code address for power-up
    ; (ground movement, swimming, Kuribo's shoe)
    LDA PowerUpMovement_JumpTable,Y
    STA Temp_Var1
    LDA PowerUpMovement_JumpTable+1,Y
    STA Temp_Var2


    JMP (Temp_Var1)  ; Jump into the movement code!

PowerUpMovement_JumpTable:
    ; Ground movement code
    .word GndMov_Small  ; 0 - Small
    .word GndMov_Big    ; 1 - Big
    .word GndMov_FireHammer ; 2 - Fire
    .word GndMov_Leaf   ; 3 - Leaf
    .word GndMov_Frog   ; 4 - Frog
    .word GndMov_Tanooki    ; 5 - Tanooki
    .word GndMov_FireHammer ; 6 - Hammer

    ; Underwater movement code
    .word Swim_SmallBigLeaf ; 0 - Small
    .word Swim_SmallBigLeaf ; 1 - Big
    .word Swim_FireHammer   ; 2 - Fire
    .word Swim_SmallBigLeaf ; 3 - Leaf
    .word Swim_Frog     ; 4 - Frog
    .word Swim_Tanooki  ; 5 - Tanooki
    .word Swim_FireHammer   ; 6 - Hammer

    ; Kuribo's shoe
    .word Move_Kuribo

GndMov_Small:
    JSR Player_GroundHControl ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag

    LDA Player_SandSink
    LSR A
    BCS PRG008_A9A3  ; If bit 0 of Player_SandSink was set, jump to PRG008_A9A3 (RTS)

    LDA Player_AllowAirJump
    BNE PRG008_A9A3  ; If Player_AllowAirJump, jump to PRG008_A9A3 (RTS)

    LDA in_air
    BEQ PRG008_A9A3  ; If Player is not mid air, jump to PRG008_A9A3 (RTS)

    ; Player is mid-air...

    LDA #PF_JUMPFALLSMALL   ; Standard jump/fall frame

    LDY Player_FlyTime
    BEQ PRG008_A9A1  ; If Player_FlyTime = 0, jump to PRG008_A9A1

    LDA #PF_FASTJUMPFALLSMALL    ; High speed jump frame

PRG008_A9A1:
    STA Player_Frame ; Set appropriate frame

PRG008_A9A3:
    RTS      ; Return

Swim_SmallBigLeaf:
    JSR Player_UnderwaterHControl ; Do Player left/right input for underwater
    JSR Player_SwimV ; Do Player up/down swimming action
    JSR Player_SwimAnim ; Do Player swim animations
    RTS      ; Return

GndMov_Big:
    JSR Player_GroundHControl ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag
    JSR Player_SoarJumpFallFrame ; Do Player soar/jump/fall frame
    RTS      ; Return

    RTS      ; Return?

GndMov_FireHammer:
    JSR Player_GroundHControl ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag
    JSR Player_SoarJumpFallFrame ; Do Player soar/jump/fall frame
    JSR Player_ShootAnim ; Do Player shooting animation
    RTS      ; Return

Swim_FireHammer:
    JSR Player_UnderwaterHControl ; Do Player left/right input for underwater
    JSR Player_SwimV ; Do Player up/down swimming action
    JSR Player_SwimAnim ; Do Player swim animations
    JSR Player_ShootAnim ; Do Player shooting animation
    RTS      ; Return

GndMov_Leaf:
    JSR Player_GroundHControl ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag
    JSR Player_AnimTailWag ; Do Player's tail animations
    JSR Player_TailAttackAnim ; Do Player's tail attack animations
    RTS      ; Return

    RTS      ; Return?

GndMov_Frog:
    JSR Player_GroundHControl ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag

    LDA is_holding
    BNE PRG008_AA23  ; If Player is holding something, jump to PRG008_AA23

    LDA in_air
    BEQ PRG008_AA00  ; If Player is NOT in mid air, jump to PRG008_AA00

    LDA Player_SandSink
    LSR A
    BCS PRG008_AA00  ; If bit 0 of Player_SandSink is set, jump to PRG008_AA00

    LDA #$00
    STA Player_FrogHopCnt    ; Player_FrogHopCnt = 0

    LDY #$01     ; Y = 1
    JMP PRG008_AA1E  ; Jump to PRG008_AA1E

PRG008_AA00:
    LDA Player_FrogHopCnt
    BNE PRG008_AA1A  ; If Player_FrogHopCnt <> 0, jump to PRG008_AA1A

    STA player_x_vel    ; player_x_vel = 0
    LDA active_inputs
    AND #PAD_LEFT | PAD_RIGHT
    BEQ PRG008_AA1A  ; If Player is not pressing left/right, jump to PRG008_AA1A

    ; Play frog hop sound
    LDA Sound_QPlayer
    ORA #SND_PLAYERFROG
    STA Sound_QPlayer

    LDA #$1f
    STA Player_FrogHopCnt ; Player_FrogHopCnt = $1f

PRG008_AA1A:
    LSR A
    LSR A
    LSR A
    TAY  ; Y = Player_FrogHopCnt >> 3

PRG008_AA1E:
    LDA Player_FrogHopFrames,Y  ; Get frog frame
    STA Player_Frame       ; Store as frame

PRG008_AA23:
    RTS      ; Return

Frog_SwimSoundMask:
    .byte $03, $07

    ; Base frame for the different swimming directions of the frog
Frog_BaseFrame:
    ; Down, Up, Left/Right
    .byte PF_FROGSWIM_DOWNBASE, PF_FROGSWIM_UPBASE, PF_FROGSWIM_LRBASE

    ; Frame offset to frames above
Frog_FrameOffset:
    .byte $02, $02, $02, $01, $00, $01, $02, $02

    ; Base velocity for frog swim right/down, left/up
Frog_Velocity:
    .byte 16, -16

Swim_Frog:
    LDX #$ff     ; X = $FF

    LDA active_inputs
    AND #PAD_UP | PAD_DOWN
    BEQ PRG008_AA61  ; If Player is NOT pressing up/down, jump to PRG008_AA61

    ;
    STA in_air

    LSR A
    LSR A
    LSR A
    TAX      ; X = 1 if pressing up, else 0

    LDA Frog_Velocity,X ; Get base frog velocity
    BPL PRG008_AA4D  ; If value >= 0 (if pressing down), jump to PRG008_AA4D

    LDY Player_AboveTop
    BPL PRG008_AA4D  ; If Player is not off top of screen, jump to PRG008_AA4D

    LDA #$00     ; A = 0

PRG008_AA4D:
    LDY active_inputs
    BPL PRG008_AA52  ; If Player is not pressing 'A', jump to PRG008_AA52

    ASL A        ; Double vertical speed

PRG008_AA52:
    CMP #PLAYER_FROG_MAXYVEL+1
    BLT PRG008_AA5C

    LDY in_air
    BNE PRG008_AA5C  ; If Player is swimming above ground, jump to PRG008_AA5C

    LDA #PLAYER_FROG_MAXYVEL     ; Cap swim speed

PRG008_AA5C:
    STA player_y_vel ; Set Y Velocity
    JMP PRG008_AA6E  ; Jump to PRG008_AA6E

PRG008_AA61:
    LDY player_y_vel
    BEQ PRG008_AA6E  ; If Y Velocity = 0, jump to PRG008_AA6E

    INY      ; Y++

    LDA player_y_vel
    BMI PRG008_AA6C  ; If player_y_vel < 0, jump to PRG008_AA6C

    DEY
    DEY      ; Y -= 2

PRG008_AA6C:
    STY player_y_vel ; Update Y Velocity

PRG008_AA6E:
    LDA active_inputs
    AND #PAD_LEFT | PAD_RIGHT
    BEQ PRG008_AA84  ; If Player is not pressing left or right, jump to PRG008_AA84

    ; Player is pressing left/right...

    LSR A
    TAY
    LDA Frog_Velocity,Y ; Get base frog velocity

    LDY active_inputs
    BPL PRG008_AA7E  ; If Player is not pressing 'A', jump to PRG008_AA7E

    ASL A        ; Double horizontal velocity

PRG008_AA7E:
    STA player_x_vel ; Update X Velocity

    LDX #$02     ; X = 2
    BNE PRG008_AA9C  ; Jump (technically always) to PRG008_AA9C

PRG008_AA84:
    LDY player_x_vel
    BEQ PRG008_AA94  ; If Player is not moving horizontally, jump to PRG008_AA94

    INY      ; Y++

    LDA player_x_vel
    BMI PRG008_AA8F  ; If player_x_vel < 0, jump to PRG008_AA8F

    DEY
    DEY      ; Y -= 2

PRG008_AA8F:
    STY player_x_vel ; Update X Velocity
    JMP PRG008_AA9C  ; Jump to PRG008_AA9C

PRG008_AA94:
    LDA in_air
    BNE PRG008_AA9C  ; If Player is swimming above ground, jump to PRG008_AA9C

    LDA #$15     ; A = $15
    BNE PRG008_AAD2  ; Jump (technically always) to PRG008_AAD2

PRG008_AA9C:
    TXA
    BMI PRG008_AAC8  ; If X < 0, jump to PRG008_AAC8

    LDA tick_counter
    LSR A
    LSR A

    LDY #$00     ; Y = 0

    BIT active_inputs
    BMI PRG008_AAAB  ; If Player is holding 'A', jump to PRG008_AAAB

    LSR A        ; Otherwise, reduce velocity adjustment
    INY      ; Y++

PRG008_AAAB:
    AND #$07
    TAY
    BNE PRG008_AABF

    LDA tick_counter
    AND Frog_SwimSoundMask,Y
    BNE PRG008_AABF  ; If timing is not right for frog swim sound, jump to PRG008_AABF

    ; Play swim sound
    LDA Sound_QPlayer
    ORA #SND_PLAYERSWIM
    STA Sound_QPlayer

PRG008_AABF:
    LDA Frog_BaseFrame,X
    CLC
    ADC Frog_FrameOffset,Y
    BNE PRG008_AAD2

PRG008_AAC8:
    LDY #PF_FROGSWIM_IDLEBASE

    LDA tick_counter
    AND #$08
    BEQ PRG008_AAD1

    INY

PRG008_AAD1:
    TYA

PRG008_AAD2:
    STA Player_Frame ; Update Player_Frame
    RTS      ; Return

GndMov_Tanooki:
    JSR Player_TanookiStatue  ; Change into/maintain Tanooki statue (NOTE: Will not return here if statue!)
    JSR Player_GroundHControl ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag
    JSR Player_AnimTailWag ; Do Player's tail animations
    JSR Player_TailAttackAnim ; Do Player's tail attack animations
    RTS      ; Return

Swim_Tanooki:
    JSR Player_TanookiStatue ; Change into/maintain Tanooki statue (NOTE: Will not return here if statue!)
    JSR Player_UnderwaterHControl ; Do Player left/right input for underwater
    JSR Player_SwimV ; Do Player up/down swimming action
    JSR Player_SwimAnim ; Do Player swim animations
    RTS      ; Return

Move_Kuribo:
    JSR Player_GroundHControl ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag

    LDA in_air
    BNE PRG008_AAFF  ; If Player is mid air, jump to PRG008_AAFF

    STA is_kuriboDir     ; Clear is_kuriboDir

PRG008_AAFF:
    LDA is_kuriboDir
    BNE PRG008_AB17  ; If Kuribo's shoe is moving, jump to PRG008_AB17

    LDA in_air
    BNE PRG008_AB25  ; If Player is mid air, jump to PRG008_AB25

    LDA active_inputs
    AND #PAD_LEFT | PAD_RIGHT
    STA is_kuriboDir     ; Store left/right pad input -> is_kuriboDir
    BEQ PRG008_AB25     ; If Player is not pressing left or right, jump to PRG008_AB25
    INC in_air    ; Flag as in air (Kuribo's shoe bounces along)

    LDY #-$20
    STY player_y_vel     ; player_y_vel = -$20

PRG008_AB17:
    LDA new_inputs
    BPL PRG008_AB25  ; If Player is NOT pressing 'A', jump to PRG008_AB25

    LDA #$00
    STA is_kuriboDir     ; is_kuriboDir = 0

    LDY Player_RootJumpVel   ; Get initial jump velocity
    STY player_y_vel     ; Store into Y velocity

PRG008_AB25:
    LDY active_powerup
    BEQ PRG008_AB2B  ; If Player is small, jump to PRG008_AB2B

    LDY #$01     ; Otherwise, Y = 1

PRG008_AB2B:

    ; Y = 0 if small, 1 otherwise

    LDA is_kuriboFrame,Y    ; Get appropriate Kuribo's shoe frame
    STA Player_Frame       ; Store as active Player frame

    LDA tick_counter
    AND #$08
    BEQ PRG008_AB38     ; Every 8 ticks, jump to PRG008_AB38

    INC Player_Frame   ; Player_Frame++

PRG008_AB38:
    RTS      ; Return
