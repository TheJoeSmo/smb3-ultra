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
    JSR player_horizontal_walking_control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag

    LDA Player_SandSink
    LSR A
    BCS PRG008_A9A3  ; If bit 0 of Player_SandSink was set, jump to PRG008_A9A3 (RTS)

    LDA can_jump_in_air
    BNE PRG008_A9A3  ; If can_jump_in_air, jump to PRG008_A9A3 (RTS)

    LDA in_air
    BEQ PRG008_A9A3  ; If Player is not mid air, jump to PRG008_A9A3 (RTS)

    ; Player is mid-air...

    LDA #PF_JUMPFALLSMALL   ; Standard jump/fall frame

    LDY can_fly_counter
    BEQ PRG008_A9A1  ; If can_fly_counter = 0, jump to PRG008_A9A1

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
    JSR player_horizontal_walking_control ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag
    JSR Player_SoarJumpFallFrame ; Do Player soar/jump/fall frame
    RTS      ; Return

    RTS      ; Return?

GndMov_FireHammer:
    JSR player_horizontal_walking_control ; Do Player left/right input control
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
    JSR player_horizontal_walking_control ; Do Player left/right input control
    JSR Player_JumpFlyFlutter ; Do Player jump, fly, flutter wag
    JSR Player_AnimTailWag ; Do Player's tail animations
    JSR Player_TailAttackAnim ; Do Player's tail attack animations
    RTS      ; Return

    RTS      ; Return?

GndMov_Frog:
    JSR player_horizontal_walking_control ; Do Player left/right input control
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
    LDA player_sound_queue
    ORA #SND_PLAYERFROG
    STA player_sound_queue

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
    LDA player_sound_queue
    ORA #SND_PLAYERSWIM
    STA player_sound_queue

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
    JSR player_horizontal_walking_control ; Do Player left/right input control
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
    JSR player_horizontal_walking_control ; Do Player left/right input control
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

    LDY #PLAYER_JUMP   ; Get initial jump velocity
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

    ; This is the main value of X acceleration applied
player_x_accelaration:

    ; F = "Friction" (stopping rate), "N = "Normal" accel, S = "Skid" accel, X = unused
    ; Without B button  With B button
    ;      F   N   S   X     F   N   S   X
    .byte -1,  0,  2,  0,   -1,  0,  2,  0  ; Small
    .byte -1,  0,  2,  0,   -1,  0,  2,  0  ; Big
    .byte -1,  0,  2,  0,   -1,  0,  2,  0  ; Fire
    .byte -1,  0,  2,  0,   -1,  0,  2,  0  ; Leaf
    .byte -1,  2,  2,  0,   -1,  2,  2,  0  ; Frog
    .byte -1,  0,  2,  0,   -1,  0,  2,  0  ; Tanooki
    .byte -1,  0,  2,  0,   -1,  0,  2,  0  ; Hammer

player_x_accelaration_UW:
    ; If on the ground  If swimming above the ground
    .byte -1,  1,  1,  0,   -1,  0,  0,  0

    .byte -1,  0,  0,  0,   -1,  0,  1,  0
    .byte -1,  0,  0,  0,   -1,  0,  0,  0


    ; The following values are added to the "Counter_Wiggly"
    ; value in an attempt to push the likelihood of a carry
    ; which gives just a slight boost to the Player's X
    ; velocity acceleration; way of making it sort of a
    ; fractional increase while he moves...
player_x_subpixel_accelaration:

    ; F = "Friction" (stopping rate), "N = "Normal" accel, S = "Skid" accel, X = unused
    ; Without B button      With B button
    ;       F    N    S    X          F    N    S    X
    .byte $60, $E0, $00, $00,   $60, $E0, $00, $00  ; Small
    .byte $20, $E0, $00, $00,   $20, $E0, $00, $00  ; Big
    .byte $20, $E0, $00, $00,   $20, $E0, $00, $00  ; Fire
    .byte $20, $E0, $00, $00,   $20, $E0, $00, $00  ; Leaf
    .byte $00, $00, $00, $00,   $00, $00, $00, $00  ; Frog
    .byte $60, $E0, $00, $00,   $60, $E0, $00, $00  ; Tanooki
    .byte $60, $E0, $00, $00,   $60, $E0, $00, $00  ; Hammer

player_x_subpixel_accelaration_UW:
    ; If on the ground      If swimming above the ground
    .byte $30, $00, $00, $00,   $E0, $30, $80, $00

    .byte $A0, $E0, $C0, $00,   $A0, $E0, $20, $00
    .byte $D0, $E0, $60, $00,   $D0, $E0, $C0, $00

    .byte $10, $F0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; player_horizontal_walking_control
; player_horizontal_walking_control
;
; Routine to control based on Player's left/right pad input (not
; underwater); configures walking/running
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_temp_x_velocity = Temp_Var3

; Table of values that have to do with is_going_uphill_speed override
uphill_speed_index:
    .byte $00, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D

player_horizontal_walking_control:
    LDA is_going_uphill
    BEQ +not_going_uphill  ; If Player is not going up hill, jump to +not_going_uphill

; Going up a hill
    INC player_walking_frames    ; player_walking_frames++

    LDY #10
    BIT active_inputs
    BVC +       ; if holding b, jump

    LDY #01
    BNE +       ; jump

+not_going_uphill:

    ; Use override value

    LDY is_going_uphill_speed
    BEQ ++      ; if not going uphill, jump

+
    LDA uphill_speed_index, y       ; get uphill speed
    TAY
    JMP _store_speed

++
    LDY #new_inputs

    BIT active_inputs
    BVC _store_speed        ; if not holding b, jump

    LDA in_air
    ORA is_sliding
    BNE +                   ; if sliding or in air, jump

    LDA _temp_x_velocity
    CMP #PLAYER_TOPRUNSPEED
    BMI +                   ; if temp < top speed, jump

; Player is going fast enough while holding B on the ground; flag running!
    INC running_max_speed

+
; Start with top run speed
    LDY #PLAYER_TOPRUNSPEED ; Y = PLAYER_TOPRUNSPEED

    LDA p_speed_charge
    CMP #$7f
    BNE _store_speed    ; if Player has not hit full p speed, jump to _store_speed

    ; Otherwise, top power speed
    LDY #PLAYER_TOPPOWERSPEED

_store_speed:
_current_speed = Temp_Var14
    STY _current_speed

    LDY slippery_type
    BEQ +           ; if not slippery, jump

    INC player_walking_frames ; player_walking_frames++

    DEY
    TYA
    ASL A
    ASL A
    ASL A
    CLC
    ADC #$40
    TAY      ; ((selected top speed - 1) << 3) + $40
    BNE ++  ; And as long as that's not zero, jump to ++

+
    LDA active_powerup
    ASL A
    ASL A
    ASL A
    TAY      ; Y = active_powerup << 3

++
    BIT active_inputs
    BVC +   ; if not pressing b, jump

; Otherwise...
    INY
    INY
    INY
    INY ; Y += 4 (offset 4 inside Player_XAccel* tables)

+
    LDA active_inputs
    AND #PAD_LEFT | PAD_RIGHT
    BNE +left_or_right      ; if holding < or >, jump

; Player not pressing LEFT/RIGHT...

    LDA in_air
    BNE +return             ; return if in air

    LDA player_x_vel
    BEQ +return             ; return if no velocity
    BMI +left
    BPL +right

+left_or_right:
; Player is pressing left/right...
    INY
    INY      ; Y += 2 (offset 2 within Player_XAccel* tables, the "skid" rate)

    AND player_movement_direction
    BNE +       ; if Player suddenly reversed direction, jump to +

    DEY      ; Y-- (back one offset, the "normal" rate)

    LDA _temp_x_velocity
    CMP _current_speed
    BEQ +return  ; return if x speed == top speed
    BMI +

    LDA in_air
    BNE +return  ; If Player is mid air, jump to +return

    DEY      ; Y-- (back one offset, the "friction" stopping rate)

+
; At this point, 'Y' contains the current power-up in bits 7-3,
; bit 2 is set if Player pressed B, bit 1 is set if the above
; block was jumped, otherwise bit 0 is set if the X velocity is
; less than the specified maximum, clear if over the max

; Y = active_powerup << 3 +
;       1 if _temp_x_velocity < _current_speed
;       2 if pressing left or right else 0
;       4 if pressing b else 0

    LDA active_inputs
    AND #PAD_RIGHT
    BNE +right  ; If Player is holding RIGHT, jump to +right (moving rightward code)

+left
_player_x_subpixel_accelaration = Temp_Var1
_player_x_accelaration = Temp_Var2
    ; Player moving leftward

    LDA #$00
    SEC
    SBC player_x_subpixel_accelaration, y
    STA _player_x_subpixel_accelaration     ; -1 * acceleration

    LDA player_x_accelaration, y
    EOR #$ff     ; lazy negate (did not add 1)
    STA _player_x_accelaration

    LDA _player_x_subpixel_accelaration
    BNE +

    INC _player_x_accelaration              ; Otherwise, correct the negate
    BNE +
    BEQ +

+right:
; Player moving rightward

    LDA player_x_subpixel_accelaration, y
    STA _player_x_subpixel_accelaration

    LDA player_x_accelaration, y
    STA _player_x_accelaration

+
    LDA _player_x_subpixel_accelaration
    CLC
    ADC Counter_Wiggly  ; actual value not used, looking for a semi-random carry

    LDA player_x_vel
    ADC _player_x_accelaration
    STA player_x_vel    ; player_x_vel += _player_x_accelaration (and sometimes carry)

+return:
    RTS      ; Return


; This table grants a couple (dis)abilities to certain power-ups
_DEFAULT = $00
_CAN_FLY = $01
_CANNOT_SLIDE = $02

power_up_abilities:
    .byte _DEFAULT,         ; Baby Mario
    .byte _DEFAULT,         ; Super Mushroom
    .byte _DEFAULT,         ; Fire Suit
    .byte _CAN_FLY,         ; Raccoon Suit
    .byte _CANNOT_SLIDE,    ; Frog Suit
    .byte _CAN_FLY,         ; Tanooki Suit
    .byte _CANNOT_SLIDE     ; Hammer Suit


    ; Based on how fast Player is running, the jump is
    ; increased just a little (this is subtracted, thus
    ; for the negative Y velocity, it's "more negative")
jump_speed_by_velocity:    .byte $00, $02, $04, $08

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player_JumpFlyFlutter
;
; Controls the acts of jumping, flying, and fluttering (tail wagging)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
up_hill_speed_by_y_velocity: y    .byte $D0, $CE, $CC, $CA, $CA, $CA

Player_JumpFlyFlutter:
_pressing_a = Temp_Var1
    LDA can_jump_in_air
    BEQ +
    DEC can_jump_in_air         ; if !0 dec counter

+

    LDA new_inputs
    AND #PAD_A
    STA _pressing_a   ; Temp_Var1 = $80 if Player is pressing 'A', otherwise 0
    BEQ +not_jumping  ; If Player is NOT pressing 'A', jump to +not_jumping

    LDA can_jump_in_air
    BNE +start_jumping

    LDA in_air
    BNE +not_jumping

+start_jumping:

; Play jump sound
    LDA player_sound_queue
    ORA #SND_PLAYERJUMP
    STA player_sound_queue

    LDA invinsability_counter
    BEQ +no_starman_spin

    LDA p_speed_charge
    CMP #$7f
    BEQ +no_starman_spin    ; only without p speed

    LDA is_holding
    BNE +no_starman_spin    ; need to not hold anything

    LDA active_powerup
    BEQ +no_starman_spin    ; no spinning for small Mario
    CMP #PLAYERSUIT_FROG
    BEQ +no_starman_spin    ; or for frog either

; Otherwise, mark as mid air and back-flipping
    STA invis_summer_sault
    STA in_air

    LDA #$00
    STA can_jump_in_air

+no_starman_spin:
    LDA player_x_vel
    BPL +
    NEG     ; |player_x_vel|
+

    LSR A
    LSR A
    LSR A
    LSR A
    TAX     ; X = magnitude of player's x velocity >> 4 (the "whole" part)

    LDA #PLAYER_JUMP                ; initial jump velocity
    SEC
    SBC jump_speed_by_velocity, x   ; subtract a tiny bit of boost
    STA player_y_vel

    LDA #$01
    STA in_air                      ; flag Player as mid air

    LDA #$00
    STA is_wagging_tail             ; not wagging tail if you are jumping
    STA can_jump_in_air

    LDA p_speed_charge
    CMP #$7f
    BNE +not_jumping                ; if no p speed, jump

    LDA can_fly_counter
    BNE +not_jumping                ; if can fly, jump

    LDA #$80
    STA can_fly_counter             ; can fly is set

+not_jumping:
    LDA in_air
    BNE +in_air                     ; if Player is mid air, jump

    LDY active_powerup
    LDA power_up_abilities, y
    AND #_CAN_FLY
    BNE +                           ; if power up has flight ability, jump

    LDA #$00
    STA can_fly_counter  
    BEQ +                           ; no flying today

+in_air:
; player is mid air...

    LDY #$05

    LDA player_y_vel
    CMP #-$20
    BGS ++          ; if player's Y velocity >= -$20, jump

    LDA has_micro_goombas
    BNE +++         ; if player has got a microgoomba stuck to him, jump

    LDA Pad_Holding
    BPL ++          ; if Player is NOT pressing 'A', jump

    LDY #$01
    BNE +++

++
    LDA #$00
    STA has_micro_goombas   ; no micro goombas

+++
    TYA
    CLC
    ADC player_y_vel
    STA player_y_vel        ; player_y_vel += Y

    LDA is_wagging_tail
    BEQ ++

    DEC is_wagging_tail     ; decrement if !0

++
    LDA is_kuribo
    BNE ++                  ; if Player is wearing Kuribo's shoe, jump to ++

    LDX active_powerup

    LDA power_up_abilities, x
    AND #_CAN_FLY
    BEQ ++                  ; jump if no flight

    LDY _pressing_a
    BEQ ++                  ; if not pressing a

    LDA #$10
    STA is_wagging_tail    ; is_wagging_tail = $10

++
    LDA is_wagging_tail
    BEQ +                   ; if Player has not wag count left, jump to +

; RACCOON / TANOOKI TAIL WAG LOGIC

    LDA player_y_vel
    CMP #PLAYER_FLY_YVEL
    BLS +                       ; if Player's Y velocity is < PLAYER_FLY_YVEL, jump

    LDY #PLAYER_FLY_YVEL

    LDA can_fly_counter
    BEQ ++                      ; if Player is not flying, jump

    CMP #$0f
    BGE +++                     ; if plenty of flight time, jump

    ; Player has a small amount of flight time left

    LDY #$F0
    AND #$08
    BNE +++                     ; every 8 ticks, jump

    LDY #$00                    ; Y = 0 (at apex of flight, Player no longer rises)
    BEQ +++                     ; always jump

++
    LDA player_y_vel
    BMI +                       ; if player's Y velocity < 0 (moving upward), jump to +

    CMP #PLAYER_TAILWAG_YVEL
    BLT +                       ; if player's Y velocity < PLAYER_TAILWAG_YVEL, jump to +

    LDY #PLAYER_TAILWAG_YVEL    ; Y = PLAYER_TAILWAG_YVEL

+++
    STY player_y_vel

+
    LDA is_going_uphill_speed
    BEQ +                       ; if is_going_uphill_speed == 0 (not walking uphill), jump

    LSR A
    TAY      
    LDA player_y_vel
    BPL +                       ; if Player's Y vel >= 0, return

    CMP up_hill_speed_by_y_velocity, y
    BLS +                       ; if Player's uphill speed < Y velocity, jump to +

    LDA #$20
    STA player_y_vel 
+
    RTS
