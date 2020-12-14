-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY InvRdivider IS
  PORT(
    clk           : IN STD_LOGIC := '0';
    NumeratorIn   : IN UNSIGNED( 19 DOWNTO 0);
    DenominatorIn : IN UNSIGNED( 17 DOWNTO 0 );
    IntegerOut    : OUT UNSIGNED( 19 DOWNTO 0 ) := ( OTHERS => '0' );
    FractionOut   : OUT UNSIGNED( 17 DOWNTO 0 )       := ( OTHERS => '0' )
  );
END InvRdivider;

ARCHITECTURE behavioral OF InvRdivider IS

  TYPE tDivisionLUT IS ARRAY( 0 TO 511 ) OF UNSIGNED( 35 DOWNTO 0 );

  FUNCTION PrepareDivisionLUTs RETURN tDivisionLUT IS
    VARIABLE lRet : tDivisionLUT := ( OTHERS => ( OTHERS => '0' ) );
  BEGIN
    FOR i IN 1 TO 511 LOOP
      lRet( i ) := TO_UNSIGNED( INTEGER( ROUND( REAL( ( 2.0 ** 24.0 ) -1.0 ) / REAL( i * i ) ) ) , 36 ); -- Effectively a fraction of 2^24, but in 24-bits not 25
    END LOOP;
    RETURN lRet;
  END PrepareDivisionLUTs;

  CONSTANT DivisionLUT               : tDivisionLUT := PrepareDivisionLUTs;
  ATTRIBUTE ram_style                : STRING;
  ATTRIBUTE ram_style OF DivisionLUT : CONSTANT IS "block";


  SIGNAL Numerator1                  : UNSIGNED( NumeratorIn'RANGE )                  := ( OTHERS => '0' );
  SIGNAL Denominator1                : UNSIGNED( 17 DOWNTO 0 )                        := ( OTHERS => '0' );
  SIGNAL RequiredShift1              : INTEGER RANGE 0 TO 9                           := 0;

  SIGNAL Numerator2                  : UNSIGNED( NumeratorIn'RANGE )                  := ( OTHERS => '0' );
  SIGNAL Denominator2                : UNSIGNED( 17 DOWNTO 0 )                        := ( OTHERS => '0' );
  SIGNAL RequiredShift2              : INTEGER RANGE 0 TO 9                           := 0;

  SIGNAL Numerator3                  : UNSIGNED( NumeratorIn'RANGE )                  := ( OTHERS => '0' );
  SIGNAL Difference3                 : UNSIGNED( 17 DOWNTO 0 )                        := ( OTHERS => '0' );
  SIGNAL LUToutput3                  : UNSIGNED( 35 DOWNTO 0 )                        := ( OTHERS => '0' );
  SIGNAL RequiredShift3              : INTEGER RANGE 0 TO 9                           := 0;

  SIGNAL Numerator4                  : UNSIGNED( NumeratorIn'RANGE )                  := ( OTHERS => '0' );
  SIGNAL DspOut4                     : UNSIGNED( 24 DOWNTO 0 )                        := ( OTHERS => '0' );
  SIGNAL RequiredShift4              : INTEGER RANGE 0 TO 9                           := 0;

  SIGNAL Result5                     : UNSIGNED( ( NumeratorIn'HIGH + 25 ) DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL RequiredShift5              : INTEGER RANGE 0 TO 9                           := 0;

BEGIN

  PROCESS( clk )
    VARIABLE DspOutFull4 : UNSIGNED( 41 DOWNTO 0 )                        := ( OTHERS => '0' );
    VARIABLE Padded      : UNSIGNED( ( NumeratorIn'HIGH + 27 ) DOWNTO 0 ) := ( OTHERS => '0' );

  BEGIN
    IF RISING_EDGE( clk ) THEN

-- ----------------------------------------------------------------------------------------------
-- Clock 1
    Numerator1   <= NumeratorIn;
    Denominator1 <= DenominatorIn;

    FOR i IN 0 TO 9 LOOP -- We loop until we see a '1' in the MSB, else we know that at 9 we have shifted all zeros into the lower-half of the word.
      RequiredShift1 <= i;
      IF( DenominatorIn( 17-i ) = '1' ) THEN
        EXIT;
      END IF;
    END LOOP;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 2
    Numerator2                               <= Numerator1;
    Denominator2                             <= ( OTHERS => '0' );
    Denominator2( 17 DOWNTO RequiredShift1 ) <= Denominator1( 17 - RequiredShift1 DOWNTO 0 );
    RequiredShift2                           <= RequiredShift1;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 3
    Numerator3                               <= Numerator2;
    Difference3                              <= ( Denominator2( 17 DOWNTO 9 ) & "000000000" ) - ( "000000000" & Denominator2( 8 DOWNTO 0 ) );
    LUToutput3                               <= PrepareDivisionLUTs( TO_INTEGER( Denominator2( 17 DOWNTO 9 ) ) );
    RequiredShift3                           <= RequiredShift2;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 4
    DspOutFull4 := Difference3 * LUToutput3( 23 DOWNTO 0 ); -- 18 x 24bit = 1 DSP48e
    DspOut4        <= DspOutFull4( 41 DOWNTO 17 ); -- Use the built-in 17-bit shifter in the DSP48e
    Numerator4     <= Numerator3;
    RequiredShift4 <= RequiredShift3;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 5
    Result5        <= Numerator4 * DspOut4;
    RequiredShift5 <= RequiredShift4;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 6
    Padded := Result5 & "00";
    IntegerOut  <= Padded( NumeratorIn'HIGH + ( 27-RequiredShift5 ) DOWNTO( 27-RequiredShift5 ) );
    FractionOut <= Padded( ( 26-RequiredShift5 ) DOWNTO( 9-RequiredShift5 ) );
-- ----------------------------------------------------------------------------------------------

    END IF;
  END PROCESS;


END ARCHITECTURE behavioral;
