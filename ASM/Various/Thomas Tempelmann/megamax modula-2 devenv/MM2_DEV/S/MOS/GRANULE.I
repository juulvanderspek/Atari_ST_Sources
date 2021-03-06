(*########################################################################
                              S T O R A G E
  ########################################################################

  Idee          : Johannes Leckebusch, Peter Sollich
  Realisation   : Peter Sollich
  Dynamic Heap  : Peter Hellinger

  ########################################################################

  16.03.94 TT   Verwendet nun kein TT-RAM mehr, weil die freeMap auf einen ein-
                zigen Bereich ausgelegt ist. Wollte man das TT-RAM mitnutzen,
                m��te 1. f�r die Berechnung der Maximalgr��e der freeMap das
                TT-RAM mit einbezogen werden (s. Zuweisung 'MaxHeapSize') und
                2. die freeMap diesen zweiten Speicherbereich entsprechend
                ber�cksichtigen. Ein einfache L�sung w�re, einfach als
                Speicherobergrenze das MemTop vom TT-RAM zu nehmen, allerdings
                w�rden dann f�r die L�cke vom Ende d. ST-RAMs zum Beginn des
                TT-RAMs (k�nnen 8-14 MB sein) trotzdem Eintr�ge in der FreeMap
                reserviert werden, was bis zu ca. 100 KB verschwendet.
                Umgekehrt k�nnte man auch einfach nur das TT-RAM verwenden,
                wenn vorhanden.

  19.01.94 TT   Die freemap wird nun nicht mehr zu weit (�ber allozierten
                Bereicht hinaus) gel�scht.
  
  18.12.90 TT   Noch eine Malloc-Erfolgsabfrage in CreateHeap vorgesehen
  
  12.12.90 TT   Super & Malloc ge�ndert (kein Zugriff auf glob. 'a' mehr).
                OutOfMemory-Aufruf statt HALT.

  28.05.89 Hp   deallocate ist jetzt in der Lage nur ein Teil-Deallocate
                des Speicher-Blocks durchzuf�hren.

  26.05.89 Hp   Problem des "doppelten Lottchens" in deallocate gel�st.
                St�rzt nun nicht mehr bei bereits deallozierten Pointern ab.

  28.12.88 Hp   deallocate st�rzt nicht mehr bei NIL-Pointern ab.
           +    Allozierungs reihenfolge ver�ndert. Dadurch das "Heaprest"-
                Problem gel�st. Siehe auch Kommentar in allocate.
           +    Berechnung der freien bzw. belegten Bytes im Heap auf Bytes
                umgestellt. free liefert jetzt auch die Anzahl freier BYTES.
           +    memAvail liefert nun die Anzahl aller freien BYTES sowohl
                im Heap, als auch im noch nicht allozierten Speicher -
                abz�glich der GEMDOS-Reserve von 64kb (Konstante GEMReserve)
           +    In AppendHeap wird nun bei JEDER Fehlerbedingung das Dynamic-
                Flag FALSE geschaltet. (!!)
                
  04.12.88 Hp   Initalisierung des Heaps beschleunigt.
                Markierung von Lisp-Bl�cken durchg�ngig gemacht; l�uft nun
                auch �ber AppendHeap.

  03.12.88 Hp   Zu fr�h gefreut: Storage l�uft nicht. Warum? Nach endlosem
                Debugging habe ich zwei Fehler gefunden:
                1. Die Gr��e des Blocks der per AppendHeap angefordert
                   wurde, wird nicht richtig gesetzt. Dadurch ist die
                   Blockberechnung von DEALLOCATE katastrophal falsch.
                   Warum es zun�chst funktionierte ist mir schleierhaft.
                2. GEMDOS.Alloc liefert nicht NIL wenn kein Speicher mehr
                   da, ist sondern NULL. AppendHeap konnte deshalb das
                   Ende des Speichers nicht erkennen.

  28.11.88 Hp   Initialisierung f�r GESAMTEN Speicher eingef�hrt. Kann
                sonst zu Problemen f�hren wenn wir Blocks bekommen die
                nicht durch unsere freeMap abgedeckt werden.

  25.11.88 Hp   Bug in allocate beseitig. allocate testet nun BEVOR es nach
                einem Block sucht, ob der Heap �berhaupt gro� genug ist.
                Der G2E l�uft jetzt einwandfrei. Damit m��ten eigentlich
                alle schwerwiegenden Fehler behoben sein.

  23.11.88 Hp   Jubel! Heaptest lief einwandfrei! 3640 x 1000 Byte und an-
                schlie�end 1820 x 2000 Byte. Nun kommen die H�rtetests.

  22.11.88 Hp   Heute fiel der Groschen: Es ist wieder einmal eines jener
                Dinge, die einem fast in die Nase zwicken, bevor man sie
                sieht. Also: Wir tarnen das St�ckchen Speicher, da� wir
                in den Heap integrieren wollen als von ALLOCATE behandlet
                (korrekt gesetzte Gr��en, GranulesUsed richtig berechnet etc.
                largeSentinel erh�lt die neue Heapgr��e) und lassen es von
                DEALLOCATE in den Heap integrieren... Physikalisch zusammen-
                h�ngende Speicherbereiche werden anhand der BitMap ermittelt
                und als gr��erer Block in den Heap integriert.

  20.11.88 Hp   Versuchsweise Implementierung von AppendHeap -> Bombenstimmung
  
  19.11.88 Hp   freeMap wird bei Modul-Initialisierung f�r den ganzen verf�g-
                baren Speicher angelegt -> dadurch Weg frei f�r eine dynamische
                Heap-Erweiterung.

  18.11.88 Hp   Massenweise Kommentare erg�nzt.
                Bezeichner etwas entkryptisiert...
                Standard-Initalisierung bei Aufruf von ALLOCATE (@#!)

  08.08.87      Johannes Leckebusch / Peter Sollich
                Erstimplementation

  ########################################################################*)

IMPLEMENTATION MODULE Granule;

(* Idee         : Johannes Leckebusch, Peter Sollich    *)
(* Realisation  : Peter Sollich                         *)
(* Dynamic-Heap : Peter Hellinger                       *)
(* Stand        : 05.10.90   Version f�r MM2            *)

(*$Y+*)
(*$R- *) (* Range-Checks    *)

FROM SYSTEM IMPORT  ADDRESS, ASSEMBLER, CAST;

FROM SystemError IMPORT OutOfMemory;

FROM Block IMPORT Clear;


CONST   cSetGrain =     LONGCARD(8);    (* Granule-Setgr��e   *)
        cMinHeapSize =  64;             (* Minimum-Heap       *)
        cMaxHeapSize =  16777215;       (* 16 Megabyte maximaler Heap   *)
        cMaxGranules =  1048575;        (* Maximale Anzahl der Granules *)
        cBytesInSet =   131071;         (* Maximum Bytes im Set *)
        GEMReserve =    010000H;        (* 64kb Restspeicher f�r GEM *)
        cgrain =        16;
        NULL =          ADDRESS(0);

TYPE    BlockPtr =      POINTER TO Block; (* Zeiger auf ein Element des Heaps *)
        Block =         RECORD
                         bigger: BlockPtr; (* Zeiger auf gr��ere Bl�cke (rechts) *)
                         equal:  BlockPtr; (* Zeiger auf kleinere Bl�cke (links) *)
                         back:   BlockPtr; (* Zeiger auf den vorhergehenden Block *)
                         size:   LONGCARD; (* Gr��e des Blocks *)
                        END;


TYPE    ByteSet =       SET OF [0..7]; (* Basistyp f�r das BitmapSet *)
        mapSet =        ARRAY [0..cBytesInSet] OF ByteSet;


VAR     root:           BlockPtr;     (* Die Wurzel unseres Baumes    *)
        initialBlock:   BlockPtr;     (* Erster Block des Baumes      *)
        largeSentinel:  BlockPtr;     (* Lezter Block im Heap         *)
        freeMap:        POINTER TO mapSet;
        lispMap:        POINTER TO mapSet;
        GranulesUsed:   LONGCARD;     (* Wird vorerst nicht mehr benutzt *)
        heapUsed:       LONGCARD;     (* Anzahl der benutzten Bytes   *)
        heapStart:      ADDRESS;
        heapSize:       LONGCARD;     (* Gr��e des Heap               *)
        dynamic:        BOOLEAN;      (* Flag f�r Dynamic-Option      *)
        defaultSize:    LONGCARD;     (* Standardgr��e f�r Heaperweiterung *)
        FreeMapSize:    LONGCARD;     (* Gr��e der Bitmap             *)
        MaxHeapSize:    LONGCARD;     (* Maximale Gr��e des Heaps     *)
        MemoryBottom:   ADDRESS;      (* Unteres Ende des Speichers   *)
        PhysicalTop:    ADDRESS;      (* Oberes Ende des Speichers    *)



VAR a: ADDRESS;



PROCEDURE Malloc (bytes: LONGCARD): ADDRESS;
VAR a: ADDRESS;
BEGIN
 ASSEMBLER
  CLR.W   -(A7)         ; nur ST-RAM anfordern, kein TT-RAM
  MOVE.L  bytes(A6),-(SP)
  MOVE.W  #$44,-(SP)    ; Mxalloc() - nur bei Atari TT & Falcon verf�gbar
  TRAP    #1
  TST.L   D0
  BPL     ok2
  ; falls Fehler bei mxalloc kam, es nochmal mit altem malloc probieren:
  MOVE.W  #$48,(SP)    ; Malloc()
  TRAP    #1
 ok2:
  ADDQ.L  #8,SP
  TST.L   D0
  BPL     ok
  CLR.L   D0
 ok:
  MOVE.L  D0, a(A6)
 END;
 RETURN a;
END Malloc;

PROCEDURE Super (VAR stack: ADDRESS);
BEGIN
 ASSEMBLER
  MOVE.L  stack(A6),A0
  MOVE.L  (A0), -(SP)
  MOVE.W  #32, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.L  stack(A6),A0
  MOVE.L  D0,(A0)
 END;
END Super;

PROCEDURE AppendHeap (Amount: LONGCARD): BOOLEAN;
(* f�gt neuen Block in den Heap ein, FALSE wenn nicht m�glich *)

VAR Block, b1:  BlockPtr;
    adr:        ADDRESS;
    lc:         LONGCARD;
VAR l,g:        LONGCARD;
    wasFree:    BOOLEAN;

BEGIN

 (* erst mal Testen ob soviel Speicher da ist *)
 lc:= CAST (LONGCARD, Malloc (0FFFFFFFFH));
 IF (lc > GEMReserve) THEN
  DEC(lc, GEMReserve) (* Gemdos-Minimum reservieren *)
 ELSE
  dynamic:= FALSE; (* Speicher kleiner als GEMReserve -> nix geht mehr *)
  RETURN FALSE;
 END;

 IF lc < Amount THEN
  Amount:=lc;
  dynamic:=FALSE;
  (* Kein Speicher mehr zur Verf�gung -> AppendHeap darf nicht mehr
   * aufgerufen werden, da sonst Restspeicher f�r GEM verbraten wird!
   *)
 END;

 (* Nur Vielfache von cgrain als Blockgr��e zulassen *)
 INC(Amount,(cgrain-1)-(Amount+(cgrain-1)) MOD cgrain);
 
 (* Testen, ob Amount im g�ltigen Bereich *)
 IF (Amount < cMinHeapSize) OR (Amount > MaxHeapSize) THEN
  dynamic:= FALSE; RETURN FALSE;
 END;

 (* Speicher abrufen *)
 Block:= Malloc (Amount);
 IF Block=NULL THEN
  dynamic:=FALSE;
  RETURN FALSE
 END;

 INC(heapSize, Amount); (* neue Heapgr��e berechnen *)
 largeSentinel^.size:= heapSize + 1;

 (* Unseren neuen Block als von ALLOCATE behandelt tarnen  *)
 (* 04.12.88: Wie hat das blo� jemals funktionieren k�nnen ??? *)
 Block^.size:= Amount-(cgrain * 2);
 b1:= (ADDRESS(Block)+ADDRESS(Block^.size))-ADDRESS(cgrain);
 b1^.size:= Block^.size;
 INC(heapUsed, Amount);  (* Zur Tarnung *)

 (* Nun wird der Block noch in der Bitmap als Belegt gekennzeichnet.
  * Es gen�gt, das erste Bit zu setzen, da deallocate auch nur das
  * erste Block-Bit in der freeMap testet.  Zeit ist Geld!
  *)
 l:= CAST (LONGCARD, CAST (ADDRESS, Block) - MemoryBottom) DIV cgrain;
 g:= Amount DIV cgrain;
 EXCL(freeMap^[l DIV cSetGrain],SHORT(l MOD cSetGrain));

 (* Nun mu� auch der phys. linke Nachbar tempor�r als belegt gekennzeichnet
  * werden, damit nicht versucht wird, auf den "Block" vor diesem neu
  * angelegten Speicherbereich zuzugreifen. TT 19.01.94
  *)
 wasFree:= SHORT((l-1) MOD cSetGrain) IN freeMap^[(l-1) DIV cSetGrain];
 EXCL(freeMap^[(l-1) DIV cSetGrain],SHORT((l-1) MOD cSetGrain));
 
 DEALLOCATE (Block, Amount);
 
 IF wasFree THEN
  INCL(freeMap^[(l-1) DIV cSetGrain],SHORT((l-1) MOD cSetGrain));
 END;
 
 RETURN TRUE;
END AppendHeap;


PROCEDURE ALLOCATE (VAR Addr: ADDRESS; Amount: LONGCARD);
VAR Block,b : BlockPtr;
    b1,b2,b3: BlockPtr;
    l,g     : LONGCARD;
    m       : LONGCARD; (* f�r Testzwecke *)
    i       : INTEGER;  (* f�r createheap *)
BEGIN

 Addr:= NIL; (* Na denn... *)

 (* Wenn nicht installiert, mu� der Heap initialisiert werden *)
 IF root = NIL THEN
  IF (Amount>=defaultSize) THEN  i:= CreateHeap (Amount+defaultSize);
                           ELSE  i:= CreateHeap (defaultSize);
  END;
  IF i < 0 THEN RETURN; END;
  (* hier kann nur 0 oder -1 zur�ckkommen, da root=NIL *)
 END;

 IF (Amount > heapSize) THEN (* Grmpfft! Siehe Bugnote 25.11.88 *)
  IF dynamic THEN
   IF NOT AppendHeap (Amount) THEN RETURN END;
  ELSE
   RETURN;
  END;
 END;
 
 Block:= root; (* Laufzeiger auf Beginn des Heap-Baumes *)

 (* Nur Vielfache von cgrain als Blockgr��e zulassen *)
 INC(Amount,(cgrain-1)-(Amount+(cgrain-1)) MOD cgrain);

 (* Suche nach einem Block gr��er oder gleich dem Angeforderten *)
 REPEAT Block:= Block^.bigger UNTIL Block^.size>=Amount;
          (* !TT 19.01.94: vormals: Block^.size>Amount *)

 IF Block^.size>heapSize THEN (* Heapoverflow! *)
  IF dynamic THEN
   IF NOT AppendHeap (defaultSize) THEN RETURN END; (* nichts geht mehr *)
   ALLOCATE (Addr, Amount);
  ELSE
   RETURN;
  END;
  RETURN;
 END;

 b1:= Block^.back; (* b1 = vorhergehender Block *)

 IF Block^.size=Amount THEN
  (* Block hat gleiche Gr��e wie angefordert, das ist einfach *)
  
  (*!TT 19.01.94
   *  Hier fehlte Zuweisung von "Addr". Allerdings kam wg. der fehlerhaften
   *  Suchschleife (es wurde nur nach gr��eren freien Blocks gesucht) nie
   *  dazu, da� dieser Code ausgef�hrt wurde. Hoffentlich klappt's nun so.
   *)
  Addr:= Block;
  
  (*-- Block aus der Liste l�sen und Liste restaurieren --*)
  b2:= Block^.equal;
  b3:= Block^.bigger;
  IF b2=NIL THEN
   b1^.bigger:= b3;
   b3^.back:= b1;
  ELSE
   b1^.bigger:= b2;
   b2^.bigger:= b3;
   b2^.back:= b1;
   b3^.back:= b2;
  END;

 ELSE (* Block ist gr��er als angefordert -> nu wirds kompliziert *)
 
 (* In Verbindung mit der dynamischen Erweiterungsm�glichkeit des Heaps
  * ergibt sich hier ein gar nicht so leicht aufzudeckender Fehler:
  *
  * Der allozierte Speicher wird am OBEREN Ende des gefundenen Blocks
  * abgezweigt. Hierdurch entsteht der Effekt, da� die Daten in UMGE-
  * kehrter Reihenfolge im Heap stehen - also die zuerst abgelegten Daten
  * auf h�heren Adressen als die zuletzt abgelegten. Der Heap w�chst
  * gewisserma�en "nach unten".
  *
  * Wird nun mittels AppendHeap ein neuer Block in den Heap integriert,
  * wird er in aller Regel eine h�here Adresse als der bereits bestehende
  * Heap haben, also im Speicher weiter "hinten" liegen.
  *
  * Da der oberste Block des bereits bestehenden Heaps auch in aller Regel
  * belegt sein wird (er wird ja schlie�lich als erster alloziert) kann
  * deallocate den neuen Block nicht mit dem Rest des bestehenden Heaps
  * verschmelzen - der Rest steht ja am BEGINN des Blocks, nicht am Ende
  * wie es notwendig w�re.
  *
  * So k�nnen Bl�cke entstehen, die nicht mehr durchs Programm allozierbar
  * sind, da sie einfach zu klein sind. Je nachdem, wie die durchschnittliche
  * Blockgr��e aussieht, kann so ein Rest zwischen 1 und 100 Kilobyte
  * entstehen (bei einem freien Speicher von ca 3.5 Mb).
  *
  * Ich habe versucht diesen Fehler auszumerzen, indem ich die Allozierungs-
  * reihenfolge ge�ndert habe. Der Rest-Heap sollte nun am Ende des Blocks
  * stehen und sich mit dem neuen Block verschmelzen lassen.
  *
  * Hp 25.12.88
  *)

  Addr:= Block; (* die halbe Miete h�tten wir... *)
 
  (*-- Block aus Liste nehmen und Liste restaurieren --*)
  b2:= Block^.equal;
  b3:= Block^.bigger;
  IF b2 = NIL THEN
   b1^.bigger:= b3;
   b3^.back:= b1;
  ELSE
   b1^.bigger:= b2;
   b2^.bigger:= b3;
   b2^.back:= b1;
   b3^.back:= b2;
  END;

  (* Block-Pointer "nach oben" verschieben *)
  b:= ADDRESS(Block) + ADDRESS(Amount);
  b^.bigger:= Block^.bigger;
  b^.equal := Block^.equal;
  b^.back  := Block^.back;
  b^.size  := Block^.size - Amount;
  Block:= b;

  (* Nun suchen wir ein trautes Pl�tzchen f�r den Rest unseres Blocks *)

  b2:= root;
  REPEAT b2:= b2^.bigger UNTIL b2^.size>=Block^.size;
  (* b2 zeigt auf einen Block gr��er oder gleich unseres Blockrestes *)

  (* Block an neuer Stelle einf�gen *)
  b1:= b2^.back;
  b1^.bigger:= Block;
  Block^.back:= b1;
  b2^.back:= Block;
  IF b2^.size>Block^.size THEN
   (* Block zwischen b1 und b2 einf�gen *)
   Block^.bigger:= b2;
   Block^.equal := NIL;
  ELSE
   (* Block nach b2 einf�gen *)
   b3:= b2^.bigger;
   Block^.bigger:= b3;
   Block^.equal:= b2;
   b3^.back:= Block;
  END;

  (* oberes Ende des Blocks berechnen *)
  b2:= (CAST (ADDRESS, Block) + CAST (ADDRESS, Block^.size)) - CAST (ADDRESS, cgrain);
  b2^.size:= Block^.size;
 END (* IF Block^.Amount = Amount *);

 (* Nun wird der Block noch in der Bitmap als Belegt gekennzeichnet *)
 l:= CAST (LONGCARD, Addr-MemoryBottom) DIV cgrain;
 g:= Amount DIV cgrain;
 INC(heapUsed,Amount);
 REPEAT
  EXCL(freeMap^[l DIV cSetGrain],SHORT(l MOD cSetGrain));
  INC(l); DEC(g);
 UNTIL g=0;

 (* Uff... *)
END ALLOCATE;


PROCEDURE Shrink (VAR Addr: ADDRESS; Amount: LONGCARD; VAR new: LONGCARD);
VAR newAddr   : ADDRESS;
    newAmount : LONGCARD;
BEGIN
 IF Addr # NIL THEN
  INC (Amount, (cgrain-1) - (Amount+ (cgrain-1)) MOD cgrain);
  INC (new, (cgrain-1) - (new + (cgrain-1)) MOD cgrain);
  IF (new > Amount) THEN
   DEALLOCATE (Addr, Amount);
  ELSE
   newAddr:= Addr + ADDRESS (new);
   newAmount:= Amount - new;
   DEALLOCATE (newAddr, newAmount);
  END;
 END;
END Shrink;


PROCEDURE DEALLOCATE (VAR Addr: ADDRESS; Amount: LONGCARD);
VAR  s,b,b1,b2,b3 : BlockPtr;
     l,r,g        : LONGCARD;
BEGIN

 IF Addr=NIL THEN RETURN END; (* gibt sonst B�mbchen *)

 (* Nur Vielfaches von cgrain als Gr��e zulassen *)
 INC(Amount,(cgrain-1) - (Amount+(cgrain-1)) MOD cgrain);

 (* Schutz vor Doppelten Pointern *)
 l:= CAST (LONGCARD, (Addr-MemoryBottom) DIV cgrain);
 IF (SHORT(l MOD cSetGrain) IN ByteSet(freeMap^[l DIV cSetGrain])) THEN
  Addr:= NIL; HALT; RETURN; (* Doppelter Pointer *)
 END;

 (* Block in der Bitmap als frei kennzeichnen *)
 (* l:= CAST (LONGCARD, (Addr-MemoryBottom) DIV cgrain);  Ist hier �berfl�ssig *)
 g:= Amount DIV cgrain;
 DEC(heapUsed,Amount);
 r:= l;
 REPEAT
  INCL(freeMap^[r DIV cSetGrain],SHORT(r MOD cSetGrain));
  INC(r); DEC(g)
 UNTIL g=0;

 s:= root; (* Start des Heap *)
 b:= Addr; (* Adresse des Blocks *)

 (* physikalisch Rechten Nachbar in der Bitmap auf Frei testen *)
 IF SHORT(r MOD cSetGrain) IN ByteSet(freeMap^[r DIV cSetGrain]) THEN

  b:= CAST (ADDRESS, b) + CAST (ADDRESS, Amount); (* Adresse des Blocks berechnen *)
  INC (Amount, b^.size); (* Blockgr��e zu der Unseren addieren *)

  (* Die Zeiger der beiden Bl�cke verk�pfen *)
  b1:= b^.back; b2:= b^.equal;
  IF b1^.size=b^.size THEN
   b1^.equal:= b2;
   IF b2#NIL THEN b2^.back:= b1 END;
  ELSE
   b3:= b^.bigger; s:= b3;
   IF b2 = NIL THEN
    b1^.bigger:= b3; b3^.back:= b1;
   ELSE
    b1^.bigger:= b2; b2^.bigger:= b3; b2^.back:= b1; b3^.back:= b2;
   END;
  END;
  b:= Addr;

 END; (* IF SHORT *)

 (* physikalisch Linken Nachbar in der Bitmap auf Frei testen *)
 IF SHORT((l-1) MOD cSetGrain) IN ByteSet(freeMap^[(l-1) DIV cSetGrain]) THEN
  b1:= CAST (ADDRESS, b) - cgrain;
  b:= Addr - CAST (ADDRESS, b1^.size); (* Startadresse des linken Blocks *)
  INC(Amount,b^.size);
  b1:=b^.back; b2:= b^.equal;

  IF b1^.size=b^.size THEN
   b1^.equal:= b2;
   IF b2#NIL THEN b2^.back:= b1 END;
  ELSE
   b3:= b^.bigger;
   IF s^.size<b3^.size THEN s:= b3 END;
   IF b2=NIL THEN
    b1^.bigger:= b3; b3^.back:= b1;
   ELSE
    b1^.bigger:= b2; b2^.bigger:= b3; b2^.back:= b1; b3^.back:= b2;
   END (* IF b2=NIL *);
  END (* IF b1^.Amount *);

 END (* IF l - 1 *);

 b^.size:= Amount;  b1:= CAST (ADDRESS, b) + CAST (ADDRESS, Amount) - cgrain;
 b1^.size:= Amount; b2:= s;
 WHILE b2^.size<Amount DO b2:=b2^.bigger END;
 b1:= b2^.back; b1^.bigger:= b; b^.back:= b1; b2^.back:= b;
 IF b2^.size>Amount THEN (* insert b between b1 and b2 *)
  b^.bigger:= b2; b^.equal:= NIL;
 ELSE (* insert b above b2 *)
  b3:= b2^.bigger; b^.bigger:= b3; b^.equal:= b2; b3^.back:= b;
 END (* IF b2^.size *);

 Addr:= NIL; (* Schwitz... *)

END DEALLOCATE;


PROCEDURE CreateHeap (Amount: LONGCARD): INTEGER;
VAR smallSentinel: BlockPtr;
    i,l,g        : LONGCARD;
    a            : ADDRESS;  (*21.12.88 Hp*)
BEGIN

 (* Fehler, wenn Heap schon existiert *)
 IF root # NIL THEN RETURN -2 END;
 
 (* Mal sehen was so im Speicher rumliegt *)
 l:= CAST (LONGCARD, Malloc (0FFFFFFFFH));
 IF l <= GEMReserve THEN RETURN -1 END; (*19.01.94 TT*)
 DEC(l, GEMReserve);

 (* Bereich testen und Heapsize korrigieren *)
 INC(Amount,(cgrain-1)-(Amount+(cgrain-1)) MOD cgrain);
 IF l < Amount THEN Amount:= l; END;
 IF (Amount < cMinHeapSize) OR (Amount>l) THEN RETURN -1; END;

 (* Speicher anfordern *)
 heapStart:= Malloc (Amount);
 IF heapStart = NULL THEN
   RETURN -1
 END;

 heapSize:= Amount;
 
 smallSentinel:= heapStart;             (* unteres Ende des Heaps *)
 largeSentinel:= heapStart+cgrain;      (* Zeiger auf obere Ende des Heap *)
 initialBlock := heapStart+cgrain*2;    (* Erster Block des Heap *)

 (* "kleinen W�chter" initalisieren *)
 WITH smallSentinel^ DO
  bigger:= initialBlock;
  equal := NIL;
  back  := NIL;
  size  :=   0;
 END;

 (* "gro�en W�chter" initialisieren *)
 WITH largeSentinel^ DO
  bigger:= NIL;
  equal := NIL;
  back  := initialBlock;
  size  := heapSize+1;
  (* Aktuelle Heapgr��e +1. So wird in allocate das Ende des Heaps erkannt. *)
 END;

 (* Ersten Block intialisieren *)
 WITH initialBlock^ DO
  bigger:= largeSentinel;
  equal := NIL;
  back  := smallSentinel;
  size  := Amount-(cgrain * 2);
  DEC(size,size MOD cgrain);
 END;

 heapUsed:= cgrain * 2;
 
 root:= smallSentinel;

 (* Heap in der Bitmap als frei kennzeichnen *)
 l:= CAST (LONGCARD, (heapStart + CAST (ADDRESS, cgrain * 2)) - MemoryBottom) DIV cgrain;
 g:= Amount DIV cgrain;
 REPEAT
  INCL(freeMap^[l DIV cSetGrain],SHORT(l MOD cSetGrain));
  INC(l); DEC(g);
 UNTIL g=0;

 (* Kennzeichnet unteres Ende des Heap *)
 EXCL(freeMap^[0],1);

 RETURN 0;
END CreateHeap;


PROCEDURE Free(): LONGCARD;
BEGIN
 RETURN heapSize - heapUsed;
END Free;


PROCEDURE Dynamic (dyn: BOOLEAN);
BEGIN
 dynamic:= dyn;
END Dynamic;


PROCEDURE SetDefaultSize (size: LONGCARD);
BEGIN
 defaultSize:= size;
END SetDefaultSize;


PROCEDURE MemAvail(): LONGCARD;
VAR a: ADDRESS;
    l: LONGCARD;
BEGIN
 a:= Malloc (0FFFFFFFFH);
 RETURN (heapSize + LONGCARD(a)) - (heapUsed + GEMReserve);
END MemAvail;


VAR     c:              LONGCARD;
        x:              POINTER TO LONGCARD;
        y:              POINTER TO CHAR;
        phystop[042EH]: ADDRESS;        (* Systemvariable *)
        membot[0432H]:  ADDRESS;        (* Systemvariable *)

BEGIN

 dynamic:=      TRUE;          (* Dynamic-Option gew�hlt       *)
 defaultSize:=  010000H;       (* 64Kb Default Heapsize        *)
 GranulesUsed:= 0;             (* Noch kein Granule gebraucht  *)
 heapUsed:=     0;             (* Noch kein Byte belegt        *)
 root:=         NIL;           (* Heap ist leer                *)

 (* maximale Speichergr��e feststellen *)
 a:= 0; Super(a);
 PhysicalTop:=  phystop;
 MemoryBottom:= membot;
 Super(a);

 (* Maximale Gr��e des freien Speichers *)
 MaxHeapSize:= CAST (LONGCARD, PhysicalTop - MemoryBottom);

 (* Gr��e der Bitmap berechnen, sie wird f�r den gesamten theoretisch
  * verf�gbaren Speicher ausgelegt. *)
 FreeMapSize:= MaxHeapSize DIV (cgrain * cSetGrain);
 INC(FreeMapSize);

 (* Speicher anfordern *)
 freeMap:= Malloc(FreeMapSize);
 IF (freeMap = NULL) THEN OutOfMemory END;
 
 (* Bitmap l�schen. Geht so schneller *)
 (* 19.01.94 TT: war sowieso fehlerhaft (FOR c:=0 mu�te c:=1 hei�en)
  *   - nun gleich durch schnelleres Block.Clear ersetzt *)
 (*
   x:= CAST (ADDRESS, freeMap);
   FOR c:=1 TO (FreeMapSize DIV 4) DO x^:=0; INC(x,4); END;
   y:= CAST (ADDRESS, x);
   FOR c:=1 TO (FreeMapSize MOD 4) DO y^:=0C; INC(y); END;
 *)
 Clear (freeMap, FreeMapSize);

END Granule.

(* $FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$0000200F$FFE520B8$00005C77$FFE520B8$00004A78$FFE520B8$FFE520B8$FFE520B8$FFE520B8$00004272$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8$FFE520B8�$0000200BT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00002091$00001FD1$00001FBB$00001FD6$00002096$000020B4$0000200F$000020B4$00002080$0000200B$00005A0A$00002019$000020CD$000020BC$00001FC4$FFE5C27A���*)
