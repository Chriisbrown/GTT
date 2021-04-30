LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;
USE GTT.GTTDataFormats.ALL;

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
ENTITY ByPassTrackTransform IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk              : IN STD_LOGIC; -- The algorithm clock
    TTTrackPipeIn    : IN InTTTrack.ArrayTypes.VectorPipe; --In Tracks of type LinkIn tracks
    TTTrackPipeOut   : OUT TTTrack.ArrayTypes.VectorPipe  --Out Tracks of type transformed tracks
  );
END ByPassTrackTransform;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF ByPassTrackTransform IS
  SIGNAL Output : TTTrack.ArrayTypes.Vector( 0 TO NumInputLinks - 1 ) := TTTrack.ArrayTypes.NullVector( NumInputLinks );
-- -------------------------------------------------------------------------
  FUNCTION GlobalPhi (InPhi     : UNSIGNED( widthPhi0 - 1 DOWNTO 0 );  --Procedure for changing sector phi to global phi using LUT
                      Sector    : INTEGER ) 
                      RETURN UNSIGNED IS 
  VARIABLE TempPhi : INTEGER := 0;
  BEGIN
    IF InPhi(widthPhi0-1) = '1' THEN
      TempPhi   := TO_INTEGER(SHIFT_RIGHT(InPhi,TrackPhiScale)) + Phi_shift(Sector) - PhiShift; 
    ELSE
      TempPhi   := TO_INTEGER(SHIFT_RIGHT(InPhi,TrackPhiScale)) + Phi_shift(Sector); 
    END IF; 
    IF TempPhi < PhiMin THEN
      TempPhi := TempPhi + PhiMax;
    ELSIF TempPhi > PhiMax THEN
      TempPhi := TempPhi - PhiMax; 
    ELSE
      TempPhi := TempPhi;
    END IF;

  RETURN TO_UNSIGNED(TempPhi, GlobalPhiWidth); 
  END FUNCTION GlobalPhi;

  FUNCTION AbsoluteEta (InEta   : UNSIGNED( widthTanL - 1 DOWNTO 0 ); 
                        Link    : INTEGER ) 
                        RETURN UNSIGNED IS 
  VARIABLE TempEta : INTEGER := 0;
  BEGIN
    IF Link >= 9 THEN
      TempEta := TO_INTEGER(SHIFT_RIGHT(InEta,TrackEtaScale));
    ELSE
      TempEta :=  (2**EtaWidth - 1) - TO_INTEGER(SHIFT_RIGHT(InEta,TrackEtaScale)) ;
    END IF;

  RETURN TO_UNSIGNED(TempEta, EtaWidth); 
  END FUNCTION AbsoluteEta;
-- -------------------------------------------------------------------------

BEGIN
  g1              : FOR i IN 0 TO NumInputLinks - 1 GENERATE

  BEGIN
    
    PROCESS( clk )
    BEGIN
      IF RISING_EDGE( clk ) THEN
        Output( i ).Pt         <=  TO_UNSIGNED(abs(TO_INTEGER(TTTrackPipeIn( 0 )( i ).InvR( widthInvR - 2 DOWNTO 0))),PtWidth); --Ignore Sign Bit, only care about magnitude
        Output( i ).Phi        <=  GlobalPhi(TTTrackPipeIn( 0 )( i ).Phi0,i);
        Output( i ).Eta        <=  AbsoluteEta(TTTrackPipeIn( 0 )( i ).TanL,i);
        Output( i ).Z0         <=  TO_UNSIGNED(TO_INTEGER(SHIFT_RIGHT(TTTrackPipeIn( 0 )( i ).Z0,TrackZ0Scale)),VertexZ0Width);
        Output( i ).Chi2rphi   <=  TTTrackPipeIn( 0 )( i ).Chi2rphi;
        Output( i ).Chi2rz     <=  TTTrackPipeIn( 0 )( i ).Chi2rz;
        Output( i ).BendChi2   <=  TTTrackPipeIn( 0 )( i ).BendChi2;
        Output( i ).Hitpattern <=  TTTrackPipeIn( 0 )( i ).HitPattern;
        Output( i ).DataValid  <=  TTTrackPipeIn( 0 )( i ).DataValid;
        Output( i ).FrameValid <=  TTTrackPipeIn( 0 )( i ).FrameValid;

      END IF;
    END PROCESS;
    -- Fill new track word
    
        
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
  GENERIC MAP( "TransformBypass" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;
