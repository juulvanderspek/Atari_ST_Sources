/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include <PORTAB.H>
#include	<TOS.H>
#include	<VDI.H>
#include	<MT_AES.H>

#include	<STRING.H>
#include	<STDLIB.H>

/*----------------------------------------------------------------------------------------*/ 
/* Prototypen																										*/
/*----------------------------------------------------------------------------------------*/ 

void	cdecl	display( WORD x, WORD y, WORD *clip_rect, LONG id, LONG pt, LONG ratio, BYTE *string );
WORD open_screen_wk( WORD aes_handle, WORD *work_out );
WORD			wlf_available( void );

/*----------------------------------------------------------------------------------------*/ 
/* Globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/ 

WORD	app_id;
WORD	aes_handle;
WORD	pwchar;
WORD	phchar;
WORD	pwbox;
WORD	phbox;

WORD	work_out[57];
WORD	vdi_handle;

/*----------------------------------------------------------------------------------------*/ 
/* Applikationseigene Fonts - Beispielstrukturen														*/
/*----------------------------------------------------------------------------------------*/ 

BYTE	test_pts[2] = { 12, 15 };										/* 12 und 15 Punkt sind vordefiniert */

FNTS_ITEM	calamus_sample = 
{
	0L,																		/* kein weiterer Font */
	display,																	/* Zeiger auf Anzeige-Funktion */
	400001L,																	/* ID, mu� f�r applikationseigene Fonts >= 65536 sein */
	0,																			/* kein Index, da applikationseigen */
	0,																			/* proportionaler Font */
	1,																			/* Vektorfont */
	2,																			/* 2 vordefinierte Punkth�hen */
	"Calamus-Beispiel? Italic",										/* vollst�ndiger Fontname */
	"Calamus-Beispiel?",													/* Name der Fontfamilie */
	"Italic",																/* Name des Stils */
	test_pts,																/* Zeiger auf ein Feld mit den vordefinierten Punkth�hen */
	{ 0L, 0L, 0L, 0L }													/* reserviert, mu� 0 sein */
};

FNTS_ITEM	signum_sample =
{
	&calamus_sample,														/* Zeiger auf den n�chsten Font */
	display,																	/* Zeiger auf Anzeige-Funktion */
	400000L,																	/* ID, mu� f�r applikationseigene Fonts >= 65536 sein */
	0,																			/* kein Index, da applikationseigen */
	1,																			/* �quidistanter Font (monospaced) */
	0,																			/* Bitmapfont */
	2,																			/* 2 vordefinierte Punkth�hen */
	"Signum-Beispiel? Roman",											/* vollst�ndiger Fontname */
	"Signum-Beispiel?",													/* Name der Fontfamilie */
	"Roman",																	/* Name des Stils */
	test_pts,																/* Zeiger auf ein Feld mit den vordefinierten Punkth�hen */
	{ 0L, 0L, 0L, 0L }													/* reserviert, mu� 0 sein */
};

/*----------------------------------------------------------------------------------------*/ 
/* Makros																											*/
/*----------------------------------------------------------------------------------------*/ 

#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP )

#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE + FNTS_SRATIO + FNTS_CHNAME + FNTS_CHSTYLE + FNTS_CHSIZE + FNTS_CHRATIO + FNTS_RATIO + FNTS_BSET + FNTS_BMARK )

/*----------------------------------------------------------------------------------------*/ 
/* Virtuelle Bildschirm-Workstation �ffnen																*/
/* Funktionsresultat:	VDI-Handle oder 0 (Fehler)														*/
/*	aes_handle:				Handle der vom AES benutzten Workstation									*/
/* work_out:				Ger�teinformationen																*/
/*----------------------------------------------------------------------------------------*/ 
WORD open_screen_wk( WORD aes_handle, WORD *work_out )
{
	WORD	work_in[11];
	WORD	handle;
	WORD	i;
			
	for( i = 1; i < 10 ; i++ )											/* work_in initialisieren */
		work_in[i] = 1;
		
	work_in[0] = Getrez() + 2;											/* Aufl�sung */
	work_in[10] = 2;														/* Rasterkoordinaten benutzen */
	handle = aes_handle;

	v_opnvwk( work_in, &handle, work_out );
	
	return( handle );
}

/*----------------------------------------------------------------------------------------*/ 
/* Beispielfunktion zur Anzeige applikationseigener Fonts											*/
/*	Der Code ist Dummycode. Bei einer Applikation die Signum-Fonts verwendet, m��te hier	*/
/*	z.B. die interne Ausgabefunktion aufgerufen werden. Der auszugebende Text sollte			*/
/*	linksjustiert und mit der Basislinie als Bezugspunkt ausgegeben werden.						*/
/*																														*/
/* Funktionsresultat:	-																						*/
/*	x:							x-Koordinate der Zeichenkette													*/
/*	y:							y-Koordinate der Zeichenkette													*/
/*	clip_rect:				Zeiger auf Clipping-Rechteck													*/
/*	id:						ID des Fonts																		*/
/*	pt:						H�he in 1/65536 Punkten															*/
/*	ratio:					Verh�ltnis Breite/H�he in 1/65536											*/
/*	string:					Zeiger auf den Beispieltext													*/
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	display( WORD x, WORD y, WORD clip_rect[4], LONG id, LONG pt, LONG ratio, BYTE *string )
{
	extern WORD	vdi_handle;
	WORD	dummy;

	vswr_mode( vdi_handle, 2 );
	vs_clip( vdi_handle, 1, clip_rect );
	
	vst_font( vdi_handle, 1 );
	vst_height( vdi_handle, 4, &dummy, &dummy, &dummy, &dummy );
	vst_alignment( vdi_handle, 0, 0, &dummy, &dummy );
	vst_color( vdi_handle, 1 );
	v_gtext( vdi_handle, x, y, "Beispiel f�r applikationseigene Fonts..." );
}

/*----------------------------------------------------------------------------------------*/ 
/* Testen, ob wdlg_xx()/lbox_xx()/fnts_xx()-Funktionen vorhanden sind							*/
/* Funktionsresultat:	1: vorhanden, 0: nicht vorhanden												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wlf_available( void )
{
	if ( appl_find( "?AGI" ) == 0 )									/* appl_getinfo() vorhanden? */
	{
		WORD	ag1;
		WORD	ag2;
		WORD	ag3;
		WORD	ag4;

		if ( appl_getinfo( 7, &ag1, &ag2, &ag3, &ag4 ))			/* Unterfunktion 7 aufrufen */
		{
			if (( ag1 & 7 ) == 7 )										/* wdlg_xx()/lbox_xx()/fnts_xx() vorhanden? */
				return( 1 );
		}	
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Hauptprogramm																									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	main( void )
{
	extern WORD	app_id;
	extern WORD	aes_handle;
	extern WORD	pwchar;
	extern WORD	phchar;
	extern WORD	pwbox;
	extern WORD	phbox;
	
	FNT_DIALOG	*fnt_dialog;
	
	app_id = appl_init();

	if( app_id != -1 )													/* Anmeldung erfolgreich? */
	{
		if ( wlf_available())											/* Dialogroutinen vorhanden? */
		{
			aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );
			graf_mouse( ARROW, 0L );										/* Mauszeiger anschalten */
			vdi_handle = open_screen_wk( aes_handle, work_out );	/* Workstation �ffnen */
	
			if( vdi_handle != 0 )
			{
				fnt_dialog = fnts_create( vdi_handle, 0, FONT_FLAGS, FNTS_3D,
												  "Was Shake'beer Your Favourite Poet?",
												  "frei belegbar" );
	
				if ( fnt_dialog )
				{
					LONG	id;
					LONG	pt;
					LONG	ratio;
					WORD	x;
					WORD	y;

					fnts_add( fnt_dialog, &signum_sample );			/* eigene Fonts hinzuf�gen */
					
					id = 1;														/* Systemfont */
					pt = 10L << 16;											/* 10 Punkt einstellen */
					ratio = 1L << 16;											/* Verh�ltnis 1/1 (Bitmapfonts k�nnen nicht gestaucht oder gedehnt werden) */
					x = -1;
					y = -1;
	
					if ( fnts_open( fnt_dialog, BUTTON_FLAGS, x, y, id, pt, ratio ))
					{
						EVNT	evnts;
						WORD	button;
						WORD	check_boxes;
						WORD	cont;
						
						cont = 1;												/* weitermachen... */
						
						while( cont )
						{
							EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG, 2, 1, 1,	0L, 0L, 0L, &evnts );
					
							if	( fnts_evnt( fnt_dialog, &evnts, &button, &check_boxes, &id, &pt, &ratio ) == 0 )
							{
								switch ( button )
								{
									case	FNTS_CANCEL:						/* "Abbruch" */
									{
										cont = 0;								/* Schleife beenden */
										break;
									}
									case	FNTS_OK:								/* "OK" */
									{
										/* markierte Bereiche sollten auf die �bergebenen */
										/*	Attribute gesetzt werden; der Dialog mu� */
										/* geschlossen werden. */
	
										cont = 0;								/* Schleife beenden */
										break;
									}
									case	FNTS_SET:							/* "setzen" */
									{
										/* markierte Bereiche sollten auf die �bergebenen */
										/*	Attribute gesetzt werden; der Dialog sollte wird */
										/* nicht geschlossen */
	
										break;
									}
									case	FNTS_MARK:							/* "markieren" */
									{
										/* wenn das Markieren unterst�tzt wird sollten jetzt */
										/* alle Bereiche mit dem Font <id> in der H�he <pt> */
										/*	mit dem Breite/H�he-Verh�ltnis <ratio> markiert */
										/* werden. Wenn das Programm die Checkboxen f�r Name, */
										/* Stil, H�he und Seitenverh�ltnis unterst�tzt, sollte */
										/* au�erdem noch <check_boxes> beachtet werden. */
										
										break;
									}
									case	FNTS_OPT:							/* beliebiger Button-Text */
									{
										/* hier k�nnte jetzt ein applikationsspezifischer */
										/* Dialog (besser Fensterdialog) ge�ffnet werden */
										/* ...beispielsweise f�rs Kerning oder...*/
	
										form_alert( 1, "[0][Hier kann ein beliebiger|Dialog ge�ffnet werden.][OK]" );
										break;
									}
								}
							}
						}
				
						fnts_close( fnt_dialog, &x, &y );				/* Fenster des Fontdialogs schlie�en */
					}
					fnts_remove( fnt_dialog );								/* eigene Fonts entfernen */
					fnts_delete( fnt_dialog, vdi_handle );				/* Speicher f�r Fontdialog freigeben */
				}
				v_clsvwk( vdi_handle );
			}
		}		
		else
			form_alert( 1, "[1][Bitte starten Sie die System-|erweiterung WDIALOG.][Ende]" );

		appl_exit();
	}
	return( 0 );
}
