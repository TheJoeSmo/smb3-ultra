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

tileset = Level_TilesetIdx ; tilesets starting at Plains
pipes_by_tileset = Temp_Var16
is_vertical = Level_7Vertical

head_block = Level_Tile_Head
left_block = Level_Tile_GndL
right_block = Level_Tile_GndR
front_block = Level_Tile_InFL ; front block at feet level


player_x = Player_X
player_y = Player_Y
player_y_vel = Player_YVel
player_slide = Player_SlideRate ; the amount added for 'sliding' (does not persist)

active_inputs = Pad_Holding
new_inputs = Pad_Input

horz_scroll_lock = LevelJctBQ_Flag

; common routines

Get_hurt = Player_GetHurt