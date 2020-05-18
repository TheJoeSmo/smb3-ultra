is_statue = Player_Statue ; if ~0 then is a statue
tail_swipe_counter = Player_TailAttack ; counter from 0-12
invis_summer_sault = Player_Flip ; if the player in_air and invis
hit_ceiling = Player_HitCeiling ; if player just hit the ceiling
is_ducking = Player_IsDucking
pipe_movement = Level_PipeMove
is_sloped = Level_SlopeEn
pswitch_cnt = Level_PSwitchCnt
is_kuribo = Player_Kuribo
slippery_type = Player_Slippery
white_block_cnt = Player_WhiteBlkCnt
is_behind = Player_Behind
is_behind_enabled = Player_Behind_En
is_sliding = Player_Slide
is_sinking = Player_SandSink

in_air = Player_InAir ; if player is in the air
last_in_air= Player_InAir_OLD

end_level_counter = Player_EndLevel
is_shaking_counter = Player_VibeDisable

player_direction = Player_FlipBits ; 0 == left, #$40 == right
last_player_direction = Player_FlipBits_OLD

in_water = Player_InWater
is_above_below_water = FloatLevel_PlayerWaterStat
swim_counter = Player_SwimCnt
sliding_x_vel = Player_SlideRate

tileset = Level_TilesetIdx ; tilesets starting at Plains
tileset_alt = Level_Tileset ; tilesets starting at overworld
pipes_by_tileset = Temp_Var16
is_vertical = Level_7Vertical

head_block = Level_Tile_Head
left_block = Level_Tile_GndL
right_block = Level_Tile_GndR
front_block = Level_Tile_InFL ; front block at feet level

cur_player = Player_Current
player_movement_direction = Player_MoveLR
player_x = Player_X
player_x_hi = Player_XHi
player_y = Player_Y
player_y_hi = Player_YHi
player_x_vel = Player_XVel
player_y_vel = Player_YVel
player_slide = Player_SlideRate ; the amount added for 'sliding' (does not persist)
player_slope = Player_Slopes
is_going_uphill = Player_UphillFlag
is_going_uphill_speed = Player_UphillSpeedIdx
player_sprite_y = Player_SpriteY
player_splash_disable = Splash_DisTimer
splash_counter = Splash_Counter
splash_y_flag = Splash_NoScrollY
splash_y_pos = Splash_Y
splash_x_pos = Splash_X
bubbles_count = Bubble_Cnt
bubble_y = Bubble_Y
bubble_y_hi = Bubble_YHi
bubble_x = Bubble_X
bubble_x_hi = Bubble_XHi
running_max_speed = Player_RunFlag
p_speed_charge = Player_Power
can_jump_in_air = Player_AllowAirJump 	; allows jumping off enemies and whatnot
can_fly_counter = Player_FlyTime

has_micro_goombas = Player_mGoomba
player_walking_frames = Player_WalkAnimTicks

invinsability_counter = Player_StarInv

is_wagging_tail = Player_WagCount

active_inputs = Pad_Holding
new_inputs = Pad_Input

is_holding = Player_IsHolding
is_climbing = Player_IsClimbing

active_powerup = Player_Suit

no_exit_to_map = Level_PipeNotExit
level_junction_type = Level_JctCtl
return_status_from_level = Map_ReturnStatus

player_partition_detection = Player_PartDetEn
is_above_level = Player_AboveTop
temp_17 = Temp_VarNP0

tile_memory_offset = Level_TileOff


temp_tile = Level_Tile

horz_scroll_lock = LevelJctBQ_Flag

is_stuck_in_wall = Player_LowClearance

; object info
objects_states = Objects_State
objects_ids = Level_ObjectID
objects_y = Objects_Y
objects_x = Objects_X
objects_x_velocity = Objects_XVel
objects_y_velocity = Objects_YVel
objects_x_subpixel = Objects_XVelFrac
objects_v1 = Objects_Var1
objects_v2 = Objects_Var2
objects_v3 = Objects_Var3
objects_v4 = Objects_Var4
objects_timer = Objects_Timer

; block update queues
block_event_lo_y = Level_BlockChgYLo
block_event_hi_y = Level_BlockChgYHi

block_event_lo_x = Level_BlockChgXLo
block_event_hi_x = Level_BlockChgXHi

skip_status_bar = Level_SkipStatusBarUpd 	; stops the status bar from being updated for a frame
block_event_queue = Level_ChgTileEvent 	; queues a block event to occur

; toad house stuff
toad_house_type = THouse_Treasure
mario_items = Inventory_Items
mario_cards = Inventory_Cards
luigi_items = Inventory_Items2

; rng
cur_random = RandomN

; scroll information
alt_level_scroll_lo = Level_VertScroll
horizontal_scroll_settings = Level_AScrlConfig

; sound engine
player_sound_queue = Sound_QPlayer
map_sound_queue = Sound_QMap

; common routines

Get_hurt = Player_GetHurt

; tileset names

ts_toad_house = #$06

tick_counter = Counter_1

; tile addressing

tile_address_offset = TileAddr_Off
block_size = LL_ShapeDef
tile_address = Map_Tile_AddrL
tile_layout_address = Level_LayPtr_AddrL