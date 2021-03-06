IMPLEMENTATION MODULE AESResources;
(*$L-, N+, Y+*)


(*  Megamax Modula-2 GEM-Library :  Die AES Resourcefunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0001
 *)
 
(*  05.11.87    | �bernahme von 'GEMBase' und 'GEMExt'
 *  ???????? TT | REF-Parameter
 *  02.04.90    | Anpassung an public arrays
 *)


FROM    SYSTEM          IMPORT ASSEMBLER, ADDRESS;

FROM    GEMGlobals      IMPORT PtrObjTree;
 
IMPORT  GEMShare;

(*$I GEMOPS.ICL *)
 
 
PROCEDURE LoadResource(REF pathname:ARRAY OF CHAR);

BEGIN
  ASSEMBLER
        JSR     stringIntoCFormat   ; R�ckgabe der Str.anf.addr. in D2
        MOVE.L  pubs,A0
        MOVE.L  D2,pubArrays.ADDRIN(A0)
        MOVE.W  #RSRC_LOAD,(A3)+
        JSR     aes_if
        MOVE.L  (A7),A7             ; String wieder vom Stack runterholen
        JSR     testINTOUT0
  END;
END LoadResource;
        
PROCEDURE FreeResource;

BEGIN
  ASSEMBLER
    MOVE.W      #RSRC_FREE,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END FreeResource;
        
PROCEDURE ResourceAddr(typ:ResourcePart;index:CARDINAL):ADDRESS;

BEGIN
  ASSEMBLER
    MOVE.L      pubs, A0
    MOVE.L      our_cb,A1
    MOVE.L      -(A3),pubArrays.aINTIN(A0)
    MOVE.W      #1,cb.A_CONTRL.saddrout(A1)
    MOVE.W      #RSRC_GADDR,(A3)+
    JSR         aes_if
    MOVE.L      pubs,A0
    MOVE.L      our_cb,A1
    CLR.W       cb.A_CONTRL.saddrout(A1)
    MOVE.L      pubArrays.ADDROUT(A0),(A3)+
    JSR         testINTOUT0
  END;
END ResourceAddr;

PROCEDURE SetResourceAddr(typ:ResourcePart;index:CARDINAL;objAddr:ADDRESS);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.L      -(A3),pubArrays.aINTIN(A0)
    MOVE.W      #RSRC_SADDR,(A3)+
    JSR         aes_if
  END;
END SetResourceAddr;

PROCEDURE ConvertCoor(tree:PtrObjTree;index:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      -(A3),pubArrays.aINTIN(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      #RSRC_OBFIX,(A3)+
    JSR         aes_if
  END;
END ConvertCoor;


END AESResources.  
(* $FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$00000874$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C$FFF8B65C�$00000032T...............T.......T.......T.......T.......T.......T.......T.......T.......$000004FE$000004DC$000004C1$00000533$0000058E$000005CC$000005E9$FFEC5578$000006AD$000006D2$000006FE$FFEC5578$000007C6$000007EB$00000816$00000032���*)
