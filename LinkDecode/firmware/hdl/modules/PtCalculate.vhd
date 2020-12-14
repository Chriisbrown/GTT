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


-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;



library LinkDecode;
USE LinkDecode.InvRdivider;
USE LinkDecode.TanLROM.all;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY PtCalculate IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk              : IN STD_LOGIC := '0'; -- The algorithm clock
    TTTrackPipeIn    : IN TTTrack.ArrayTypes.VectorPipe;
    TTTrackPipeOut   : OUT TTTrack.ArrayTypes.VectorPipe
  );
END PtCalculate;
-- -------------------------------------------------------------------------



-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF PtCalculate IS
  SIGNAL Output : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  COMPONENT InvRdivider IS

    PORT(
      clk : IN STD_LOGIC; -- clock
      NumeratorIn   : IN UNSIGNED;
      DenominatorIn : IN UNSIGNED( 17 DOWNTO 0 );
      IntegerOut    : OUT UNSIGNED( 19 DOWNTO 0 ) := ( OTHERS => '0' );
      FractionOut   : OUT UNSIGNED( 17 DOWNTO 0 )       := ( OTHERS => '0' )
    );
  END COMPONENT InvRdivider;

BEGIN

-- -------------------------------------------------------------------------
  g1              : FOR i IN 0 TO 17 GENERATE
    SIGNAL lTTTrack    : TTTrack.DataType.tData := TTTrack.DataType.cNull;

    
    SIGNAL InvR : UNSIGNED( 17 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL IntOut : UNSIGNED( 19 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL FracOut : UNSIGNED( 17 DOWNTO 0 ) := ( OTHERS => '0' );

    SIGNAL temp_z01     : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL temp_z02     : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL temp_z03     : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL temp_z04     : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL temp_z05     : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL temp_z06     : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL temp_z07     : TTTrack.DataType.tData := TTTrack.DataType.cNull;


  BEGIN

    Divider : InvRdivider
    PORT MAP(
      clk => clk, -- clock
      NumeratorIn   => TO_UNSIGNED(700573,20),
      DenominatorIn => InvR,
      IntegerOut    => IntOut,
      FractionOut   => FracOut
    );

    lTTTrack <= TTTrackPipeIn( PipeOffset )( i );
    
    PROCESS( clk )
    BEGIN
      IF RISING_EDGE( clk ) THEN
-- ----------------------------------------------------------------------------------------------
-- Clock 1
        temp_z01         <= lTTTrack;
        InvR             <= TO_UNSIGNED( abs(TO_INTEGER( lTTTrack.InvR )),18 );
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 2
        temp_z02     <= temp_z01;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 3
        temp_z03     <= temp_z02;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 4
        temp_z04     <= temp_z03;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 5
        temp_z05     <= temp_z04;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 6
        temp_z06     <= temp_z05;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 7
        temp_z07     <= temp_z06;
-- ----------------------------------------------------------------------------------------------
        Output( i )         <= temp_z07;
        Output( i ) .eta    <= TO_UNSIGNED(TanLLUT(TO_INTEGER(temp_z07.tanlfrac))(abs(TO_INTEGER(temp_z07.tanlint))));
        report "InvR"& Integer'image(TO_INTEGER(temp_z07.InvR));
        report "IntOut"& Integer'image(TO_INTEGER(IntOut));
        report "FracOut"& Integer'image(TO_INTEGER(FracOut));
        report "Pt"& Integer'image(TO_INTEGER(TO_UNSIGNED(TO_INTEGER(IntOut)*2,16)));
        Output( i ) .Pt     <= TO_UNSIGNED(TO_INTEGER(IntOut)+TO_INTEGER(FracOut)/2**18,16);


      END IF;
    END PROCESS;
  END GENERATE;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY TTTrack.DataPipe
  PORT MAP( clk , Output , TTTrackPipeOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY TTTrack.Debug
  GENERIC MAP( "PtCalculate" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;
