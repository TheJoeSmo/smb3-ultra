is_statue = Player_Statue ; if ~0 then is a statue
tail_swipe_counter = Player_TailAttack ; counter from 0-12
invis_summer_sault = Player_Flip ; if the player in_air and invis
in_air = Player_InAir ; if player is in the air
hit_ceiling = Player_HitCeiling ; if player just hit the ceiling
is_ducking = Player_IsDucking
pipe_movement = Level_PipeMove
is_sloped = Level_SlopeEn
pswitch_cnt = Level_PSwitchCnt
is_kuribo = Player_Kuribo
slippery_type = Player_Slippery
white_block_cnt = Player_WhiteBlkCnt
is_behind = Player_Behind
is_sliding = Player_Slide
is_sinking = Player_SandSink

tileset = Level_TilesetIdx ; tilesets starting at Plains
pipes_by_tileset = Temp_Var16
is_vertical = Level_7Vertical

head_block = Level_Tile_Head
left_block = Level_Tile_GndL
right_block = Level_Tile_GndR
front_block = Level_Tile_InFL ; front block at feet level

cur_player = Player_Current
player_x = Player_X
player_y = Player_Y
player_x_vel = Player_XVel
player_y_vel = Player_YVel
player_slide = Player_SlideRate ; the amount added for 'sliding' (does not persist)

active_inputs = Pad_Holding
new_inputs = Pad_Input

horz_scroll_lock = LevelJctBQ_Flag

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

; sound engine
player_sound_queue = Sound_QPlayer
map_sound_queue = Sound_QMap

; common routines

Get_hurt = Player_GetHurt

; tileset names

ts_toad_house = #$06