;
; Fichier include-Datei pour d�claration � l'AES/VDI d'un accessoire
; Assembler                             ACC_INEX.ASM
;

;Ce fichier peut �tre utilis� dans vos applications avec
;Include, qui devra �tre la premi�re instruction du texte
;source en assembleur

;Diff�rences avec GEM_INIT et GEM_INEX:
;Un accessoire ne doit pas lib�rer de m�moire par
;Setblock/Mshrink. Une seule pile de taille suffisante (4 Ko)
;est cr�e.


               .TEXT 

               lea.l      stackend,sp   ;Cr�er pile
               jmp        main          ;Saut dans l'application

; Sous-programmes aes et vdi

aes:           move.l     #aespb,d1     ;Bloc de param�tres AES
               move.w     #$c8,d0       ;Nombre "magique" pour l'AES
               trap       #2            ;Appel GEM
               rts        

vdi:           move.l     #vdipb,d1     ;Bloc de param�tres VDI
               move.w     #$73,d0       ;Code pour la VDI
               trap       #2            ;Appel GEM
               rts        

gem_init:                 ;appel avant le premier call GEM

;D�claration � l'AES (appl_init):

               move.w     #10,control   ;appl_init (AES)
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes
               move.w     int_out,ap_id ;Stocker l'identification

;D�clarer l'�cran comme station de travail (VDI):

               moveq.l    #18,d0        ;pr�parer intin
               lea.l      intin,a0
gi_lp:         move.w     #1,0(a0,d0.w) ;Mettre �l�ment � 1
               subq.w     #2,d0         ;�l�ment
               bpl.s      gi_lp         ;Fin?
               move.w     #2,20(a0)     ;Drapeau de coordonn�es (toujours 2)

               move.w     #100,contrl   ;v_opnvwk (VDI)
               clr.w      contrl+2
               move.w     #12,contrl+4
               move.w     #11,contrl+6
               move.w     #45,contrl+8
               jsr        vdi
               move.w     contrl+12,handle        ;Handle graphique VDI

               move.w     intout,x_max  ;Stockage de la r�solution
               move.w     intout+2,y_max
               rts        


gem_exit:                 ;Appeler avant de quitter le programme

               move.w     #101,contrl   ;v_clsvwk (VDI)
               clr.w      contrl+2
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               jsr        vdi

               move.w     #19,control   ;appl_exit (AES)
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes
               rts        

; Les blocs de param�tres suivent:

               .DATA 

aespb:         .DC.l control
               .DC.l global
               .DC.l int_in             ;Diff�rence entre les tableaux
               .DC.l int_out            ;d'entiers AES et VDI: _
               .DC.l addr_in
               .DC.l addr_out

vdipb:         .DC.l contrl
               .DC.l intin
               .DC.l ptsin
               .DC.l intout
               .DC.l ptsout

; Voici les tableaux proprement dits:

               .BSS 

global:        .DS.w 16   ;AES
control:       .DS.w 10
int_in:        .DS.w 128
int_out:       .DS.w 128
addr_in:       .DS.l 128
addr_out:      .DS.l 128

contrl:        .DS.w 12   ;VDI
intin:         .DS.w 128
ptsin:         .DS.w 128
intout:        .DS.w 128
ptsout:        .DS.w 128

stack:         .DS.w 2000
stackend:      

ap_id:         .DS.w 1    ;ap_id, fourni par appl_init

handle:        .DS.w 1    ;Handle graphique VDI

x_max:         .DS.w 1    ;R�solution de l'�cran, obtenue
y_max:         .DS.w 1    ;par v_opnvwk

               .TEXT 

               .END 
