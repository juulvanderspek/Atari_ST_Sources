DEFINITION MODULE Console;

(*
 * Dieses Modul stellt Funktionen zur Ausgabe auf den Bildschirm bzw. Eingabe
 * von der Tastatur zur Verf�gung.
 *
 * Entgegen den Funktionen des Moduls 'Terminal', die das BIOS f�r die
 * Ein-/Ausgabe nutzen, werden hier die GEMDOS-Routinen verwendet.
 *
 * Die GEMDOS-Routinen sind etwas langsamer und sie erlauben das
 * Abbrechen des laufenden Programms durch Eingabe von <Control-C>.
 * Daf�r erlaubt das GEMDOS die Umlenkung der Ein-/Eusgabe auf Dateien
 * von au�erhalb (vom aufrufenden Programm aus).
 *
 * So ist dieses Modul 'Console' vor Allem dann zu verwenden, wenn
 * das endg�ltige Programm als gelinkte Version unter Command-Shells
 * verwendet werden soll, die diese Datei-Umleitung im Allgemeinen
 * erm�glichen.
 *
 * Sind die Funktionen in diesem Modul nicht ausreichend, k�nnen
 * zus�tzlich die Funktionen direkt aus dem Modul GEMDOS verwendet werden.
 * Dann kann auch das Modul 'StringEditor' zur komfortableren Texteingabe
 * herangezogen werden.
 *
 * Sollen Zahlen ein- oder ausgegeben werden, sind dazu die hiesigen Proze-
 * duren 'ReadString' und 'WriteString' sowie die String-Umwandlungsfunktio-
 * nen des Moduls 'StrConv' zu benutzen.
 *)

PROCEDURE Write (ch: CHAR);
  (* Ausgabe eines Zeichens *)

PROCEDURE WriteString (REF str: ARRAY OF CHAR);
  (* Ausgabe eines Strings *)

PROCEDURE WriteLn;
  (* Ausgabe eines CR / LF. (Sprung in n�chste Zeile) *)

PROCEDURE Read (VAR ch: CHAR);
  (* Eingabe eines Zeichen mit Echo *)

PROCEDURE ReadLine (VAR str: ARRAY OF CHAR);
  (*
   * Eingabe einer Zeile.
   * Dazu wird die GEMDOS-Funktion Nr. 10, "readline", verwendet.
   * > Das eingegebene Return- oder LF-Zeichen wird nicht mit ausgegeben,
   *   soda� der Cursor nach dem Aufruf hinter der Eingabe stehen bleibt.
   *)

PROCEDURE BusyRead (VAR c: CHAR);
  (*
   * Wenn Taste im Puffer ansteht, wird sie in 'c' geliefert,
   * sonst enth�lt 'c' nach dem Aufruf 0C. Die Funktion kehrt
   * auf jeden Fall sofort ohne Warten auf eine Taste zur�ck.
   *)

PROCEDURE KeyPressed (): BOOLEAN;
  (*
   * Liefert TRUE, wenn eine Taste ansteht.
   *)

PROCEDURE FlushKbd;
  (*
   * L�scht Tastaturpuffer
   *)

END Console.
