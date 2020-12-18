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

LIBRARY InTTTrack;
USE InTTTrack.DataType;
USE InTTTrack.ArrayTypes;

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
ENTITY TrackTransform IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk              : IN STD_LOGIC := '0'; -- The algorithm clock
    TTTrackPipeIn    : IN InTTTrack.ArrayTypes.VectorPipe;
    TTTrackPipeOut   : OUT TTTrack.ArrayTypes.VectorPipe
  );
END TrackTransform;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF TrackTransform IS
  SIGNAL Output : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  COMPONENT InvRdivider IS

    PORT(
      clk : IN STD_LOGIC; -- clock
      NumeratorIn   : IN UNSIGNED;
      DenominatorIn : IN UNSIGNED( 17 DOWNTO 0 );
      IntegerOut    : OUT UNSIGNED( 19 DOWNTO 0 ) := ( OTHERS => '0' );
      FractionOut   : OUT UNSIGNED( 17 DOWNTO 0 ) := ( OTHERS => '0' )
    );
  END COMPONENT InvRdivider;

BEGIN

-- -------------------------------------------------------------------------
  g1              : FOR i IN 0 TO 17 GENERATE
    SIGNAL lTTTrack    : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;

    
    SIGNAL InvR : UNSIGNED( 17 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL IntOut : UNSIGNED( 19 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL FracOut : UNSIGNED( 17 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL temp_eta : INTEGER := 0;

    SIGNAL temp_trk1     : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;
    SIGNAL temp_trk2     : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;
    SIGNAL temp_trk3     : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;
    SIGNAL temp_trk4     : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;
    SIGNAL temp_trk5     : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;
    SIGNAL temp_trk6     : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;
    SIGNAL temp_trk7     : InTTTrack.DataType.tData := InTTTrack.DataType.cNull;

    SIGNAL GlobalPhi1 : INTEGER := 0;
    SIGNAL GlobalPhi2 : INTEGER := 0;
    SIGNAL GlobalPhi3 : INTEGER := 0;

    SIGNAL tmp_z : INTEGER := 0;
    SIGNAL tmp_z1 : INTEGER := 0;
    SIGNAL tmp_z2 : INTEGER := 0;
    SIGNAL tmp_z3 : INTEGER := 0;

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
        temp_trk1   <= lTTTrack;
        InvR        <= TO_UNSIGNED( abs(TO_INTEGER( lTTTrack.InvR )),18 );
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 2
        temp_trk2   <= temp_trk1;
         
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 3
        temp_trk3   <= temp_trk2;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 4
        temp_trk4     <= temp_trk3;
        IF temp_trk3.Z0Frac(temp_trk3.Z0Frac'left) = '1' THEN --negative
          IF temp_trk3.Z0Int >= 15 THEN
            tmp_z <= 0;
          ELSE
            tmp_z <= -TO_INTEGER(temp_trk3.Z0Int)*8 + TO_INTEGER(temp_trk3.Z0Frac)/8 + TO_INTEGER(temp_trk3.Z0Frac)/64 + 128 - TO_INTEGER(temp_trk3.Z0Int)/2;
          END IF;
        ELSE  --positive
          IF temp_trk3.Z0Int >= 15 THEN
            tmp_z <= 255;
          ELSE
            tmp_z <= TO_INTEGER(temp_trk3.Z0Int)*8 + TO_INTEGER(temp_trk3.Z0Frac)/8 + TO_INTEGER(temp_trk3.Z0Frac)/64 + 128 + TO_INTEGER(temp_trk3.Z0Int)/2;
          END IF;
        END IF;

-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 5
        temp_trk5    <= temp_trk4;
        tmp_z1       <= tmp_z;
        GlobalPhi1   <= TO_INTEGER(temp_trk4.phi) + Phi_shift(i) - 1024;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 6
        temp_trk6  <= temp_trk5;
        tmp_z2    <= tmp_z1;

        IF GlobalPhi1 < 0 THEN
          GlobalPhi2 <= GlobalPhi1 + 6268;
        ELSIF GlobalPhi1 > 6268 THEN
          GlobalPhi2 <= GlobalPhi1 - 6268; 
        ELSE
          GlobalPhi2 <= GlobalPhi1;
        END IF;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 7
        temp_trk7    <= temp_trk6;
        tmp_z3       <= tmp_z2;
        temp_eta     <= TanLLUT(TO_INTEGER(temp_trk6.tanlfrac))(abs(TO_INTEGER(temp_trk6.tanlint)));
        GlobalPhi3   <= GlobalPhi2;
-- ----------------------------------------------------------------------------------------------
-- Clock 8
        Output( i ).Pt  <= TO_UNSIGNED(TO_INTEGER(IntOut)+TO_INTEGER(FracOut)/2**18,16);
        Output( i ).Phi <= TO_UNSIGNED(GlobalPhi3,13);
        Output( i ).Eta <= TO_UNSIGNED(temp_eta,16);
        Output( i ).Z0  <= TO_UNSIGNED(tmp_z3,8);
        Output( i ).Chi2rphi   <= temp_trk7.Chi2rphi;
        Output( i ).Chi2rz     <= temp_trk7.Chi2rz;
        Output( i ).BendChi2   <= temp_trk7.BendChi2;
        Output( i ).Hitpattern <= temp_trk7.Hitpattern;
        Output( i ).DataValid  <= temp_trk7.DataValid;
        Output( i ).FrameValid <= temp_trk7.FrameValid;
        
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
