DEFINITION MODULE VDIRasters;


(*  Megemax-Modula 2 GEM-Library :  Die VDI Rasterfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  04.11.87
 *
 *  Version   2.2     V#0011
 *)
 
(*      Die Routinen dieses Moduls bieten zum einen die M�glichkeit,
 *      beliebige Grafikausschnitte zu verschieben und zum anderen
 *      kann die Farbe beliebiger Pixel ermittelt werden.
 *      Der Arbeitsbereich der Kopierroutinen ist nicht auf die VDI
 *      Ger�te beschr�nkt, vielmehr kann man nahezu unbeschr�nkt auf
 *      beliebige Speicherbereiche zugreifen. Dazu ist es aber n�tig
 *      den Aufbau des zu verwendenden Speicherausschnittes in einem
 *      Memory Form Definition Block (kurz: MFDB) zu beschreiben. Den
 *      von dem MFDB beschriebenen Speicher kann man sich als einen
 *      in seiner Gr��e (fast) frei w�hlbaren Bildschirmspeicher vor-
 *      stellen. Diese Assoziation erkl�rt auch die im MFDB-Record
 *      gew�hlten Field-Bezeichner.
 *      Eine genauere Beschreibung des MFDB befindet sich im Modul
 *      'GrafBase'.
 *
 *      Die beiden Routinen 'CopyOpaque' und 'CopyTrans' werden, falls
 *      eingebaut und aktiviert vom Blitter ausgef�hrt.
 *)
 
 
FROM    GrafBase IMPORT Point, Rectangle, MemFormDef, PtrMemFormDef,
                        WritingMode, BitOperation;

FROM    GEMEnv  IMPORT  DeviceHandle;
 
 
PROCEDURE CopyOpaque (handle                : DeviceHandle;
                      sourceMem, destMem    : PtrMemFormDef;
                      sourceFrame, destFrame: Rectangle;
                      mode                  : BitOperation);
                     
        (*  Diese Routine kopiert einen beliebigen Ausschnitt des Quell-
         *  bereichs an eine frei w�hlbare Stelle des Zielbereichs.
         *  Daf�r m��en beide Bereiche im ger�tespezifischen Format vor-
         *  liegen und sie m��en die gleiche Anzahl an Bitebenen (planes)
         *  besitzen.
         *
         *  'sourceMem'   -- Quellbereich
         *  'destMem'     -- Zielbereich
         *  'sourceframe' -- bestimmt, welcher Teil des Quellbereichs
         *                   nun kopiert wird, indem dort einfach das zu
         *                   kopierende Rechteck angegeben wird.
         *  'destframe'   -- ..des Zielbereichs..
         *  'mode'        -- bestimmt, auf welche Art beide Bereiche ver-
         *                   kn�pft werden.
         *)

PROCEDURE CopyTrans (handle                : DeviceHandle;
                     sourceMem, destMem    : PtrMemFormDef;
                     sourceFrame, destFrame: Rectangle;
                     mode                  : WritingMode;
                     setCol, unsetCol      : CARDINAL);
                    
        (*  Bei dieser Procedur wird ein einfarbiger Rechteckbereich
         *  auf einen mehrfarbigen Rechteckbereich  kopiert.
         *
         *  'sourceMem'   -- Quellbereich. Mu� hier einfarbig sein, d.h.
         *                   er darf nur aus einer Bitebene (plane) be-
         *                   hen.
         *  'destMem'     -- Zielbereich ist beliebig
         *  'sourceframe' -- bestimmt, welcher Teil des Quellbereichs
         *                   nun kopiert wird, indem dort einfach das zu
         *                   kopierende Rechteck angegeben wird.
         *  'destframe'   -- ..des Zielbereichs..
         *  'mode'        -- Schreibmodus
         *  'unsetCol'    -- die ungesetzten Bits werden mit der hier ange-
         *                   gebenen Farbe kopiert.
         *  'setCol'      -- die gesetzten Bits werden mit der hier angege-
         *                   benen Farbe kopiert.
         *)
         
PROCEDURE TransformForm (    handle            : DeviceHandle;
                         VAR sourceMem, destMem: MemFormDef);

        (*  Damit k�nnen Rasterbereiche vom ger�tespezifischen in das
         *  Standardformat umgewandelt werden und umgekehrt.
         *)

PROCEDURE PixelState (    handle: DeviceHandle;
                          toTest: Point;
                      VAR color : CARDINAL;
                      VAR set   : BOOLEAN);
                     
        (*  Hiermit kann der Zustand eines einzelnen Pixels erfragt wer-
         *  den.
         *
         *  'toTest'    -- Enth�lt die Koordinaten des Pixels
         *  'color'     -- liefert den aktuellen Farbindex des Pixels
         *  'set'       -- '=TRUE', so ist das Pixel gesetzt, sonst be-
         *                 sitzt es die Hintergrundfarbe.
         *)

END VDIRasters.