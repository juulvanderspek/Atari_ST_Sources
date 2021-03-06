MODULE DelFiles;

(*
 * Hilfsprogramm f�r Megamax Modula-2
 *
 * Wird dieses Modul gestartet, fragt es nach einem Dateinamen.
 * Dabei k�nnen auch "Wildcards" ('*', '?') eingegeben werden.
 * Die gew�nschten Dateien werden dann gel�scht.
 * Beispiele:
 *   'A:\CODES.DEF\*.DEF' l�scht alle Dateien im Ordner mit der Endung 'DEF'.
 *   '*.*' l�scht alle Dateien im aktuellen Verzeichnis.
 * Wird eine Leereingabe gemacht, endet das Programm.
 *
 * Es bietet sich an, dieses Modul im Start-Batch mit 'TOOL DelFiles' einzu-
 * tragen. Dabei sollte aber keinesfalls der Pfad, auf dem sich dieses Modul
 * befindet, mit angegeben werden, weil dieser Pfad sonst beim Starten sofort
 * zum aktuellen Verzeichnis wird.
 *)

FROM InOut IMPORT
  WriteLn, WriteString, ReadString, Write, Read, WriteInt, BusyRead;

FROM Directory IMPORT
  DirQuery, DirEntry, FileAttr, FileAttrSet, Delete;

FROM Files IMPORT GetStateMsg;

FROM Strings IMPORT
  Space, Length, String, Concat, Empty;


PROCEDURE error (res: INTEGER);
  VAR s: String;
  BEGIN
    GetStateMsg (res, s);
    WriteString (s);
  END error;

PROCEDURE delEntry (REF path: ARRAY OF CHAR; e: DirEntry): BOOLEAN;

  VAR res: INTEGER; p: String; ok: BOOLEAN; ch: CHAR;
  
  BEGIN
    WriteLn;
    BusyRead (ch);
    IF ch # 0C THEN
      Read (ch);
      WriteString ('L�schvorgang abgebrochen.');
      RETURN FALSE
    END;
    Concat (path, e.name, p, ok);
    Delete (p, res);
    WriteString (e.name);
    Write (':');
    WriteString (Space (13 - Length (e.name)));
    IF res = 0 THEN
      WriteString ('gel�scht.');
    ELSE
      error (res)
    END;
    RETURN TRUE
  END delEntry;

VAR s: String;
    ch: CHAR;
    res: INTEGER;

BEGIN
  LOOP
    WriteString ('Zu l�schende Datei(en) ? ');
    ReadString (s);
    IF Empty (s) THEN EXIT END;
    DirQuery (s, FileAttrSet {}, delEntry, res);
    WriteLn;
    IF res < 0 THEN
      error (res);
      WriteLn
    END;
    WriteLn;
  END
END DelFiles.
