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
;_y_offset = Temp_Var10 ;_x_offset = Temp_Var11 ;_head_block = Temp_Var1 ;_left_block = Temp_Var2 ;_underwater_status = Temp_Var15

    ; Player not flagged as "under water"
    ; Player not flagged as "mid air" and last checked tile was in solid region

    LDA player_direction
    AND #%01111111
    STA player_direction     ; clear vertical flip on sprite

    LDY tileset

    LDA #TILEA_DOOR2
    SEC
    SBC _head_block
    BEQ +door_logic

; Only fortresses can use DOOR1
    CPY #$01
    BNE +vine_check     ; if not fortress jump
    CMP #$01
    BNE +vine_check     ; if tile is not DOOR1, jump

+door_logic:
; DOOR LOGIC

    LDA new_inputs
    AND #PAD_UP
    BEQ +vine_check     ; if not pressing up, jump
    LDA in_air
    BNE +vine_check     ; if in air, jump

; If no_exit_to_map is set, we use level_junction_type = 3 (the general junction)
; Otherwise, a value of 1 is used which flags that pipe should exit to map
    LDY #$01            ; redundant as fortress tile-set == 1

    LDA no_exit_to_map
    BEQ +           ; exit to map

    LDY #$03        ; regular pipe

+
    STY level_junction_type             ; 1 or 3

    LDY #$00
    STY return_status_from_level        ; clear the level tile
    STY player_x_vel

    LDA player_x
    AND #$08
    BEQ +                               ; if player is not halfway across door, jump

    LDY #16      ; offset

+
    TYA
    CLC
    ADC player_x        ; add offset to player_x, 0 or 16 (add one column)
    AND #$F0            ; get the exact column
    STA player_x        ; new player x

+vine_check:

; VINE CLIMBING LOGIC
    LDA in_water
    ORA is_holding
    ORA is_kuribo
    BNE +no_climbing    ; if not any of the above, jump

    LDA Temp_Var1
    CMP #TILE1_VINE
    BNE +no_climbing    ; if not a vine, jump

    LDA is_climbing
    BNE +climbing       ; if climbing, jump

    LDA active_inputs
    AND #PAD_UP | PAD_DOWN
    BEQ +no_climbing    ; if not pressing, jump

; pressing up or down
    LDY in_air
    BNE +climbing       ; if Player is in the air, jump

    AND #%00001000
    BNE +climbing       ; if Player is pressing up, jump

+no_climbing:
    LDA #$00
    STA is_climbing    ; is_climbing = 0 (Player is not climbing)

    JMP _not_climbing  ; Jump to _not_climbing

+climbing:
    LDA #$01
    STA is_climbing    ; is_climbing = 1 (Player is climbing)

; Kill Player velocities
    LDA #$00
    STA player_x_vel
    STA player_y_vel

    LDY #$10            ; will be Y velocity down if Player is pressing down

    LDA active_inputs
    AND #PAD_UP | PAD_DOWN
    BEQ +vine_x_logic     ; if not pressing up/down, chill on the vine

; Pressing up/down
    AND #PAD_UP
    BEQ +               ; if pressing down, jump

; Pressing up
    LDY #16

    LDA active_powerup
    BEQ +small          ; if Player is small, jump

    LDY #0              ; no offset

PRG008_A8B7:
    STY _y_offset       ; 16 or 0 if small or big
    LDA #$08
    STA _x_offset
    JSR Player_GetTileAndSlope  ; get that tile

    CMP #TILE1_VINE
    BNE +vine_x_logic     ; if tile is NOT another vine, jump

    LDY #-$10
    STY in_air          ; we are in the air

+
    STY player_y_vel

+vine_x_logic:
    LDY #$10            ; rightward x velocity

    LDA active_inputs
    AND #PAD_LEFT | PAD_RIGHT
    BEQ +               ; if not pressing < or >, jump

    AND #PAD_LEFT
    BEQ +right          ; if not pressing <, jump

    LDY #-$10           ; leftward x velocity

+right:
    STY player_x_vel

+
    LDA is_climbing
    BEQ +               ; if Player is NOT climbing, jump

; Player is climbing...

    LDA in_air
    BNE +               ; if Player is in air, jump

    LDA active_inputs
    AND #PAD_UP | PAD_DOWN
    BNE +               ; if Player is pressing UP or DOWN, jump

    STA is_climbing     ; set climbing flag

+


; Todo: figure out what to do here



    ; Apply Player's X and Y velocity for the vine climbing
    JSR Player_ApplyXVelocity
    JSR Player_ApplyYVelocity

    JSR Player_DoClimbAnim   ; Animate climbing
    JSR Player_Draw29    ; Draw Player
    RTS      ; Return


_not_climbing:
    LDA sliding_x_vel
    BEQ +               ; if not sliding, jump

; Otherwise, apply it
    LDA player_x_vel
    CLC
    ADC sliding_x_vel
    STA player_x_vel

+
    JSR Player_ApplyXVelocity    ; Apply Player's X Velocity

    LDA sliding_x_vel
    BEQ +               ; if not sliding, jump

; Otherwise, un-apply it
    LDA player_x_vel
    SEC
    SBC sliding_x_vel
    STA player_x_vel

+:

    LDA #$00
    STA sliding_x_vel       ; does not persist

    LDY #$02                ; 2 = moving right

    LDA player_x_vel
    BPL +                   ; If Player's X Velocity is rightward, jump

    NEG                     ; inverse the velocity
    DEY                     ; 1 = moving left

+
    BNE +has_velocity       ; jump if velocity

    TAY                     ; 0 = no velocity

+has_velocity
_temp_x_velocity = Temp_Var3
    STA _temp_x_velocity

    STY player_movement_direction   ; set player_movement_direction appropriately

    LDA in_air
    BEQ +no_y_velocity      ; if not in air, we are not moving vertically

    LDA player_y_hi
    BPL +appy_y_velocity    ; if we are on the upper part of the screen, always do velocity

; Player is mid air, lower half of screen...
    LDA player_y
    BMI +appy_y_velocity    ; if low, do velocity

    LDA player_y_vel
    BMI +no_y_velocity      ; if moving upward, do velocity (I believe this if for going under the level)

+appy_y_velocity:
    JSR Player_ApplyYVelocity    ; Apply Player's Y velocity

+no_y_velocity:
    JSR Player_CommonGroundAnims     ; Perform common ground animation routines

    LDA is_kuribo
    BEQ +no_kuribo

; If in kuribo shoe...
    LDA #14                         ; A = 14
    BNE +

+no_kuribo:
    LDA active_powerup

    LDY in_water
    BEQ +                           ; if not underwater jump

    CLC
    ADC #$07     ; Otherwise, add 7 (underwater code pointers)

+:
    ASL A        ; 2-byte pointer
    TAY      ; -> Y

    .include player_control_power_up_movement.asm