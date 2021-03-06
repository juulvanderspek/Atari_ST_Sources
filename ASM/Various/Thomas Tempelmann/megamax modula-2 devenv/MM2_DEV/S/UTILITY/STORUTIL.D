DEFINITION MODULE StorUtils;
(*------------------------------------------------------------------------*)
(* Debuggingroutien mit Hilfe von Storage                                 *)
(* Erstellt unter Verwendung von NewStorTest                              *)
(* Kann nur f�r Megamax Modula-2 verwendet werden                         *)
(*------------------------------------------------------------------------*)
(* Autor:                                                                 *)
(* Gerd Castan, Hoehbergstr. 16, 70327 Stuttgart                          *)
(* EMail: G.Castan@physik.uni-stuttgart.de                                *)
(*------------------------------------------------------------------------*)
(* Version | Datum    | Arbeitsbericht                                    *)
(* 1       | 26.03.94 | Addr/Block/BlockExactInStorage                    *)
(* 2       | 26.03.94 | GetAllocInfo,TestStorage                          *)
(*------------------------------------------------------------------------*)

FROM SYSTEM IMPORT ADDRESS;


PROCEDURE GetAllocInfo (addr: ADDRESS; VAR start: ADDRESS; VAR size: LONGCARD);
  (* Wenn addr zu einem Speicherblock geh�rt, der mit Storage.ALLOCATE
   * angefordert wurde, gibt start den Beginn und size die L�nge dieses
   * Speicherblocks an, sonst ist start=NIL und size=0.
   *)

PROCEDURE AddrInStorage (addr: ADDRESS): BOOLEAN;
  (* Geh�rt addr zu einem Speicherblock, der mit Storage.ALLOCATE angefordert
   * wurde?
   *)

PROCEDURE BlockInStorage (addr: ADDRESS; size: LONGCARD): BOOLEAN;
  (* Pa�t addr in einen Speicherblock, der mit Storage.ALLOCATE angefordert
   * wurde?
   *)

PROCEDURE BlockExactInStorage (addr: ADDRESS; size: LONGCARD): BOOLEAN;
  (* Pa�t addr exakt in einen Speicherblock, der mit Storage.ALLOCATE
   * angefordert wurde?
   *)

TYPE
  StorageError = (
    storageOK,
    storageInconsistent,  (* StorBase.Inconsistent *)
    storageNIL,           (* NIL in der Block-Verkettung *)
    storageOdd,           (* Blockverkettung mit ungerader Adresse *)
    storageNotAlloc,      (* Block nicht �ber StorBase geholt *)
    storageCircle1,       (* Blockverkettung endet nicht bei RootPtr *)
    storagePrev1,         (* R�ckw�rtsverkettung von Block defekt *)
    storagePrev2,         (* R�ckw�rtsverkettung der Granulierung defekt *)
    storageNext2,         (* Vorw�rtsverkettung der Granulierung defekt *)
    storageSize2          (* Granulierte Daten ragen in den n�chsten Bereich *)
  );

PROCEDURE TestStorage (): StorageError;
  (* Unterzieht die interne Speicherverwaltung von Storage einem
   * Plausibilit�tstest.
   * Wird storageOk zur�ckgegeben, ist (wahrscheinlich) alles in Ordnung.
   *
   * Wenn nicht, gibt es daf�r 2 m�gliche Ursachen:
   * - Ein Fehler in Storage.
   *   In diesem Fall geben die Fehlermeldungen an, wo der Fehler zu suchen ist.
   * - Wahrscheinlicher: Ihr Programm oder ein parallel laufendes Programm
   *   hat wild in den Speicher geschrieben.
   *   In diesem Fall z�hlt nur, ob storageOk oder etwas anderes
   *   zur�ckgegeben wurde.
   *   Welcher Fehler zur�ckgegeben wird ist hier uninteressant.
   *)

END StorUtils.


(* Und hier auch gleich ein Demo/Testprogramm dazu:

MODULE StorTest;

FROM SYSTEM IMPORT ADDRESS;

FROM InOut IMPORT
  WriteString, WriteLn, Read;
FROM StorUtils IMPORT
  StorageError, TestStorage, BlockExactInStorage, GetAllocInfo;
FROM Storage IMPORT
  ALLOCATE, DEALLOCATE;
FROM StrConv IMPORT
  LHexToStr;

TYPE
  HugeString = ARRAY [0..MAX(LONGINT)] OF CHAR;
  PtrHugeString = POINTER TO HugeString;

PROCEDURE
  WriteBlock (progStart,storStart: ADDRESS; progSize, storSize: LONGCARD);

BEGIN
  WriteString ('progStart: '); WriteString (LHexToStr (progStart,7)); WriteLn;
  WriteString ('storStart: '); WriteString (LHexToStr (storStart,7)); WriteLn;
  WriteString ('progSize: '); WriteString (LHexToStr (progSize,7)); WriteLn;
  WriteString ('storSize: '); WriteString (LHexToStr (storSize,7)); WriteLn;
END WriteBlock;


VAR
  err: StorageError;
  CH : CHAR;
  ptrHugeString: PtrHugeString;
  start: ADDRESS;
  size : LONGCARD;
  I    : LONGCARD;

CONST
  initSize = 100000;  (* verhindert Granulierung *)
  diffSize  = 10000;
BEGIN
  WriteString ('Starte TestStorage...'); WriteLn;

  err := TestStorage();
  CASE err
  OF storageOK           : WriteString ('OK');
  |  storageInconsistent : WriteString ('Inconsistent');
  |  storageNIL          : WriteString ('NIL');
  |  storageNotAlloc     : WriteString ('NotAlloc');
  |  storageCircle1      : WriteString ('Circle1');
  |  storagePrev1        : WriteString ('Prev1');
  |  storagePrev2        : WriteString ('Prev2');
  |  storageNext2        : WriteString ('Next2');
  |  storageSize2        : WriteString ('Size2');
  ELSE                     WriteString ('Unbekannter Fehler');
  END;
  WriteLn();

  WriteString ('Taste...');
  Read (CH);
  WriteLn();

  (* F�r kleine Bl�cke ist der folgende Test schon durch ein 'richtiges'
   * Programm durchgef�hrt
   *)
  ALLOCATE (ptrHugeString, initSize);
  IF ~BlockExactInStorage (ptrHugeString, initSize) THEN
    GetAllocInfo (ptrHugeString, start, size);
    WriteBlock (ptrHugeString, start, initSize, size);
  END;

  (* Da� beim letzten Durchgang alles deallociert ist, ist beabsichtigt. *)
  FOR I := 1 TO 10 DO
    DEALLOCATE (ptrHugeString, diffSize);
    IF ~BlockExactInStorage (ptrHugeString, initSize-I*diffSize) THEN
      GetAllocInfo (ptrHugeString, start, size);
      WriteBlock (ptrHugeString, start, initSize-I*diffSize, size);
    END;
  END;

  WriteString ('Taste...');
  Read (CH);
  WriteLn();

END StorTest.

*)
