; TUBES.S
; This program creates bouncing raster tubes.
; Access to the MFP is made directly.
; September 1988.
; Anders Skelander
; (0652) 20659 (Sweden).

 MOVE.L A7,A5
 MOVE.L 4(A5),A5
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #$1100,D0
 MOVE.L A5,D1
 ADD.L D0,D1
 AND.L #-2,D1
 MOVE.L D1,A7
 MOVE.L D0,-(SP)
 MOVE.L A5,-(SP)
 MOVE.W D0,-(SP)
 MOVE.W #$4A,-(SP) ; Setblock.
 TRAP #1
 ADD.L #12,SP
 TST.W D0
 BMI TERM

; This is the concept of the bouncing raster tubes:

; Tables needed:
; ANI: A y-position table containing word values for the bounce
;      sequence. Every raster tube passes through this table over
;      and over, but two tubes cannot be started on the very same
;      y-position simultaneously, that is, a table entry is read
;      by only one raster output procedure during the same hblank.
; TPO: A tube position table containing word values that describe
;      which entry in the ANI table is to be read for each tube.
;      ANI and TPO are used together, TPO tells where in ANI the
;      current tube start position y-coordinate entry is located.
;
; RAS: This table contains 200 words, each entry corresponds to
;      the colour of the background on the 200 screen lines.
;
; Initialisation:
; Allocate memory for ANI, 2*12 bytes.
; Allocate memory for TPO, 2*5 bytes.
; Allocate memory for RAS, 2*200 bytes.
; These three allocation calls are simple enough to share one area.
; * MALLOC 2*12+2*5+2*200=24+10+400=434 bytes.
 MOVE.L #434,-(SP)    ; Number of bytes to reserve.
 MOVE.W #$48,-(SP)    ; Malloc.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,ANIVEC
 ADD.L #24,D0
 MOVE.L D0,TPOVEC
 ADD.L #10,D0
 MOVE.L D0,RASVEC

 LEA BOUSEQ,A0        ; Copy data into dynamic bounce animation area.
 MOVE.L ANIVEC,A1
 MOVE.L #12-1,D0      ; 12 entries to copy.
COPYANI:
 MOVE.W (A0)+,(A1)+
 DBRA D0,COPYANI

; Enable raster interrupt:

 MOVE.L $70,-(SP)          ; Save old VBL vector.
 MOVE.L $120,-(SP)         ; Save old HBL vector.
 MOVE.B $FFFA1B,-(SP)      ; Save timer B control status.
 CLR.B $FFFA1B             ; Stop timer B.
 MOVE.B #255,$FFFA21       ; B counts to #255, VBL will appear sooner.
 MOVE.B $FFFA09,-(SP)      ; Save old IERB register contents.
 AND.B #$DF,$FFFA09        ; Disable timer D interrupt.
 MOVE.L #HBL,$120          ; Set new HBL vector.
 BSET #0,$FFFA07           ; Enable timer B.
 BSET #0,$FFFA13           ; Mask interrupt (on).
 MOVE.B #8,$FFFA1B         ; Set timer B control.
 MOVE.L #VBL,$70           ; Set VBL vector.

; Wait for keypress.

 MOVE.W #7,-(SP)
 TRAP #1
 ADDQ.L #2,SP

; Diable raster interrupt.

 MOVE.B (SP)+,$FFFA09      ; Restore IERB register contents.
 MOVE.B (SP)+,$FFFA1B      ; Restore timer B control status.
 MOVE.L (SP)+,$120         ; Restore HBL vector.
 MOVE.L (SP)+,$70          ; Restore VBL vector.

; Leave program.

TERM:
 CLR.W -(SP)
 TRAP #1

; The interrupt routines:

VBL:
 MOVE.L RASVEC,A0    ; Clear RAS table.
 MOVE.L #199,D0
CLRRAS:
 CLR.B (A0)+
 DBRA D0,CLRRAS
 MOVE.L TPOVEC,A0    ; Tube position table address into A0.
 CLR.W D2            ; D2 is tube counter.
ALLTUBES:
 MOVE.W (A0,D2.W),D0 ; Tube position value into D0.
 MOVE.L ANIVEC,A1    ; Bounce animation data address into A1.
 MOVE.W (A1,D0.W),D1 ; Move actual tube start position into D1.
 BSR DRAWTUB
 ADD.W #2,D2         ; Increase tube number.
 CMPI.W #10,D2       ; Have we reached the last tube?
 BNE.S ALLTUBES      ; Branch if not.
 RTE                 ; Return from exception.
DRAWTUB:
 MOVEM.L D0/A0-A1,-(SP)
 LEA TUBDAT,A0
 MOVE.L RASVEC,A1
 MOVE.L #15,D0
PUTCOL:
 MOVE.W (A0)+,(A1)+
 DBRA D0,PUTCOL
 MOVEM.L (SP)+,D0/A0-A1
 RTS

HBL:
 MOVEM.L D0/A0,-(SP)
 MOVE.W COUNTER,D0
 LEA $FF8240,A0
 MOVE.W (A0,D0.W),$FF8240
 MOVEM.L (SP)+,D0/A0
 CLR.B $FFFA1B
 MOVE.B #1,$FFFA21
 MOVE.B #8,$FFFA1B
 BCLR #0,$FFFA0F
 RTE

; Quitting:
;
; Addresses and data:
 ALIGN
; The table vectors:
ANIVEC: DS.L 1
TPOVEC: DS.L 1
RASVEC: DS.L 1
COUNTER: DS.W 1
; Bounce sequence y-positions:
BOUSEQ: DC.W 0,6,11,15,18,20,21,20,18,15,11,6,-1
; Tube colour shading data:
TUBDAT: DC.W $000,$111,$222,$333,$444,$555,$666,$777
        DC.W $777,$666,$555,$444,$333,$222,$111,$000

 END

 