/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"RANDOM.H"


/* ###################################################################################
#  DATA
################################################################################### */

uU32	gRandomSeed;


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : Random_Init( void )
* ACTION   : called at start of app
* CREATION : 26.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Random_Init( void )
{
	gRandomSeed.l     = 0x12345678L;
	gRandomSeed.b.b0 += (U8)(*((U8*)0xFFFF8209L));
	gRandomSeed.l    += *((U32*)0x466L);
	gRandomSeed.l    += *((U32*)0x4BAL);
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Random_DeInit( void )
* ACTION   : called at end of app
* CREATION : 26.01.01 PNK
*-----------------------------------------------------------------------------------*/
void			Random_DeInit( void )
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Random_Update( void )
* ACTION   : called every game frame
* CREATION : 13.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Random_Update( void )
{
	gRandomSeed.l *= 69069L;
	gRandomSeed.l += 41;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Random_GetClamped( U16 aMax )
* ACTION   : returns random number between 0..aMax
* CREATION : 13.01.01 PNK
*-----------------------------------------------------------------------------------*/

U16	Random_GetClamped( U16 aMax )
{
	uU32	lNum;

	lNum.w.w1 = 0;
	lNum.w.w0 = aMax;

	lNum.l    = aMax;
	lNum.l   *= gRandomSeed.w.w0;

	gRandomSeed.l *= 69069L;
	gRandomSeed.l += 41;

	if( lNum.w.w0 > 0x7FFF )
	{
		lNum.w.w1++;
	}

	if( lNum.w.w1 > aMax )
	{
		lNum.w.w1 = aMax;
	}

	return( lNum.w.w1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Random_Get( void )
* ACTION   : returns random number
* CREATION : 13.01.01 PNK
*-----------------------------------------------------------------------------------*/

U32			Random_Get( void )
{
	gRandomSeed.l *= 69069L;
	gRandomSeed.l += 41;

	return( gRandomSeed.l );
}


/* ################################################################################ */
