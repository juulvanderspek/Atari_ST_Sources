;
; DECOUPEUR DE DIGIT
;
LOAD=$40000
	LEA	LOAD,A6

O:
	MOVEQ	#0,D0
	MOVE	(A6),D0
	ADD.L	#LOAD,D0
	MOVE.L	D0,A0

	ADDQ	#8,A6

	MOVEQ	#0,D0
	MOVE	(A6),D0
	ADD.L	#LOAD,D0
	MOVE.L	D0,A1

DEL:	CMP.B	#$FF,-(A1)
	BEQ.S	DEL
	ADDQ	#2,A1


	MOVE	A1,D0
	SUB	A0,D0
	LSR	#1,D0
	BCC.S	PAIR
	ADDQ	#1,A1
PAIR:
	ILLEGAL
