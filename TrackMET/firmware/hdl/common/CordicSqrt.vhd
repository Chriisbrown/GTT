LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY TrackMET;
USE TrackMET.constants.all;
USE TrackMET.ROMConstants.all;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;
USE GTT.GTTDataFormats.ALL;

ENTITY CordicSqrt IS
    GENERIC (n_steps    : NATURAL RANGE 1 TO 8 := 4
    );
    PORT (
        clk  : IN STD_LOGIC := '0';
        Xin  : IN SIGNED ( PtWidth DOWNTO 0 )  := (OTHERS => '0');
        Yin  : IN SIGNED ( PtWidth DOWNTO 0 )  := (OTHERS => '0');
        Root : OUT UNSIGNED ( METMagWidth - 1 DOWNTO 0 ) := (OTHERS => '0');
        Phi  : OUT UNSIGNED ( METPhiWidth - 1 DOWNTO 0 ) := (OTHERS => '0')
    );
END CordicSqrt;

ARCHITECTURE behavioral OF CordicSqrt IS

  TYPE tCordic IS RECORD
    x         : SIGNED( PtWidth DOWNTO 0 );
    y         : SIGNED( PtWidth DOWNTO 0 );
    phi       : UNSIGNED( METPhiWidth - 1 DOWNTO 0 );
    sign      : BOOLEAN;
  END RECORD;

  CONSTANT cEmptyCordic : tCordic := ( ( OTHERS => '0' ) ,  ( OTHERS => '0' ) , ( OTHERS => '0' )  , FALSE );

  TYPE tCordicSteps IS ARRAY( n_steps + 1 DOWNTO 0 ) OF tCordic; -- Number of steps used by the CORDIC
  SIGNAL CordicSteps  : tCordicSteps := ( OTHERS => cEmptyCordic );

  SIGNAL NormedRoot : UNSIGNED( METMagWidth*2 - 1 DOWNTO 0 ) := (OTHERS => '0');
  SIGNAL TempRoot   : UNSIGNED( METMagWidth - 1 DOWNTO 0 ) := (OTHERS => '0');

  SIGNAL NormedPhi  : UNSIGNED( METPhiWidth - 1 DOWNTO 0 ) := (OTHERS => '0');
  SIGNAL TempPhi    : UNSIGNED( METPhiWidth - 1 DOWNTO 0 ) := (OTHERS => '0');

BEGIN

PROCESS( clk ) 
    VARIABLE x_neg , y_neg : BOOLEAN;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      x_neg := ( Xin < 0 );
      y_neg := ( Yin < 0 );

      IF( NOT x_neg AND NOT y_neg ) THEN
        CordicSteps( 0 ) .sign <= True;
        CordicSteps( 0 ) .phi  <= TO_UNSIGNED( 0, METPhiWidth );
        CordicSteps( 0 ) .x    <= Xin;
        CordicSteps( 0 ) .y    <= Yin;
      ELSIF( x_neg AND NOT y_neg ) THEN
        CordicSteps( 0 ) .sign <= False;
        CordicSteps( 0 ) .phi  <= TO_UNSIGNED( CordicPhiScale/2 , METPhiWidth );
        CordicSteps( 0 ) .x    <= -Xin;
        CordicSteps( 0 ) .y    <= Yin;
      ELSIF( x_neg AND y_neg ) THEN
        CordicSteps( 0 ) .sign <= True;
        CordicSteps( 0 ) .phi  <= TO_UNSIGNED( CordicPhiScale/2 , METPhiWidth );
        CordicSteps( 0 ) .x    <= -Xin;
        CordicSteps( 0 ) .y    <= -Yin;
      ELSE
        CordicSteps( 0 ) .sign <= False;
        CordicSteps( 0 ) .phi  <= TO_UNSIGNED( CordicPhiScale , METPhiWidth );
        CordicSteps( 0 ) .x    <= Xin;
        CordicSteps( 0 ) .y    <= -Yin;
    END IF;

  END IF;
END PROCESS;



steps : FOR i IN 1 TO n_steps GENERATE
  PROCESS( clk )
    VARIABLE y_neg : BOOLEAN;
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN
          y_neg := ( CordicSteps( i-1 ) .y < 0 );

          IF y_neg THEN
            CordicSteps( i ) .x <= CordicSteps( i-1 ) .x - SHIFT_RIGHT( CordicSteps( i-1 ) .y , i-1 );
            CordicSteps( i ) .y <= CordicSteps( i-1 ) .y + SHIFT_RIGHT( CordicSteps( i-1 ) .x , i-1 );
          ELSE
            CordicSteps( i ) .x <= CordicSteps( i-1 ) .x + SHIFT_RIGHT( CordicSteps( i-1 ) .y , i-1 );
            CordicSteps( i ) .y <= CordicSteps( i-1 ) .y - SHIFT_RIGHT( CordicSteps( i-1 ) .x , i-1 );
          END IF;

          IF y_neg = CordicSteps( i-1 ) .sign THEN
            CordicSteps( i ) .phi <= CordicSteps( i-1 ) .phi - TO_UNSIGNED( ATanLUT( i-1 ) , METPhiWidth );
          ELSE
            CordicSteps( i ) .phi <= CordicSteps( i-1 ) .phi + TO_UNSIGNED( ATanLUT( i-1 ) , METPhiWidth );
          END IF;


          CordicSteps( i ) .sign <= CordicSteps( i-1 ) .sign;
      END IF;
  END PROCESS;
END GENERATE steps;

PROCESS( clk )
BEGIN
  IF ( RISING_EDGE( clk ) ) THEN
    CordicSteps( n_steps + 1 ) <= CordicSteps( n_steps );
    TempRoot                   <= UNSIGNED(RESIZE(CordicSteps( n_steps + 1 ).x,METMagWidth));  --Buffer for clock constraint on DSP
    TempPhi                    <= UNSIGNED(CordicSteps( n_steps + 1 ).phi);
    NormedRoot                 <= TempRoot*TO_UNSIGNED(RenormLUT( n_steps - 1),METMagWidth);
    NormedPhi                  <= TempPhi;
    Root                       <= TO_UNSIGNED((TO_INTEGER(SHIFT_RIGHT(NormedRoot,PtWidth)) * MaxPt/MaxMETMag),METMagWidth); --Rescale Output MET
    Phi                        <= NormedPhi;  --Divide by 2**6
  END IF;
END PROCESS;


END ARCHITECTURE behavioral;