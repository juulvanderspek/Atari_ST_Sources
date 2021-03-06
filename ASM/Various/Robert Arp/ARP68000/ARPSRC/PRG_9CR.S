 ; Program Name: DONGLE.S
 ;      Version: 1.004

 ; Assembly Instructions:

 ;     Assemble in Relocatable mode and save with a PRG extension.  From
 ; the desktop, change the extension to ACC and copy DONGLE.ACC to the
 ; C partition of the hard disk.

 ; Execution Instructions:

 ;     Execute this program by selecting DONGLE from the accessory menu.

program_start:
 lea       stack(pc), a7        ; A7 points to program's stack address.

install_trap_11_routine:
 pea       trap_11_routine(pc)  ; Push address of custom routine.
 move.w    #43, -(sp)           ; Trap 11 vector number.
 move.w    #5, -(sp)            ; Function = BIOS  set_exec.
 trap      #13                  ; See COMPUTE! TOS book page 180.
 addq.l    #8, sp
 
 lea       aes_pb(pc), a3       ; aes_pb = AES parameter block.
 move.l    a3, d5               ; Use D5 as variable for aes_pb address.
 lea       control(pc), a4      ; A4 is pointer for array "control".
 lea       int_out(pc), a5      ; A5 is pointer for array "int_out".
 lea       addr_in, a3          ; A3 is pointer for array "addr_in".
 move.w    #$C8, d3             ; *** AES call number in D3.

initialize_application:
 move.w    #$A, (a4)            ; Function = appl_init = AES $A.
 move.w    #1, 4(a4)            ; Return one int_out parameter.
 move.l    d5, d1               ; A3 contains address of aes parameter block.
 move.w    d3, d0               ; D3 contains AES call number.
 trap      #2                   ; apid returned in int_out[0] and global[2].

menu_installation:             
 move.w    #$23, (a4)           ; Function = menu_register = AES $23.
 move.w    #1, 2(a4)            ; Pass one int_in parameter.         
 move.w    #1, 6(a4)            ; Pass one addr_in parameter.
 move.w    (a5), int_in         ; Application identification to int_in[0].
 move.l    #menu_text, (a3)     ; Menu text address to addr_in[0].
 move.l    d5, d1               ; Address of aes parameter block to D1.
 move.w    d3, d0               ; D3 contains AES call number.
 trap      #2                   ; Menu id returned in int_out[0].
 move.w    (a5), d4             ; Store menu identification number in D4.

 ; MAIN ACCESSORY LOOP

 lea       message(pc), a5      ; Message received in stored at address in A5.
 move.l    a5, (a3)             ; Address of message array to addr_in.
 move.w    #$17, (a4)           ; Function = evnt_mesag = AES $17.
 move.w    #0, 2(a4)            ; Pass no int_in parameters.
wait_for_message:               ; Relinquish processor control.
 move.l    d5, d1               ; Address of aes parameter block to D1.
 move.w    d3, d0               ; AES call number to D0.
 trap      #2                

; Enters here only when a message is received.

message_handler:                ; Entrance point when message is received.
 cmpi.w    #$28, (a5)           ; Compare AC OPEN code with message[0].
 bne.s     wait_for_message     ; Execute the evnt_mesag function.
 move.w    8(a5), d0            ; Fetch menu id selected.
 cmp.w     d4, d0               ; Was this application selected.
 bne.s     wait_for_message     ; Execute the evnt_mesag function.

invoke_software_dongle:
 trap      #11
 bra       wait_for_message

trap_11_routine:                ; See text in book for explaination.
 move.w    SR, -(a7)
 move.w    #$2700, SR
 movem.l   d0-a6, -(a7)
 move.l    usp, a0
 move.l    a0, -(a7)
 lea       $B27E, a0
 jmp       (a0)

 data
menu_text:  dc.b '  DONGLE  ',0
 align           
aes_pb:     dc.l control,global,int_in,int_out,addr_in,addr_out
 bss
control:          ds.w    5
global:           ds.w    3
                  ds.l    6
int_in:           ds.w    1     ; Input parameter.
int_out:          ds.w    1     ; Output parameter.
addr_in:          ds.l    1     ; Input address.
addr_out:         ds.l    1     ; Output address.
 ;
 ; OTHER VARIABLES
 ;
message:          ds.w    8
                  ds.l   48
stack:            ds.l    0
program_end:      ds.l    0
 end

 