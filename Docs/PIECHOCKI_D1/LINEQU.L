         
; D�finition des EQUIVALENCES du TABLEAU INTERNE des LineAs

; NOM de la valiable  =   D�placement relatif

v_planes        EQU       0                ;nombre de plans
v_lin_wr        EQU       2                ;octet par ligne d'�criture
ticontrol       EQU       4                ;adresse du T.I de CONTROL
tiintin         EQU       8                ;adresse du T.I de INTIN
tiptsin         EQU       12               ;adresse du T.I de PTSIN
tiintout        EQU       16               ;adreses du T.I de INTOUT
tiptsout        EQU       20               ;adresse du T.T de PTSOUT
_fg_bp_1        EQU       24               ;bit 0 de la couleur
_fg_bp_2        EQU       26               ;bit 1 de la couleur
_fg_bp_3        EQU       28               ;bit 2 de la couleur
_fg_bp_4        EQU       30               ;bit 3 de la couleur
_lstlin         EQU       32               ;toujours =-1
_ln_mask        EQU       34               ;forme de la ligne pour $A003
_wrt_mode       EQU       36               ;WRITE MODE
_x1             EQU       38               ;Coordonn�e X du premier point
_y1             EQU       40               ;Coordonn�e Y du premier point
_x2             EQU       42               ;Coordonn�e X du second point
_y2             EQU       44               ;Coordonn�e Y du second point
_patptr         EQU       46               ;adresse du remplissage
_patmsk         EQU       50               ;nombre de remplissage
_multifill      EQU       52               ;d�tails plus loin
_clip           EQU       54               ;drapeau de clipping
_xmn_clip       EQU       56               ;X le + � gauche pour le clip
_ymn_clip       EQU       58               ;Y le + haut pour le clip
_xmx_clip       EQU       60               ;X le + � droite pour le clip
_ymx_clip       EQU       62               ;Y le + bas pour le clip
_xacc_dda       EQU       64               ;pointe sur $8000 pour TXTBLT  
_dda_inc        EQU       66               ;facteur d'agrandissement=$FFFF
_t_sclsts       EQU       68               ;=0                   
_mono_status    EQU       70               ;type de TEXT EFFECTS
_sourcex        EQU       72               ;Nr du caract�re dans le JEU  
_sourcey        EQU       74               ;=0  
_destx          EQU       76               ;Coordonn�e X du TEXT
_desty          EQU       78               ;Coordonn�e Y du TEXT  
_delx           EQU       80               ;Largeur du caract�re  
_dely           EQU       82               ;Hauteur du caract�re
_fbase          EQU       84               ;Adresse du JEU  
_fwidth         EQU       88               ;X du JEU
_style          EQU       90               ;FLAG pour TEXT EFFECTS  
_litemark       EQU       92               ;Masque des ombrages  
_skewmask       EQU       94               ;Masque de l'inclinaison TEXT
_weight         EQU       96               ;NB de bits d'�largissement  
_r_off          EQU       98               ;D�calage pour TEXT italique 
_l_off          EQU       100              ;idem cot� gauche (Left)  
_scale          EQU       102              ;Flag agrandissement (1/0)       
_chup           EQU       104              ;Angle de rotation du TEXT  
_txt_fg         EQU       106              ;Couleur du 1� plan du TEXT  
_scrtchp        EQU       108              ;Adresse d'1 tampon pour effets  
_scrpt2         EQU       112              ;D�calage pour l'agrandissement  
_text_bg        EQU       114              ;Couleur de Back Ground du TEXT  
_copytran       EQU       116              ;FLAG pour le mode d'�criture  

                END

 