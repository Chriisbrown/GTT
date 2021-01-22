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

LIBRARY LinkDecode;
USE LinkDecode.InvRdivider;
USE LinkDecode.TanLROM.all;
USE LinkDecode.Constants.all;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ENTITY TrackTransform IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk              : IN STD_LOGIC; -- The algorithm clock
    TTTrackPipeIn    : IN InTTTrack.ArrayTypes.VectorPipe := InTTTrack.ArrayTypes.NullVectorPipe( 10 , 18 ); --In Tracks of type LinkIn tracks
    TTTrackPipeOut   : OUT TTTrack.ArrayTypes.VectorPipe := TTTrack.ArrayTypes.NullVectorPipe( 10 , 18 )  --Out Tracks of type transformed tracks
  );
END TrackTransform;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF TrackTransform IS
  SIGNAL Output : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );

  PROCEDURE RescaleZ0 (SIGNAL TTTrack : IN InTTTrack.DataType.tData;   --Procedure rescaling Z for vertex finder
                       SIGNAL z0      : OUT Integer) IS
    VARIABLE tmp_z : INTEGER := 0;

    BEGIN
    IF TTTrack.Z0Frac(TTTrack.Z0Frac'left) = '1' THEN --negative
      IF TTTrack.Z0Int >= ZMax THEN
        tmp_z := Zsaturate( 0 );  -- Saturate at out of range Z
      ELSE   --Approximation of z0 transformation that saves complex division and multiplications
        tmp_z := (- TO_INTEGER(TTTrack.Z0Int)*8   - TO_INTEGER(TTTrack.Z0Int)/8
                  + TO_INTEGER(TTTrack.Z0Frac)/8 + TO_INTEGER(TTTrack.Z0Frac)/64
                  + ZConstant );
      END IF;
    ELSE  --positive
      IF TTTrack.Z0Int >= ZMax THEN
        tmp_z := Zsaturate( 1 );  -- Saturate at out of range Z 
      ELSE
        tmp_z := (  TO_INTEGER(TTTrack.Z0Int)*ZIntScale( 0 )   + TO_INTEGER(TTTrack.Z0Int)/ZIntScale( 1 )
                  + TO_INTEGER(TTTrack.Z0Frac)/ZFracScale( 0 ) + TO_INTEGER(TTTrack.Z0Frac)/ZFracScale( 1 )
                  + ZConstant );
      END IF;
    END IF;

    z0 <= tmp_z;

  END PROCEDURE RescaleZ0;
-- -------------------------------------------------------------------------
  PROCEDURE GlobalPhi (SIGNAL TTTrack : IN InTTTrack.DataType.tData;  --Procedure for chaning sector phi to global phi using LUT
                       SIGNAL Sector  : IN INTEGER;
                       SIGNAL Phi     : OUT INTEGER) IS
  VARIABLE TempPhi : INTEGER := 0;
  BEGIN
    TempPhi   := TO_INTEGER(TTTrack.phi) + Phi_shift(Sector) - PhiShift;  --CONSTANTS TODO place in constants file
    IF TempPhi < PhiMin THEN
      TempPhi := TempPhi + PhiMax;
    ELSIF TempPhi > PhiMax THEN
      TempPhi := TempPhi - PhiMax; 
    ELSE
      TempPhi := TempPhi;
    END IF;

  Phi <= TempPhi;

  END PROCEDURE GlobalPhi;
-- -------------------------------------------------------------------------
  PROCEDURE TanLookup (SIGNAL TTTrack : IN InTTTrack.DataType.tData;  --Procedure for chaning TanL to eta based on a LUT
                       SIGNAL eta : OUT INTEGER) IS
    VARIABLE tanL_lut_0 : INTEGER := 0;
    VARIABLE tanL_lut_1 : INTEGER := 0;
    BEGIN
        tanL_lut_0   := TO_INTEGER( TTTrack.tanlfrac );
        tanL_lut_1  := abs( TO_INTEGER( TTTrack.tanlint ) );
        eta  <= TanLLUT( tanL_lut_0 )( tanL_lut_1 );

  END PROCEDURE TanLookup;
-- -------------------------------------------------------------------------
  -- Constants for delaying signals
  CONSTANT track_delay         : INTEGER := 6;
  CONSTANT vld_delay           : INTEGER := 5;  --CONSTANTS TODO place in constants file?

BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE
  
    --Output of InvR divider
    SIGNAL IntOut           : UNSIGNED( 19 DOWNTO 0 )              := ( OTHERS => '0' );
    SIGNAL FracOut          : UNSIGNED( 17 DOWNTO 0 )              := ( OTHERS => '0' );

    SIGNAL Sector           : INTEGER                              := 0;

    --Arrays and signals used for  delaying signals

    SIGNAL framesignal      : STD_LOGIC                            := '0';
    SIGNAL frame_array      : STD_LOGIC_VECTOR(0 to vld_delay - 1) := ( OTHERS => '0' );

    SIGNAL validsignal      : STD_LOGIC                            := '0';
    SIGNAL valid_array      : STD_LOGIC_VECTOR(0 to vld_delay - 1) := ( OTHERS => '0' );

    SIGNAL rescaledZ0       : INTEGER                              := 0;
    SIGNAL z0_array         : INTEGER_VECTOR(0 to track_delay - 1) := ( OTHERS => 0 );

    SIGNAL rescaledPhi      : INTEGER                              := 0;
    SIGNAL phi_array        : INTEGER_VECTOR(0 to track_delay - 1) :=  (OTHERS => 0 );

    SIGNAL eta              : INTEGER                              := 0;
    SIGNAL eta_array        : INTEGER_VECTOR(0 to track_delay - 1) := ( OTHERS => 0 );

    SIGNAL Chi2rphi_array   : INTEGER_VECTOR(0 to track_delay - 1) := ( OTHERS => 0 );
    SIGNAL Chi2rz_array     : INTEGER_VECTOR(0 to track_delay - 1) := ( OTHERS => 0 );
    SIGNAL BendChi2_array   : INTEGER_VECTOR(0 to track_delay - 1) := ( OTHERS => 0 );
    SIGNAL Hitpattern_array : INTEGER_VECTOR(0 to track_delay - 1) := ( OTHERS => 0 );


  BEGIN

    Divider : ENTITY LinkDecode.InvRdivider
    PORT MAP(
      clk => clk, -- clock
      NumeratorIn   => TO_UNSIGNED(InvRtoPtNormalisation,IntOut'length), 
      DenominatorIn => TO_UNSIGNED( abs(TO_INTEGER( TTTrackPipeIn( 0 )( i ).InvR )),FracOut'length ), --Convert input to correct format
      IntegerOut    => IntOut,
      FractionOut   => FracOut
    );

    Sector <= i;
    RescaleZ0(TTTrackPipeIn( 0 )( i ),rescaledZ0);
    GlobalPhi(TTTrackPipeIn( 0 )( i ),Sector,rescaledPhi);
    TanLookup(TTTrackPipeIn( 0 )( i ),eta);

    PROCESS( clk )
    BEGIN
      IF RISING_EDGE( clk ) THEN

        --Delay Signals by filling arrays

        framesignal <= '1' WHEN TTTrackPipeIn( 0 )( i ).FrameValid ELSE '0';
        validsignal <= '1' WHEN TTTrackPipeIn( 0 )( i ).DataValid  ELSE '0';
      
        frame_array <= framesignal & frame_array( 0 to vld_delay - 2 );
        valid_array <= validsignal & valid_array( 0 to vld_delay - 2 );

        z0_array    <= rescaledZ0  & z0_array ( 0 to track_delay - 2 );
        phi_array   <= rescaledPhi & phi_array( 0 to track_delay - 2 );
        eta_array   <= eta         & eta_array( 0 to track_delay - 2 );

        Chi2rphi_array   <= TO_INTEGER( TTTrackPipeIn( 0 )( i ).Chi2rphi   ) & Chi2rphi_array  ( 0 to track_delay - 2 );
        Chi2rz_array     <= TO_INTEGER( TTTrackPipeIn( 0 )( i ).Chi2rz     ) & Chi2rz_array    ( 0 to track_delay - 2 );
        BendChi2_array   <= TO_INTEGER( TTTrackPipeIn( 0 )( i ).BendChi2   ) & BendChi2_array  ( 0 to track_delay - 2 );
        Hitpattern_array <= TO_INTEGER( TTTrackPipeIn( 0 )( i ).Hitpattern ) & Hitpattern_array( 0 to track_delay - 2 );
      END IF;
    END PROCESS;
    -- Fill new track word
    Output( i ).Pt         <= TO_UNSIGNED( TO_INTEGER( IntOut )+TO_INTEGER( FracOut )/2**18 ,Output( i ).Pt'length );
    Output( i ).Phi        <= TO_UNSIGNED( phi_array       ( track_delay - 1 ) ,Output( i ).Phi'length );
    Output( i ).Eta        <= TO_UNSIGNED( eta_array       ( track_delay - 1 ) ,Output( i ).Eta'length );
    Output( i ).Z0         <= TO_UNSIGNED( z0_array        ( track_delay - 1 ) ,Output( i ).Z0'length  );
    Output( i ).Chi2rphi   <= TO_UNSIGNED( Chi2rphi_array  ( track_delay - 1 ) ,Output( i ).Chi2rphi'length  );
    Output( i ).Chi2rz     <= TO_UNSIGNED( Chi2rz_array    ( track_delay - 1 ) ,Output( i ).Chi2rz'length  );
    Output( i ).BendChi2   <= TO_UNSIGNED( BendChi2_array  ( track_delay - 1 ) ,Output( i ).BendChi2'length  );
    Output( i ).Hitpattern <= TO_UNSIGNED( Hitpattern_array( track_delay - 1 ) ,Output( i ).Hitpattern'length  );
    Output( i ).DataValid  <= TRUE WHEN ( valid_array( vld_delay - 1 ) = '1' ) ELSE FALSE;
    Output( i ).FrameValid <= TRUE WHEN ( frame_array( vld_delay - 1 ) = '1' ) ELSE FALSE;
        
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
