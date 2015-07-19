; ---------------
; AFSPR16 (V 2.0)
; ---------------
; Routine d'affichage de sprites de 16x16
;  (Codage du sprite sur 3 plans)
;
 move.l 4(sp),d0              ; d0=x
 move.l 8(sp),d1              ; d1=y*160
 move.l 12(sp),a1             ; a1=adresse ecran d'affichage
 move d0,d4                   ; sauve d0
 lea disc(pc),a0              ; a0=adresse des donnees du sprite
 and.l #15,d4                 ; Calcule le decalage (modulo 16)
 lsl.l #8,d4                  ; Decalage*256
 add.l d4,a0                  ; adresse=adresse+decalage*256
 lsr #1,d0                    ; Calcule, a partir de x, la
 andi #$f8,d0                 ; position dans la ligne video
 add d0,d1                    ; x=(x/2) and -8
 adda.l d1,a1                 ; a1=adresse ou sera affiche le sprite
;--- 1 ---
 movem.l (a0)+,d0-d3          ; Chargement des 3 plans + masque
 and d3,(a1)                  ; Affichage du masque
 or d0,(a1)+                  ; Affichage du sprite
 and d3,(a1)                  ; Idem plan 2
 or d1,(a1)+
 and d3,(a1)                  ; Idem plan 3
 or d2,(a1)+
 and d3,(a1)+
 swap d0                      ; Met ce qui a ete decale dans
 swap d1                      ; le mot de poids faible
 swap d2
 swap d3
 and d3,(a1)                  ; Affichage des donnees qui sont
 or d0,(a1)+                  ; sorties lors du decalage
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1                ; Ajuste a1
;--- 2 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 3 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 4 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 5 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 6 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 7 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 8 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 9 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 10 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 11 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 12 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 13 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 14 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 15 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 add.l #144,a1
;--- 16 ---
 movem.l (a0)+,d0-d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)
 rts
; --------------------------------
; Sprite code sur 3 plans + masque
; --------------------------------
 data
disc:
;---- 0 ----
 dc.l $f00f,$2004,$ffff,$ffff0000
 dc.l $f00f,$2004,$ffff,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$ffff,$ffff0000
 dc.l $ffff,$3ffc,$ffff,$ffff0000
 dc.l $ffff,$0000,$ffff,$ffff0000
 dc.l $ffff,$0ffc,$ffff,$ffff0000
 dc.l $ffff,$0ff4,$f80f,$ffff0000
 dc.l $ffff,$0cf4,$fb0f,$ffff0000
 dc.l $ffff,$0cf4,$fb0f,$ffff0000
 dc.l $ffff,$0cf4,$fb0f,$ffff0000
 dc.l $ffff,$0ff4,$f80f,$ffff0000
;---- 1 ----


 