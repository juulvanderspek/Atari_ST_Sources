; SUN INTRO coded by epsilon in one hour
; this summer 1989
; and source code for Overlanders compil code
 jsr init
 jsr decomp_pic
 jsr aff_pal
 moveq #0,d0
 jsr music+$4e2
 move.l $70,vbl_jmp
 move.l #vbl,$70
LOOP:
 move.w #$b,-(sp)
 trap #1
 addq.l #2,sp
 tst.w d0
 beq.s loop
 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 cmp.b #32,d0
 bne.s loop
 move.l vbl_jmp,$70
 move.l $42e,a1
 sub.l #$100,a1
 LEA CODE,A0
 MOVE.W #FIN_CODE-CODE,D0
INST_CD:
 MOVE.B (A0)+,(A1)+
 DBRA D0,INST_CD
 move.B #8,$fffffc02
 clr.w -(sp)
 trap #1
CODE:
 DC.B "OKCracked 89 by KRONOS",0
FIN_CODE:
 ALIGN.W
init:
 clr.w -(sp)
 pea $78000
 pea $78000
 move.w #5,-(sp)
 trap #14
 lea 12(sp),sp
 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.b #$12,$fffffc02
 move.w #$8240,a0
 moveq #15,d0
inits1:
 clr.w (a0)+
 dbra d0,inits1
 rts
pt_vbl:
 dc.w 0
vbl:
 movem.l d0-a6,-(sp)
 add.w #1,pt_vbl
 jsr scroll
 jsr music+$28
 movem.l (sp)+,d0-a6
 rte
 dc.w $4ef9
vbl_jmp:
 dc.l -1
scroll:
 cmp.w #$10,pt_lettre
 bne.s scroll1
 clr.w pt_lettre
scroll6:
 lea ad_message,a1
 move.l (a1),a0
scroll3:
 clr.l d0
 move.b (a0),d0
 bne.s scroll2
 move.l #mess_16,(a1)
 lea mess_16,a0
 bra.s scroll3
scroll2:
 addq.l #1,(a1)
 lea $70000,a0
 subi.b #32,d0
scroll4:
 cmp.b #20,d0
 blt.s scroll5
 add.l #2560,a0
 sub.b #20,d0
 bra scroll4
scroll5:
 asl.w #3,d0
 adda.l d0,a0
 lea $70000+12800,a1
 moveq #15,d0
scroll7:
 movem.l (a0),d1-d2
 movem.l d1-d2,(a1)
 lea 160(a0),a0
 lea 160(a1),a1
 dbra d0,scroll7
scroll1:
 lea $70000+12800,a1
 lea $70000+15360,a2
 adda.l #$98,a2
 moveq #15,d5
 move.w vitesse,d3
K00000=3
K00001=0
K00002=-8
K00003=-$10
K00004=-$18
K00005=-$20
K00006=-$28
K00007=-$30
K00008=-$38
K00009=-$40
K0000A=-$48
K0000B=-$50
K0000C=-$58
K0000D=-$60
K0000E=-$68
K0000F=-$70
K00010=-$78
K00011=-$80
K00012=-$88
K00013=-$90
K00014=-$98
K00016=$98
L00017:MOVEQ #K00000,D1
L00015:MOVEQ #K00001,D0
 MOVE.W (A1),D0
 LSL.L D3,D0
 MOVE.W D0,(A1)+
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W (A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -8(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-8(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$10(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$10(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$18(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$18(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$20(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$20(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$28(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$28(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$30(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$30(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$38(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$38(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$40(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$40(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$48(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$48(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$50(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$50(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$58(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$58(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$60(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$60(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$68(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$68(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$70(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$70(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$78(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$78(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$80(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$80(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$88(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$88(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -$90(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-$90(A2)
 MOVE.L D4,D0
 SWAP D0
 MOVEQ #K00001,D4
 MOVE.W -K00016(A2),D4
 LSL.L D3,D4
 OR.W D0,D4
 MOVE.W D4,-K00016(A2)
 ADDQ.L #2,A2
 DBRA D1,L00015
 ADDA.L #K00016,A2
 adda.l #k00016,a1
 DBRA D5,L00017
 ADD.W D3,pt_lettre
 lea $70000+15360,a0
 lea $78000+26560,a1
 moveq #14,d0
scroll8:
 move.l a0,a2
 move.l a1,a3
 moveq #0,d1
 moveq #1,d4
 moveq #19,d2
 move.l #160,d3
scroll9:
 move.l (a2)+,(a3)+
 move.l (a2)+,(a3)+
 add.l d3,a3
 add.w d4,d1
 cmp.w #8,d1
 bne.s scroll10
 moveq #-1,d4
 neg.l d3
scroll10:
 cmp.w #0,d1
 bne.s scroll11
 moveq #1,d4
 neg.l d3
scroll11:
 dbra d2,scroll9
 lea 160(a0),a0
 lea 160(a1),a1
 dbra d0,scroll8
 rts
aff_pal:
 move.w #$8240,a1
 lea pic1+2,a0
 moveq #15,d0
aff_pals1:
 move.w (a0)+,(a1)+
 dbra d0,aff_pals1
 rts
decomp_pic:
 lea pic1+34,a5
 lea $78000,a3
 jsr dec10
 lea pic2+34,a5
 lea $70000,a3
dec10:
 move.l #$c7,d4
 move.l #6,a0
 moveq #4,d6
 moveq #$28,d7
dec9:
 clr.b d1
 move.l a3,a4
dec8:
 move.l a4,-(sp)
 clr.b d3
dec7:
 move.b (a5)+,d0
 tst.b d0
 bmi.s dec1
 addq.b #1,d0
dec3:
 move.b (a5)+,(a4)+
 addq.b #1,d3
 move.l a4,d5
 btst #0,d5
 bne.s dec2
 add.l a0,a4
dec2:
 subq.b #1,d0
 bne.s dec3
 bra.s dec4
dec1:
 neg.b d0
 addq.b #1,d0
 move.b (a5)+,d2
dec6:
 move.b d2,(a4)+
 addq.b #1,d3
 move.l a4,d5
 btst #0,d5
 bne.s dec5
 add.l a0,a4
dec5:
 subq.b #1,d0
 bne.s dec6
dec4:
 cmp.b d7,d3
 BNE.S DEC7
 move.l (sp)+,a4
 addq.l #2,a4
 addq.b #1,d1
 cmp.b d6,d1
 bne.s dec8
 add.l #$a0,a3
 dbra d4,dec9
 rts
music:
 ibytes 1943.b
screen1:
 dc.l $78000
vitesse:
 dc.w 4
pt_lettre:
 dc.w 16
ad_message:
 dc.l mess_16
mess_16:
 dc.b "   OVERLANDERS COMPIL CODE             "




 DC.B 0
 ALIGN.W
pic1:
 ibytes overpic6.pc1
 align.w
pic2:
 ibytes over_fnt.pc1
 end
  