MODULE ConvRsc;

(*
 * Wandelt Output File v. K-Resouce um.
 *)

FROM Files IMPORT Open, Close, Create, Access, File, EOF, State,GetStateMsg,
                ReplaceMode;
FROM Text IMPORT Read, ReadString, ReadLn, WriteString, WriteLn, EOL;
FROM Strings IMPORT String, Pos, Concat, Insert, Compare, Relation,
  Upper, Length, PosLen, Copy, Delete;
IMPORT InOut;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;

PROCEDURE err (f:File): BOOLEAN;
  VAR msg: String; ch:CHAR;
  BEGIN
    IF State (f)< 0 THEN
      InOut.GotoXY (0,20);
      InOut.WriteString ('Error !');
      InOut.WriteLn;
      GetStateMsg (State(f),msg);
      InOut.WriteString (msg);
      InOut.WriteLn;
      InOut.Read (ch);
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
  END err;

PROCEDURE clearLine;
  BEGIN
    InOut.Write (33C);
    InOut.Write ('l');
  END clearLine;

PROCEDURE letter (ch:CHAR): BOOLEAN;
  BEGIN
    RETURN (ch>='a') & (ch<='z')
  END letter;

VAR in, out: File;
    pos1,i,line: CARDINAL;
    j:INTEGER;
    up, export, const, press, ok: BOOLEAN;
    l: String;
    ch: CHAR;

BEGIN
  InOut.WritePg;
  
  InOut.GotoXY (0,2);
  InOut.WriteString ('line:');
  Open (in,'MSHELL.DEF',readSeqTxt);
  IF err (in) THEN RETURN END;
  Create (out,'MSHELL.D',writeSeqTxt,replaceOld);
  IF err (out) THEN RETURN END;
  line := 1;
  export:= FALSE;
  const:= FALSE;
  LOOP
    InOut.CondRead (ch,press);
    IF press & (ch=33C) THEN EXIT END;
    ReadString (in,l);
    IF EOF (in) THEN IF err (in) THEN RETURN END; EXIT END;
    (* TABs durch SPACE ersetzen *)
    LOOP j:=Pos (11C,l,0); IF j<0 THEN EXIT END; l[j] := ' ' END;
    j:= Pos ('Mshell',l,0);
    IF j >= 0 THEN
      Insert ('D',j+6,l,ok);
      l[j+1]:=CAP(l[j+1])
    END;
    j:= Pos (' QUALIFIED',l,0);
    IF Pos ('END',l,0) = 0 THEN
      const:= FALSE
    ELSIF j>0 THEN
      Delete (l,j,10,ok);
      export:= TRUE
    ELSIF Pos ('CONST',l,0) >= 0 THEN
      const:= TRUE
    ELSIF export THEN
      up:= TRUE;
      FOR i:= 0 TO Length (l) DO
        ch:= l[i];
        IF letter(ch) & up THEN
          l[i]:= CAP (ch);
          up:= FALSE
        ELSIF ch=',' THEN
          up:= TRUE
        ELSIF ch=';' THEN
          export:= FALSE
        END
      END
    ELSIF const THEN
      i:= 0;
      WHILE (i<Length (l)) & ~letter (l[i]) DO INC (i) END;
      IF i<Length (l) THEN
        l[i]:= CAP (l[i])
      END
    END;
    WriteString (out,l);
    IF EOL (in) THEN
      WriteLn (out);
      InOut.GotoXY (6,2);
      InOut.WriteCard (line,0);
      INC (line);
      IF err (out) THEN RETURN END;
    END
  END;
  Close (out);
  IF err (out) THEN RETURN END;
  Close (in);
  IF err (in) THEN RETURN END;
END ConvRsc.
 
(* $FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF7AA40$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6$FFF142E6�$000006FET.......T.......T.......T.......T......TT.......T.......T.......T.......T.......$00000219$00000498$00000A19$FFF7AA40$FFF7AA40$000006DC$000006CD$000006D9$000006BB$0000069E$000006BB$FFF7AA40$000006DA$000006FE$000006DD$000006D9���*)
