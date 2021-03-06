 ;*****************************************
 ;  AUTOPSY.TOS  -- THE ST CRASH CORONER
 ;
 ;        by S. M. Baugh  --  5/87
 ;
 ;*****************************************

 TEXT

 ILABEL MACLIB\DOS.L                   ; TOS calls macro library
 ILABEL MACLIB\CONVERT.L               ; my macros
 ILABEL MACLIB\IO.L

proc_lives   =     $380                ; -> Hitchhiker's Guide p. 38
proc_dregs   =     $384
proc_aregs   =     $3A4
proc_enum    =     $3C4
proc_usp     =     $3C8
proc_stk     =     $3CC
magic        =     $12345678

crashchk:
         SUPER     #newssp             ; let's do super programming
         move.l    d0,oldssp           ; save old ssp

         PRINTLINE #title              ; print title with Cconws

         cmpi.l    #magic,proc_lives   ; has there been a crash?
         beq.s     main                ; yes
         PRINTLINE #nocrash            ; no
         CONIN                         ; wait for keypress
         jmp       nosuper             ; back to user mode & exit

main:
         BINHEX_B  #proc_enum,#hexbuff ; determine ascii for bomb #
         PRINTLINE #msg1               ; print bomb msg
         lea       exceptab,a0         ; address of exception table
         clr.l     d0
         move.b    proc_enum,d0        ; use exception # as address...
         mulu      #4,d0               ; ...index for exception ID
         cmpi.l    #$24,d0             ; is bomb < 9 ($24=4*9)?
         blt       main2               ; no, then proceed
         clr.l     d0                  ; yes, so print 1st message

main2:
         move.l    0(a0,d0),emadd      ; set up error msg address to
         PRINTLINE emadd              ; print correct exception msg

         move.l    #proc_dregs,a0      ; initialize addresses
         move.l    #proc_aregs,a1
         move.l    #proc_stk,a2
         lea       outtab,a6           ; hex output addr table
         move.l    #7,d6               ; loop counter

mloop:                                 ; convert values to ASCII
         movea.l   a0,a5               ; set up input address
         bsr       convert_l           ; convert bin to ASCII
         addq.l    #4,a0               ; reset input address
         addq.l    #4,a6               ; reset output address
         movea.l   a1,a5               ; next bin # address
         bsr       convert_l
         addq.l    #4,a1
         addq.l    #4,a6
         movea.l   a2,a5
         bsr       convert_l
         addq.l    #4,a2
         addq.l    #4,a6
         dbra      d6,mloop            ; loop 7 more times

         movea.l   #proc_usp,a5        ; do usp value last
         bsr       convert_l

         PRINTLINE #msg2               ; now print whole mess and ...

         PRINTLINE #prompt             ; prompt for printer output
         CONIN                         ; get keypress
         cmpi.b    #'y',d0             ; if yes ...
         beq.s     printout            ; then send to printer
         cmpi.b    #'Y',d0
         beq.s     printout

nosuper:
         SUPER     oldssp              ; end super; restore ssp
exit:
         TERM

convert_l:
         BINHEX_L  a5,(a6)             ; my conversion macro
         rts                           ; i.e. a5 = address of value
                                       ;      a6 = ASCII output area
printout:
         PRNLINE  #msg1                ; my macro to print a line
         PRNLINE  emadd
         PRNLINE  #msg2
         bra      nosuper              ; and exit.

 DATA
 ALIGN

title:   dc.b '         *** AUTOPSY -- THE ST CRASH CORONER ***',$A,$D
         dc.b '                       by Steve Baugh',$A,$A,$D,0
nocrash: dc.b 'The system did not record a crash!',$A,$A,$A,$D
         dc.b 'Press any key to exit:',0
 ALIGN
prompt:  dc.b 'Do you want a printout? (y/N): ',0
 ALIGN
msg1:    dc.b 'You detonated  $'
hexbuff: ds.b 2
         dc.b ' bombs!  =  ',0
 ALIGN

emsg0:   dc.b 'Theormo-Nuclear Destruction.',$A,$A,$D,0
 ALIGN
emsg1:   dc.b 'Program counter after reset.',$A,$A,$D,0
 ALIGN
emsg2:   dc.b 'Bus Error.',$A,$A,$D,0
 ALIGN
emsg3:   dc.b 'Address Error.',$A,$A,$D,0
 ALIGN
emsg4:   dc.b 'Illegal Instruction.',$A,$A,$D,0
 ALIGN
emsg5:   dc.b 'Divided by Zero.',$A,$A,$D,0
 ALIGN
emsg6:   dc.b 'CHK Instruction.',$A,$A,$D,0
 ALIGN
emsg7:   dc.b 'TRAPV Instruction.',$A,$A,$D,0
 ALIGN
emsg8:   dc.b 'Privilege Violation.',$A,$A,$D,0
 ALIGN
          ; create address table for above exception messages
exceptab: dc.l emsg0,emsg1,emsg2,emsg3,emsg4,emsg5,emsg6,emsg7,emsg8

msg2:    dc.b 'd0  =  $'
xd0:     ds.b 8
         dc.b '        a0  =  $'
xa0:     ds.b 8
         dc.b '        stack  =  $'
xs0:     ds.b 8
         dc.b $A,$D

         dc.b 'd1  =  $'
xd1:     ds.b 8
         dc.b '        a1  =  $'
xa1:     ds.b 8
         dc.b '        stack  =  $'
xs1:     ds.b 8
         dc.b $A,$D

         dc.b 'd2  =  $'
xd2:     ds.b 8
         dc.b '        a2  =  $'
xa2:     ds.b 8
         dc.b '        stack  =  $'
xs2:     ds.b 8
         dc.b $A,$D

         dc.b 'd3  =  $'
xd3:     ds.b 8
         dc.b '        a3  =  $'
xa3:     ds.b 8
         dc.b '        stack  =  $'
xs3:     ds.b 8
         dc.b $A,$D

         dc.b 'd4  =  $'
xd4:     ds.b 8
         dc.b '        a4  =  $'
xa4:     ds.b 8
         dc.b '        stack  =  $'
xs4:     ds.b 8
         dc.b $A,$D

         dc.b 'd5  =  $'
xd5:     ds.b 8
         dc.b '        a5  =  $'
xa5:     ds.b 8
         dc.b '        stack  =  $'
xs5:     ds.b 8
         dc.b $A,$D

         dc.b 'd6  =  $'
xd6:     ds.b 8
         dc.b '        a6  =  $'
xa6:     ds.b 8
         dc.b '        stack  =  $'
xs6:     ds.b 8
         dc.b $A,$D

         dc.b 'd7  =  $'
xd7:     ds.b 8
         dc.b '        ssp =  $'
xa7:     ds.b 8
         dc.b '        stack  =  $'
xs7:     ds.b 8
         dc.b $A,$D

         dc.b '                        usp =  $'
xusp:    ds.b 8
         dc.b $A,$A,$D,0

 ALIGN

                   ; sets up table for ASCII hex numbers
outtab:  dc.l      xd0,xa0,xs0,xd1,xa1,xs1,xd2,xa2,xs2,xd3,xa3,xs3
         dc.l      xd4,xa4,xs4,xd5,xa5,xs5,xd6,xa6,xs6,xd7,xa7,xs7
         dc.l      xusp

 BSS
 ALIGN

emadd:   ds.l      1
oldssp:  ds.l      1
stack:   ds.l      9999
newssp:  ds.l      1
 END
 