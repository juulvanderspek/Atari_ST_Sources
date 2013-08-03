;---------------------------------------------------------------
; Doom'ish Wolfie math.. second version still by WizTom?
;---------------------------------------------------------------
; feed sin(alfa),cos(alfa),x_position,y_position,number of walls
; x1,z1,x2,z2,txt number (15-bit positive map, same for x/y_position)
; fucked up non signed maths.. finally?
; gone insane of Dvl-buggering..
; fixed getcord error, no more wild x:ram terror..
; wild sort

PBC		equ	$ffe0
HSR		equ	$ffe9
HTX		equ	$ffeb

dee		equ	$11500		;277*256 (277/320 -> 60 astetta)
txt_high	equ	128
txt_wide	equ	128		;vakioleveys kaikille textureille
buf_wide	equ	384
dyy		equ	277*txt_high
	
	org	p:$200

start	

secure	movep	#1,X:PBC
	jclr	#0,x:HSR,secure
	move	x:HTX,a
	lsl	a	
	movep	#0,x:$fffe		;port a (luku tahtoo t�kki� ilman..)
secure2	jclr	#1,X:HSR,secure2
	move	a1,X:HTX		

main
	move	#$ffff,m0
	move	#$ffff,m1
	move	#$ffff,m2
	move	#$ffff,m3
	move	#$ffff,m4
	move	#$ffff,m5
	move	#$ffff,m6
	move	#$ffff,m7

;	jsr	get_cords
	jsr	scroll
	jsr	rotate
;	jsr	sort
	jsr	sort2
;	jsr	clear_z_buffer
	jsr	project_Walls
	jsr	scale_z_buffer
	jsr	write_z_buf

	jmp	main
;---------------------------------------
get_cords
g_sin	movep	#1,x:PBC
	jclr	#0,X:HSR,g_sin
	move	X:HTX,x0
	move	x0,x:sin

g_cos	movep	#1,x:PBC
	jclr	#0,X:HSR,g_cos
	move	X:HTX,x0
	move	x0,x:cos	

g_x	movep	#1,x:PBC
	jclr	#0,X:HSR,g_x
	move	X:HTX,x0
	move	x0,x:x_pos

g_z	movep	#1,x:PBC
	jclr	#0,X:HSR,g_z
	move	X:HTX,x0
	move	x0,x:z_pos

num	movep	#1,x:PBC
	jclr	#0,X:HSR,num
	move	X:HTX,x0	
	move	x0,x:number_of_walls	

	move	#cords_of_walls,r0	
	do	x0,get_data

g_x1	movep	#1,x:PBC
	jclr	#0,X:HSR,g_x1
	move	X:HTX,x:(r0)+
g_z1	movep	#1,x:PBC
	jclr	#0,X:HSR,g_z1
	move	X:HTX,x:(r0)+

g_x2	movep	#1,x:PBC
	jclr	#0,X:HSR,g_x2
	move	X:HTX,x:(r0)+
g_z2	movep	#1,x:PBC
	jclr	#0,X:HSR,g_z2
	move	X:HTX,x:(r0)+

g_txt	movep	#1,x:PBC
	jclr	#0,X:HSR,g_txt
	move	X:HTX,x:(r0)+
	nop
get_data

	rts
;---------------------------------------
write_z_buf
	move	#z_buf,r0
	do	#buf_wide,hard

w1	jclr	#1,X:HSR,w1
	move	x:(r0)+,X:HTX		
w2	jclr	#1,X:HSR,w2
	move	x:(r0)+,X:HTX		
w3	jclr	#1,X:HSR,w3
	move	x:(r0)+,X:HTX		
	nop
	nop
hard
	rts
;---------------------------------------
scale_z_buffer
	move	#z_buf,r0
	move	#2,n0
	move	#>buf_wide,x0
	do	x0,jekku
	move	x:(r0),a
	rep	#8
	asr	a
	move	a1,x:(r0)+		;zeta

	move	x:(r0),a		;txt
;	rep	#8
;	asr	a
	move	a1,x:(r0)+

	move	x:(r0),a		;x offse in txtt
	rep	#8
	asr	a
	move	a1,x:(r0)+
jekku
	rts
;---------------------------------------
clear_z_buffer
	move	#z_buf,r0
	move	#>buf_wide,x0
	move	#>$0,x1
	do	x0,tyhjaa
	move	x1,x:(r0)+
	move	x1,x:(r0)+
	move	x1,x:(r0)+
tyhjaa
	rts
;---------------------------------------
rotate
	move	#cords_of_walls,r0
	move	#2,n0

	move	x:sin,x1
	move	x:cos,y1
	move	x:number_of_walls,x0
	do	x0,kesy
;------
	move	x:(r0)+,x0
	mpy	x0,y1,a		x:(r0)-,y0
	mac	y0,x1,a				;x*cos+z*sin (x1)

	mpy	y0,y1,b		a1,x:(r0)+
	mac	-x0,x1,b			;z*cos-x*sin (z1)
	move	b1,x:(r0)+

	move	x:(r0)+,x0
	mpy	x0,y1,a		x:(r0)-,y0
	mac	y0,x1,a				;toka piste

	mpy	y0,y1,b		a1,x:(r0)+
	mac	-x0,x1,b			
	move	b1,x:(r0)+n0
kesy
	rts
;---------------------------------------
sort
	move	#sorted_walls,r1	;copy dest
	move	#cords_of_Walls,r0
	move	#2,n0
	move	#0,r7
; zek if visible, copy r0 -> r1
	move	x:number_of_walls,x0
	do	x0,kelaa_kaikki
;----
	nop
	move	r0,r2			;source base
	move	x:(r0)+,x0		;x1
	move	x:(r0)+,b		;z1
	move	x:(r0)+,a		;x2
	sub	x0,a
	jle	rankkaa			;tapa nollapituudet!

	tst	b
;	jgt	eka_ok
	jlt	rankkaa
	move	x:(r0),b			;z2
	tst	b
	jlt	rankkaa
eka_ok		
	nop
	move	x:(r2)+,x0
	move	x0,x:(r1)+
	move	x:(r2)+,x0
	move	x0,x:(r1)+		;copy x1,z1

	move	x:(r2)+,x0
	move	x0,x:(r1)+
	move	x:(r2)+,x0
	move	x0,x:(r1)+		;x2,z2

	move	x:(r2)+,x0
	move	x0,x:(r1)+		;txt

	move	(r7)+			;inc destcount

rankkaa
	move	(r0)+n0
	nop
	nop
kelaa_kaikki
	move	r7,x:number_of_walls
	rts
;---------------------------------------
sort2
	move	#sorted_walls,r1	;copy dest
	move	#cords_of_Walls,r0
	move	x:number_of_walls,x0
	do	x0,kelaa_kaikki2
;----
	move	x:(r0)+,x0
	move	x:(r0)+,b
	move	x:(r0)+,a
	cmp	x0,a
	jge	no_backside

	move	a,x1
	move	x:(r0)+,a
	abs	a
	abs	b
	move	x1,x:(r1)+
	move	a,x:(r1)+
	move	x0,x:(r1)+
	move	b,x:(r1)+
	jmp	far_out	

no_backside
	abs	b
	move	x0,x:(r1)+
	move	b,x:(r1)+
	move	a,x:(r1)+
	move	x:(r0)+,a
	abs	a
	move	a,x:(r1)+
far_out
	move	x:(r0)+,x0
	move	x0,x:(r1)+		;txt
;----
kelaa_kaikki2
	rts
;---------------------------------------

scroll
	move	x:x_pos,x0
	move	x:z_pos,y0
	move	#cords_of_Walls,r0
	move	#2,n0
	move	x:number_of_walls,x1
	do	x1,mega

	move	x:(r0)+,a
	sub	x0,a		x:(r0)-,b
	rep	#8
	asl	a				;scroll map and conv to 24bit
	sub	y0,b		a1,x:(r0)+
	rep	#8
	asl	b
	move	b1,x:(r0)+

	move	x:(r0)+,a
	sub	x0,a		x:(r0)-,b
	rep	#8
	asl	a				;toka piste..
	sub	y0,b		a1,x:(r0)+
	rep	#8
	asl	b
	move	b1,x:(r0)+n0			;skip txt
	nop
mega
	rts
;---------------------------------------
project_walls
	move	#sorted_walls,r0
	move	#z_buf,r7
	move	#3,n6
	move	x:number_of_walls,a
	tst	a
	jeq	zero_wall			;all walls killed in sort!
	do	a,bring_the_beat_back

; laske x1:n projection

	move	#>dee,y0			;(15.8)
	move	x:(r0)+,x0			;(15.8)
	mpy	y0,x0,a		x:(r0)+,b	;d*x1 (15.8 -> 32.17)
	rep	#2
	asr	a				;
	add	y0,b				;d+z1 (16.8)
	asr	b
	move	b1,x0
	move	b1,x:eka_zeta			;(16.7)

	jsr	jako				;a/x0 (tnx 2 dee, a<x0)
	move	a0,a
	rep	#8
	asr	a
	move	#>(buf_wide/2),x0
	add	x0,a	
	move	a1,x:vasen_reuna		;
	move	a1,y1				;y1=vasen reuna
; laske x2 projectio
	move	#>dee,y0
	move	x:(r0)+,x0
	mpy	y0,x0,a		x:(r0)+,b	;d*x1
	rep	#2
	asr	a		
	add	y0,b				;d+z1		
	asr	b	
	move	b1,x0
	move	b1,x:toka_zeta

	jsr	jako				;oikea reuna
	move	a0,a				;
	rep	#8
	asr	a
	move	#>(buf_wide/2),x0
	add	x0,a
	
	move	x:(r0)+,m5			;get txt
	sub	y1,a		a,x:oikea_reuna	 ;wide in z_buf
	jle	zero_wall			 ;PIIRRETAANKO NOLLAA?!
	
; laske x1,z1 korkeus

	move	x:eka_zeta,x0			;d + z1 (16.7)
	move	#>dyy,a				;d * max_y (16)	
	rep	#8
	asr	a
	jsr	jako
	move	a0,a
	asr	a
	move	a1,x:eka_zeta			;korkeus 0-127 (15.8)

; laske x2,z2 korkeus

	move	x:toka_zeta,x0			;d + z1 / 2
	move	#>dyy,a				;d * max_y /2	
	rep	#8
	asr	a
	jsr	jako
	move	a0,a
	asr	a
	move	a1,x:toka_zeta			;korkeus 0-127 (8.8)

; laske x_stepit

	move	x:oikea_reuna,a
	move	x:vasen_reuna,x0
	sub	x0,a
	move	a,x0				;(16.0)
	move	#>txt_wide,a
	rep	#8
	asr	a
	jsr	jako				;x step (txt/z_buffeilla)
	move	a0,a
	rep	#8
	asr	a	
	move	a1,x:x_step			;(8.8)

; laske z stepit

	move	x:toka_zeta,a
	move	x:eka_zeta,x1			;(15.8)
	sub	x1,a		x0,x:z_buf_wide ;korkeus steppi,rendaus leveys muistiin
	rep	#16
	asr	a
	jsr	jako				;jakaja (9.0)
	move	a0,a
	rep	#8
	asr	a
	move	a1,x:z_step			;(8.8)

; clippaa oikea
	move	#>buf_wide,x1
	move	x:vasen_reuna,b
	sub	x1,b
	jgt	zero_wall			;vasen ulkona oikealta

	move	x:oikea_reuna,b
	sub	x1,b
	jlt	no_oikea_clip			;oikea yli?
	
	move	b1,x1
	move	x0,a
	sub	x1,a
	move	a1,x0				;wombla new wide.. 
	move		x0,x:z_buf_wide
no_oikea_clip

; clippaa vasen
	move	x:oikea_reuna,a
	tst	a
	jle	zero_wall			;oikea ulkona vasemmalta

	clr	b	x:vasen_reuna,a
	tst	a
	jge	no_vasen_clip

	not	a	x0,b			;z_wide x0:ssa..
	move	a1,x1				;x1 - hukattu seinapala..
	sub	x1,b		x:eka_zeta,a0	;new wide.. (zeta 15.8)
	move	x:z_step,x0			;(8.8)
	asl	a	b1,x:z_buf_wide	
	mac	x1,x0,a
	asr	a			;z_base+overflow*z_step (8.8)
	move	a0,x:eka_zeta
	
	move	x:x_step,x0
	mpy	x1,x0,b
	asr	b			;x_base+ovari*x_step,8bit dec	
	clr	a	b0,b
no_vasen_clip
	move	a1,x1			;lis�� x1*3 z_buffin alkuun
	add	x1,a
	add	x1,a
	move	a1,n7
	move	x:z_step,x0	
	move	x:x_step,y0
	lua	(r7)+n7,r6			;x in z_buf * 3
	move	x:z_buf_wide,a
	move	#>$1ff,x1		;mask wide
	and	x1,a
	move	a,n5
	move	x:eka_zeta,a
	do	n5,lusifer_rulz
;--------
	add	x0,a				;z_step (korkeus)
	add	y0,b				;inc txt_off

	move	x:(r6),x1
	cmp	x1,a				;seinakorkeus-zeta!!
	jlt	kauempana

	move	a1,x:(r6)+
	move	m5,x:(r6)+
	move 	b1,x:(r6)+			;write new z, txt, x_offset
	move	(r6)-n6
kauempana
	move	(r6)+n6
	nop
	nop
lusifer_rulz					;z_buffer loop end
;----------
	nop
zero_wall
	nop
	nop
	nop

bring_the_beat_back
	move	#$ffff,m5
	rts
;---------------------------------------
jako
	andi	#$fe,ccr			;clear carry
	rep	#24
	div	x0,a
	asl	a
	jclr	#23,x0,pos_diver
	neg	a
pos_diver
	rts					;signed result in a0 

;	rep	#12
;	asr	a
;	andi	#$fe,ccr			;clear carry
;	rep	#24
;	div	x0,a
;	asl	a
;	jclr	#23,x0,pos_diver
;	neg	a
;pos_diver
;-------------------------------------------
;-------------------------------------------
;write	jclr	#1,X:HSR,securex
;	move	x0,X:HTX		
;
;read	movep	#1,x:PBC
;	jclr	#0,X:HSR,read
;	move	X:HTX,x0		
;--------------
	org	x:$0

spare		ds	1
number_of_walls	dc	2
		;ds	1
sin		dc	$1a9c00
		;ds	1
cos		dc	$7d3200
		;ds	1
x_pos		dc	$40c3
		;ds	1
z_pos		dc	$d67
		;ds	1
vasen_reuna	ds	1
oikea_reuna	ds	1
eka_zeta	ds	1
toka_zeta	ds	1
x_step		ds	1
z_step		ds	1
z_buf_wide	ds	1
cords_of_Walls	
		dc	$4000,$1000
		dc	$4100,$1000,$fac
		dc	$4100,$1000
		dc	$4100,$1100,$dac
		ds	5*100			;x,z,txt
sorted_walls	ds	5*100
z_buf		ds	buf_wide*3			;z(eta),txt,x_offset
	end
	



