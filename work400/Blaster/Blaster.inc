
break_ball_blue_o    = 046+(screen_x*000)
break_ball_orange_o  = 046+(screen_x*009)
break_ball_yellow_o  = 116+(screen_x*000)
break_ball_green_o   = 116+(screen_x*009)
break_nbs_anim       = 5
break_speed          = 1
break_next_shape     = 1

debug_mode           = Off
dos_mode             = Off

PLAYER_ONE           = 1
PLAYER_TWO           = 2

EASY                 = 1
MEDIUM               = 2
HARD                 = 4
COMPUTER             = 8
KEYBOARD             = 16
JOYSTICK             = 32

icon_menu_1_o        = 002+(screen_x*049)
icon_menu_2_o        = 262+(screen_x*049)
icon_menu_3_o        = 002+(screen_x*310)
icon_menu_4_o        = 262+(screen_x*310)
icon_menu_5_o        = 002+(screen_x*571)
icon_menu_6_o        = 262+(screen_x*571)
icon_menu_7_o        = 002+(screen_x*832)
icon_menu_size_x     = 259
icon_menu_size_y     = 260
icon_menu_pos_x      = 189
icon_menu_pos_y      = 141

panel_note_o         = 467+(screen_x*026);455+(screen_x*026)
panel_note_size_x    = 11
panel_note_size_y    = 11
panel_note_pos_x     = 468
panel_note_pos_y     = 441

panel_music_o         = 370+(screen_x*009)
panel_music_size_x    = 72
panel_music_size_y    = 19
panel_music_pos_x     = 437
panel_music_pos_y     = 454

panel_music_vu_o      = 375+(screen_x*014)
panel_music_vu_red_o  = 452+(screen_x*009)
panel_music_vu_size_x = 62
panel_music_vu_size_y = 9
panel_music_vu_pos_x  = panel_music_pos_x+5
panel_music_vu_pos_y  = panel_music_pos_y+5

panel_menu_o         = 002+(screen_x*001)
panel_menu_size_x    = 240
panel_menu_size_y    = 22
panel_menu_pos_x     = 200
panel_menu_pos_y     = panel_option_pos_y

panel_menu2_o         = 002+(screen_x*024)
panel_menu2_size_x    = 240
panel_menu2_size_y    = 22
panel_menu2_pos_x     = 200+8
panel_menu2_pos_y     = panel_option_pos_y

menu_1_pal           = (16*0)+76
menu_1_pal_size      = 36*3
menu_2_pal           = (16*0)+124
menu_2_pal_size      = 36*3
menu_3_pal           = (16*0)+220
menu_3_pal_size      = 36*3
menu_4_pal           = (16*0)+172
menu_4_pal_size      = 36*3

m_play               = 0000000000000000000000001b
m_misc               = 0000000000000000000000010b
m_demo               = 0000000000000000000000100b
m_quit               = 0000000000000000000001000b
m_solo               = 0000000000000000000010000b
m_coop               = 0000000000000000000100000b
m_dual               = 0000000000000000001000000b
m_cancel             = 0000000000000000010000000b
m_computer           = 0000000000000000100000000b
m_keyboard           = 0000000000000001000000000b
m_joystick           = 0000000000000010000000000b
m_easy               = 0000000000000100000000000b
m_normal             = 0000000000001000000000000b
m_hard               = 0000000000010000000000000b
m_score_1            = 0000000000100000000000000b
m_score_2            = 0000000001000000000000000b
m_credit             = 0000000010000000000000000b
m_cancel_2           = 0000000100000000000000000b
m_eclipse            = 0000001000000000000000000b
m_space              = 0000010000000000000000000b
m_coin_coin          = 0000100000000000000000000b
m_joy_ana            = 0001000000000000000000000b
m_paddle             = 0010000000000000000000000b
m_nothing            = 0100000000000000000000000b
m_cancel_3           = 1000000000000000000000000b

menu_text_o          = 150+(screen_x*150)

cursor_menu_o        = 243+(screen_x*000)
cursor_menu_size_x   = 14
cursor_menu_size_y   = 18

shoot_o              = 444+(screen_x*339)
shoot_size_x         = 8
shoot_size_y         = 42
shoot_nbs_anim       = 11
shoot_speed          = 5
shoot_next           = 3

mini_shoot_o         = 085+(screen_x*164)
mini_shoot_size_x    = 3
mini_shoot_size_y    = 13

nbs_monster          = 4
monster_screen_x     = 930
monster_o            = 001+(monster_screen_x*001)
monster_size_x       = 32
monster_size_y       = 32
monster_next         = 000+(monster_screen_x*(3+monster_size_y))
monster_nbs_anim     = 16
monster_speed        = 5

explo_o              = 001+(monster_screen_x*141)
explo_size_x         = 70
explo_size_y         = 70
explo_nbs_anim       = 13
explo_speed          = 1

cursor_o             = 486+(screen_x*019)

NBS_BALL_MAX         = 19

option_speed         = 1
option_nbs_anim      = 1

option_off           = 001+(screen_x*827)

next_option          = 26

option_1_o           = 001+(screen_x*752)
option_2_decal       = 001+(screen_x*777)-option_1_o
option_fade_o        = 001+(screen_x*802)

option_3_ball_o      = option_1_o+(next_option*00)
option_6_ball_o      = option_1_o+(next_option*01)
option_9_ball_o      = option_1_o+(next_option*02)
option_20_ball_o     = option_1_o+(next_option*03)
option_death_o       = option_1_o+(next_option*04)
option_new_life_o    = option_1_o+(next_option*05)
option_shoot_o       = option_1_o+(next_option*06)
option_slow_ball_o   = option_1_o+(next_option*07)
option_fast_ball_o   = option_1_o+(next_option*08)
option_iron_ball_o   = option_1_o+(next_option*09)
option_telepod_o     = option_1_o+(next_option*10)
option_night_o       = option_1_o+(next_option*11)
option_small_ship_o  = option_1_o+(next_option*12)
option_large_ship_o  = option_1_o+(next_option*13)
option_reverse_o     = option_1_o+(next_option*14)
option_next_level_o  = option_1_o+(next_option*15)
option_del_monster_o = option_1_o+(next_option*16)
option_magnetic_o    = option_1_o+(next_option*17)
option_add_monster_o = option_1_o+(next_option*18)
option_ghost_o       = option_1_o+(next_option*19)
option_malus_o       = option_1_o+(next_option*20)
option_bonus_o       = option_1_o+(next_option*21)
option_mini_shoot_o  = option_1_o+(next_option*22)
option_collision_o   = option_1_o+(next_option*23)

option_size_x        = 26
option_size_y        = 24
option_pal           = (16*6)+16
option_pal_size      = 16*3

icon_logo_o          = 000+(screen_x*1103)
icon_logo_pos_x      = 0
icon_logo_pos_y      = 0
icon_logo_size_x     = 623
icon_logo_size_y     = 114

brick_o              = 371+(screen_x*008)
brick_size_x         = 226
brick_size_y         = 27
brick_pos_x          = (640/2)-(brick_size_x/2)
brick_pos_y          = 0;87;(480/2)-(brick_size_y/2)+20

panel_info_pos_y     = panel_option_pos_y;282
panel_option_size_x  = 26
panel_option_size_y  = 24
panel_option_pos_x   = bord_x+10
panel_option_pos_y   = 458-12

panel_info_o         = 123+(screen_x*019)
panel_info_cli_o     = 304+(screen_x*019)
panel_info_size_x    = 180
panel_info_size_y    = 22
panel_info_pos_x     = 240
panel_info_pos_y     = panel_option_pos_y;282

panel_level_o        = 001+(screen_x*019)
panel_level_size_x   = 30
panel_level_size_y   = 22
panel_level_pos_x    = 123
panel_level_pos_y    = 009

panel_hiscore_o      = bord_x+(screen_x*(bord_y+22))+8
panel_score_1_o      = 032+(screen_x*019)
panel_score_2_o      = 444+(screen_x*384)
panel_score_size_x   = 90
panel_score_size_y   = 22
panel_score_pos_x    = 426
panel_score_pos_y    = 009

panel_nbs_ball_1_o   = 631+(screen_x*000)
panel_nbs_ball_2_o   = 631+(screen_x*009)
panel_nbs_ball_size_x= 9
panel_nbs_ball_size_y= 9
panel_nbs_ball_pos_x = limite_x-10
panel_nbs_ball_pos_y_1 = 458
panel_nbs_ball_pos_y_2 = 469

vaisseau_1_o        = 000+(screen_x*042)
vaisseau_2_o        = 000+(screen_x*068)
vaisseau_size_x     = 74
vaisseau_size_y     = 25

vaisseau_1_tir_left_o   = 374+(screen_x*183)
vaisseau_1_tir_right_o  = 402+(screen_x*183)
vaisseau_2_tir_left_o   = 374+(screen_x*405)
vaisseau_2_tir_right_o  = 402+(screen_x*405)
vaisseau_decal_x_l      = 7
vaisseau_decal_y_l      = -7
vaisseau_decal_x_r      = vaisseau_size_x-vaisseau_decal_x_l-vaisseau_tir_size_x
vaisseau_decal_y_r      = vaisseau_decal_y_l
vaisseau_tir_size_x     = 12
vaisseau_tir_size_y     = 18
vaisseau_tir_next_shape = (37*screen_x)-vaisseau_tir_size_x
vaisseau_tir_nbs_anim   = 6
vaisseau_tir_speed      = 1

vaisseau_1_tir_big_o    = 446+(screen_x*413)
vaisseau_2_tir_big_o    = 446+(screen_x*435)
vaisseau_decal_x_b      = 31
vaisseau_decal_y_b      = -8
vaisseau_tir_big_size_x = 13
vaisseau_tir_big_size_y = 19
vaisseau_tir_big_next_shape = 1
vaisseau_tir_big_nbs_anim   = 4
vaisseau_tir_big_speed      = 1

vaisseau_explo_size_y     = 70
vaisseau_explo_sub_y      = 24
vaisseau_explo_next_shape = (71*screen_x)
vaisseau_explo_nbs_anim   = 8
vaisseau_explo_speed      = 4

vaisseau_explo_1_o                  = 001+(screen_x*182)
vaisseau_explo_1_size_x             = 118
vaisseau_explo_1_sub_x              = 21

vaisseau_explo_2_o                  = 001+(screen_x*877)
vaisseau_explo_2_size_x             = 118
vaisseau_explo_2_sub_x              = 21

vaisseau_explo_large_1_o            = 213+(screen_x*182)
vaisseau_explo_large_1_size_x       = 143
vaisseau_explo_large_1_sub_x        = 19

vaisseau_explo_large_2_o            = 213+(screen_x*877)
vaisseau_explo_large_2_size_x       = 143
vaisseau_explo_large_2_sub_x        = 19

vaisseau_explo_small_1_o            = 120+(screen_x*182)
vaisseau_explo_small_1_size_x       = 92
vaisseau_explo_small_1_sub_x        = 27

vaisseau_explo_small_2_o            = 120+(screen_x*877)
vaisseau_explo_small_2_size_x       = 92
vaisseau_explo_small_2_sub_x        = 27

vaisseau_large_1_o        = 296+(screen_x*042)
vaisseau_large_2_o        = 296+(screen_x*068)
vaisseau_large_size_x     = 105
vaisseau_large_size_y     = 25

vaisseau_small_1_o        = 506+(screen_x*042)
vaisseau_small_2_o        = 506+(screen_x*068)
vaisseau_small_size_x     = 38
vaisseau_small_size_y     = 25

vaisseau_telepod_size_y     = 43
vaisseau_telepod_sub_y      = 9
vaisseau_telepod_next_shape = (44*screen_x)
vaisseau_telepod_nbs_anim   = 10
vaisseau_telepod_speed      = 1

vaisseau_telepod_red_off_o          = 357+(screen_x*877)
vaisseau_telepod_red_off_size_x     = 92
vaisseau_telepod_red_off_sub_x      = 9

vaisseau_telepod_red_on_o           = 450+(screen_x*877)
vaisseau_telepod_red_on_size_x      = 92
vaisseau_telepod_red_on_sub_x       = 9

vaisseau_telepod_green_off_o        = 357+(screen_x*1317)
vaisseau_telepod_green_off_size_x   = 92
vaisseau_telepod_green_off_sub_x    = 9

vaisseau_telepod_green_on_o         = 450+(screen_x*1317)
vaisseau_telepod_green_on_size_x    = 92
vaisseau_telepod_green_on_sub_x     = 9

vaisseau_telepod_red_small_o        = 543+(screen_x*877)
vaisseau_telepod_red_small_size_x   = 92
vaisseau_telepod_red_small_sub_x    = 27

vaisseau_telepod_green_small_o      = 543+(screen_x*1317)
vaisseau_telepod_green_small_size_x = 92
vaisseau_telepod_green_small_sub_x  = 27

vaisseau_telepod_red_large_o        = 001+(screen_x*1445)
vaisseau_telepod_red_large_size_x   = 127
vaisseau_telepod_red_large_sub_x    = 11

vaisseau_telepod_green_large_o      = 129+(screen_x*1445)
vaisseau_telepod_green_large_size_x = 127
vaisseau_telepod_green_large_sub_x  = 11

ball_blue_o         = 000+(screen_x*000)
ball_orange_o       = 000+(screen_x*009)
ball_size           = 9
next_ball           = 11

Ghost_ball_blue_o   = 018+(screen_x*000)
Ghost_ball_orange_o = 018+(screen_x*009)
Ghost_ball_yellow_o = 027+(screen_x*009)
Ghost_ball_green_o  = 027+(screen_x*009)

brique_beton_o      = 585+(screen_x*029)
next_reflet         = (68*screen_x)
brique_reflet_o     = brique_beton_o+next_reflet
brique_classic_o    = 066+(screen_x*095)
brique_transp_o     = 198+(screen_x*095)
brique_teleport_o   = 231+(screen_x*095)
next_color          = 000+(screen_x*017)
next_brique         = 33
nbs_reflet          = 5
brique_multi_o      = 033+(screen_x*095)
brique_size_x       = 32
brique_size_y       = 16

panel_editor_o      = 456+(screen_x*094)
cursor_editor_o     = 000+(screen_x*163)
panel_editor_size_x = 101
panel_editor_size_y = 238
panel_editor_pos_x  = 535
panel_editor_pos_y  = 016

border_right_o      = 579+(screen_x*514)
border_left_o       = 579+(screen_x*610)
border_size_x       = 42
border_size_y       = 96

;border_right_o      = 559+(screen_x*094)
;border_left_o       = 559+(screen_x*190)
;border_size_x       = 21
;border_size_y       = 96

arrow_o             = 033+(screen_x*163)
arrow_del_o         = 047+(screen_x*163)
arrow_size_x        = 14
arrow_size_y        = 16
arrow_pos_x         = 546
arrow_pos_1         = 22+(18*0)
arrow_pos_2         = 22+(18*1)
arrow_pos_3         = 22+(18*2)
arrow_pos_4         = 22+(18*3)
arrow_pos_6         = 22+(18*4)
arrow_pos_7         = 22+(18*5)
arrow_pos_8         = 22+(18*6)
arrow_pos_9         = 22+(18*7)
arrow_pos_5         = 22+(18*8)

BLOCAGE_COUNTER     = 60
BLOCAGE_COUNTER_2   = 3

nombre_de_coups     = 11111000b
resistance_de_brique= 00011111b

couleur_de_brique   = 11000000b
verte               = 00000000b
bleu                = 01000000b
violet              = 10000000b
orange              = 11000000b

type_de_brique      = 00111000b
normale             = 00100000b
transparente        = 00010000b
incassable          = 00001000b
teleporteuse        = 00011000b

absente             = 00000000b
invalide            = 11111111b

speed_min_x         = 1;+angle  1  2
speed_min_y         = 2;-angle  2  1
speed_max_x         = 14;+angle 14  15
speed_max_y         = 15;-angle 15  14
speed_max           = 15
angle_max           = 1

DELAI_DATTENTE      = 600
DELAI_TELEPOD       = 5
DELAI_OPTION        = 600
DELAI_INFO          = DELAI_OPTION-100
DELAI_INFO_SOUND    = 50
DELAI_DEMO          = 800
DELAI_DEMO_MAX      = -1

screen_x            = 640
screen_y            = 480

Delay_Intro_1       = 60

Sb_Freq             = 44000

off                 = 0
on                  = 1
ball                = 2
vaisseau            = 3
option              = 4
panel               = 5
monster             = 6
shoot               = 7
delete              = -6
profil              = -5
lost                = -4
kill                = -3
first               = -2
last                = -1

bord_x              = 112
bord_y              = 0
limite_x            = 528
limite_y            = limite_x-bord_x
screen_center       = ((limite_x-bord_x)/2)+bord_x

cursor_border       = 23

nbs_brique_x        = ((limite_x-bord_x)/brique_size_x)   ; 13
nbs_brique_y        = (screen_y/brique_size_y)            ; 30

READY_TO_PLAY       = 2
PLAYING             = 3
EDIT                = 4
GAME_OVER           = 5
READY_TO_PLAY_AGAIN = 6
NEW_PLAY            = 7
MENU                = 8

;----------------------------------------------------------------------------
; Macros
;----------------------------------------------------------------------------

Send        macro value,x,y
            if debug_mode
            pushad
            pushfd
            mov edx,value
            mov bx,x
            mov cx,y
            mov ah,Set_Value_Mono
            Int_EOS
            popfd
            popad
            endif
            endm

affiche     macro Text
            if debug_mode
            lea edx,text
            mov ah,9
            int 21h
            endif
            endm

Attente     macro val
local       @@wait
            pushad
            mov ecx,val
@@wait:
            call wait_synchro
            loop @@wait
            popad
            endm

Play_Sound  macro iff
            push ebx
            mov ebx,iff
            call play_sound_track_0_or_1
            pop ebx
            endm

loadsample  macro x
            mov ah,Load_Sample
            mov al,1
            mov edx,O name_iff_&x
            Int_EOS
            mov [iff_&x],eax
            endm