
 move.l 4(sp),a0                ; a0=ecran d'affichage
 move.w 8(sp),d0                ; d0=increment angle

 lea sin_tab,a1                 ; a1=table des sinus
 lea cos_tab,a2                 ; a2=table des cosinus
 lea vit_tab,a5                 ; a5=table des vitesses
 lea mot_tab,a6                 ; a6=table des motifs

 moveq.l #6,d7                  ; Decalage (/64)
 move.l #69,d1                  ; 70 etoiles

etoile:

 move.w d1,d2
 add.w d2,d2
;
;---- angle ----
;
 lea ang_tab(pc),a4
 add.l d2,a4
 move.w (a4),d3                 ; Angle dans d3
 move.w d3,d4                   ; Sauve l'angle dans d4
 add.w d4,d4                    ; angle *2
 move.w 0(a1,d4.w),d5           ; Sin(angle) dans d5
 move.w 0(a2,d4.w),d6           ; Cos(angle) dans d6
 add.w d0,d3                    ; Angle=angle+d0

 cmp.w #359,d3                  ; Angle>359 ?
 ble.s sui1                     ; Non
 clr.w d3                       ; Oui, angle=0
sui1:
 cmp.w #0,d3                    ; Angle<0
 bge.s sui2                     ; Non
 move.l #359,d3                 ; Oui, angle=359
sui2:
 move.w d3,(a4)                 ; Sauve le nouvel angle
;
;---- module ----
;
 lea mod_tab(pc),a4
 add.l d2,a4
 move.w (a4),d3                 ; Module dans d3
 muls d3,d5                     ; Cos(angle)*64*module
 muls d3,d6                     ; Sin(angle)*64*module
 asr.l d7,d5                    ; Cos(angle)*module
 asr.l d7,d6                    ; Sin(angle)*module
 add.l #99,d5                   ; y=99+cos(angle)*module
 add.l #159,d6                  ; x=159+sin(angle)*module

 cmp.w #17,d6
 blt.s newmod
 cmp.w #303,d6
 bgt.s newmod
 cmp.w #23,d5
 blt.s newmod
 cmp.w #176,d5
 bgt.s newmod

; ------------------
; Affichage du point
;-------------------

 move.w 0(a5,d2.w),d2
 add.l d2,d3
 move.w d3,(a4)

 lea (a0),a3
 mulu #160,d5
 move.l d6,d4                         ; x dans d4
 and.w #15,d4                         ; d4=decalage (modulo 16)
 add.w d4,d4                          ; decalage*2
 lsr.w #1,d6                          ; x=(x/2)
 andi #$f8,d6                         ; and -8
 add.w d6,d5
 add.l d5,a3                          ; a3=adresse affichage point
 move.w (a6,d4),d5                    ; motif du point
 or d5,(a3)                           ; motif or fond (couleur 1
 dbf d1,etoile
 rts
newmod:
 move.w #10,(a4)
 dbra d1,etoile
 rts

mot_tab:
 dc.w $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
 dc.w $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001
sin_tab:
 ibytes "COSIN.DAT"
cos_tab:equ sin_tab+720
ang_tab:
 ibytes "ANGTAB.DAT"
mod_tab:
 ibytes "MODTAB.DAT"
vit_tab:
 ibytes "VITTAB.DAT"
 end
 