 ; Program Name: PRG_4AP.S

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS suffix.

 ; Program Function:

 ;    This program simply establishes itself in memory as a Load and Stay
 ; Resident (LSR) program and prints its location to the video screen.  The
 ; addresses printed are the program start address (not the basepage address)
 ; and the program end address.

 ; Program Purpose:

 ;    To illustrate the role of GEMDOS function $31 in establishing a
 ; program as LSR.

 ; Execution Instructions:

 ;    Execute the program from the desktop.  When the addresses appear on
 ; the screen, write them down.  Terminate execution by pressing the Return
 ; key.  In the AssemPro debugger, go to the first address using the
 ; "from address" function.  On the first line in the output field, you
 ; should see the second address (program_end) being loaded into register A3.

 ;    Once this program has been executed, it will remain in ram memory until
 ; the computer is rebooted.

 ; WARNING: If this program or any other LSR program is executed from within
 ;          the AssemPro debugger, upon exit from AssemPro, the operating
 ;          system will not be able to clear the program from memory.

 ;          Because the program will be residing in an area of memory that
 ;          was controlled by AssemPro, the environment will be corrupted.
 ;          You can confirm this by trying to reexecute AssemPro after you
 ;          exit.  You will receive a Bus error message.

 ;          Furthermore, you will not be able to assemble a program until
 ;          you reset the system.

 ;          There is only one thing you can do if you execute a LSR program
 ;          from within AssemPro; you must reset the system by turning it
 ;          completely off, then back on.  You can try a warm reset, but
 ;          all bets are off if you do that. 
 
program_start:                  ; Calculate program size and retain result.
 lea        program_end, a3     ; Fetch address of last memory location occupied
 movea.l    a3, a4              ; by the program.  Copy into scratch register.
 suba.l     4(a7), a3           ; Subtract basepage address from program end 
                                ; address.  After this, the basepage address
                                ; is no longer needed in this program.
fetch_stack_address:
 lea        stack, a7

print_memory_locations:   
 lea        load_message, a0
 bsr.s      print_string
 lea        program_start, a0
 move.l     a0, d1              ; Transfer to D1 for binary to ASCII
                                ; hexadecimal conversion.

 ; Note: Above, must load address into an address register first, then move
 ; to the data register for binary to hexadecimal conversion, in order to
 ; permit PC-relative assembly.

 bsr.s      bin_to_hex          ; bin_to_hex expects binary number in D1.
 lea        hexadecimal, a0     ; Print the hexadecimal string.
 bsr.s      print_string
 lea        separator, a0       ; Print a separator between addresses.
 bsr.s      print_string
 move.l     a4, d1              ; Program end address is in scratch register.          
 bsr.s      bin_to_hex      
 lea        hexadecimal, a0
 bsr.s      print_string
 bsr.s      print_newline

wait_for_keypress:              ; Give time to write down memory addresses.
 move.w     #8, -(sp)           ; Function = c_necin = GEMDOS $8.
 trap       #1                  ; GEMDOS call.
 addq.l     #2, sp

 ; Note: GEMDOS function $31 doesn't need the basepage address.

relinquish_processor_control:   ; Maintain memory residency.
 move.w    #0, -(sp)            ; See page 121 of Internals book.
 move.l    a3, -(sp)            ; Program size.
 move.w    #$31, -(sp)          ; Function = ptermres = GEMDOS $31.
 trap      #1

 ; 
 ; SUBROUTINES
 ;

 ; The binary to ASCII hexadecimal conversion routine expects a number to be
 ; passed as a longword in register D1.  Beginning with the most significant
 ; nibble (a nibble = four bits), each nibble is converted to its ASCII
 ; hexadecimal equivalent and stored in "hexadecimal", a null terminated
 ; buffer.  Maximum size of the binary number is 32 bits = 8 nibbles.

 ; The algorithm discards leading zeroes.

 ; The conversion from binary nibble to hex digit is accomplished by 
 ; extracting the character in the hex table that is located at the position
 ; defined by the decimal value of the nibble.  For example, if the nibble
 ; is "1111", the decimal value is 15; the 15th element of the hex table is
 ; the letter F.  The location in the table is specified by an offset from
 ; the address of the first character of the table, which is stored in A1.
 ; The value of the offset is stored in register D0.  The addressing mode
 ; used to locate the appropriate table entry is "address register indirect
 ; with offset".  

bin_to_hex:                      ; Expects binary number in D1.   
 lea        hexadecimal, a0      ; A0 is pointer to array "hexadecimal".
 tst.l      d1                   ; Test for contents = 0.
 beq.s      zero_passed          ; Branch if number is 0.
 lea        hex_table, a1        ; A1 is pointer to array "hex_table".
 lea        hex_table, a1        ; A1 is pointer to array "hex_table".
 moveq      #7, d2               ; D2 is the loop counter for 8 nibbles.
 
discard_leading_zeroes: 
 rol.l      #4, d1               ; Rotate most significant nibble to the
                                 ; least significant nibble position.
 move.b     d1, d0               ; Copy least significant byte of D1 to D0.
 andi.b     #$F, d0              ; Mask out most significant nibble of D0.
 bne.s      store_digit          ; Branch and store if not leading zero.
 dbra       d2, discard_leading_zeroes
continue:
 rol.l      #4, d1               ; Rotate most significant nibble.
 move.b     d1, d0               ; Copy least significant byte of D1 to D0.
 andi.b     #$F, d0              ; Mask out most significant nibble of D0.
store_digit:
 move.b     0(a1,d0.w), (a0)+    ; Store ASCII hexadecimal digit in buffer.
 dbra       d2, continue         ; Continue looping until D2 = -1.
 move.b     #0, (a0)             ; Terminate hexadecimal string with a null.
 rts
zero_passed:
 move.b     #$30, (a0)+         ; Store an ASCII zero in "hexadecimal".
 move.b     #0, (a0)            ; Terminate ASCII hexadecimal string with null.
 lea        hexadecimal, a0
 rts

print_string:                   ; Expects address of string to be in A0.
 pea        (a0)                ; Push address of string onto stack.
 move.w     #9, -(sp)           ; Function = c_conws = GEMDOS $9.
 trap       #1                  ; GEMDOS call
 addq.l     #6, sp              ; Reset stack pointer to top of stack.
 rts

print_newline:                  ; Prints a carriage return and linefeed.
 pea        newline             ; Push address of string onto stack.
 move.w     #9, -(sp)           ; Function = c_conws = GEMDOS $9.
 trap       #1                  ; GEMDOS call
 addq.l     #6, sp
 rts

 data
hex_table:       dc.b  '0123456789ABCDEF'
newline:         dc.b  $D,$A,0
load_message:    dc.b  'Installing PRG_4AP between hex addresses: ',0
separator:       dc.b  ' - ',0
 align
 bss
hexadecimal:     ds.l  3   ; Output buffer.  Must be NULL terminated.
                 ds.l 16
stack:           ds.l  1
program_end:     ds.l  0
 end
 