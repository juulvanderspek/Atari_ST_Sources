#include <stdio.h>
#include <math.h>


long
	values[856];


main ()
{
	FILE
		*fd;
	double
		freq_amiga,
		freq_st,
		freqtimer,
		work;
	int
		divf,
		freqson;

	printf ("Timer Frequency? ");
	fflush (stdout);
	scanf ("%d", &divf);
	divf *= 10;
	freq_amiga = 1 / (2.79365 * poweri ((double)4.0, -7));
	freq_st = (2.4576 * poweri ((double)4.0, 6)) / (double)divf;
	freqtimer = freq_amiga / freq_st;
	for (freqson=1; freqson<=856; freqson++)
	{
		work = freqtimer / (double)freqson;
		work *= 65536.0;
		values[freqson - 1] = (long)work;
	}
	values[0] = 0L;

	unlink ("BORIS.BIN");
	fd = fopen ("BORIS.BIN", "bw");
	fwrite (values, sizeof (long), 856, fd);
	fclose (fd);
}

/*
' The 'Timer Frequency' is the MFP Timer Delay Value constant.
' In English this is the delay before playing the next sample byte e.g
' to calculate what frequency output we get from a timer value we use the
' following formula :-         614400/timerval
' So if 'timerval' is 60 then  614400/60 = 10240hz = 10khz
'
a$=SPACE$(857*4)
INPUT "Timer Frequency?",divf
divf=divf*10
freq_amiga=1/(2.79365*4^-7)
freq_st=(2.4576*4^6)/divf
freqtimer=freq_amiga/freq_st
adrdeb=VARPTR(a$)
adrfin=adrdeb
FOR freqson%=1 TO 856 STEP 1
  work=freqtimer/freqson%
  MUL work,65536
  LPOKE adrfin,work
  adrfin=adrfin+4
NEXT freqson%
LPOKE adrdeb,0
long=adrfin-adrdeb
BSAVE "freq.bin",adrdeb,long
*/
