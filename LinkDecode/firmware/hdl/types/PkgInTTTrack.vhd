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

-- .library Track
-- .include ReuseableElements/PkgUtilities.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

LIBRARY GTT;
USE GTT.GTTDataFormats.ALL;

LIBRARY Utilities;
USE Utilities.Utilities.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS
-- -------------------------------------------------------------------------

--  Track Word 
  TYPE tData IS RECORD

  TrackValid : UNSIGNED( 0 DOWNTO 0);
  extraMVA   : UNSIGNED( widthExtraMVA   - 1 downto 0 );
  TQMVA      : UNSIGNED( widthTQMVA      - 1 downto 0 );
  HitPattern : UNSIGNED( widthHitPattern - 1 downto 0 );
  BendChi2   : UNSIGNED( widthBendChi2   - 1 downto 0 );
  Chi2RPhi   : UNSIGNED( widthChi2RPhi   - 1 downto 0 );
  Chi2RZ     : UNSIGNED( widthChi2RZ     - 1 downto 0 );
  D0         : UNSIGNED( widthD0         - 1 downto 0 );
  Z0         : UNSIGNED( widthZ0         - 1 downto 0 );
  TanL       : UNSIGNED( widthTanL       - 1 downto 0 );
  Phi0       : UNSIGNED( widthPhi0       - 1 downto 0 );
  InvR       : UNSIGNED( widthInvR       - 1 downto 0 );

  DataValid  : BOOLEAN;
  FrameValid : BOOLEAN;

end record;

ATTRIBUTE SIZE : NATURAL;
ATTRIBUTE SIZE of tData : TYPE IS widthTTTrack;

-- -------------------------------------------------------------------------       

-- A record to encode the bit location of each field of the tData record
-- when packaged into a std_logic_vector
  TYPE tFieldLocations IS RECORD
    extraMVAl   : INTEGER;
    extraMVAh   : INTEGER;
    TQMVAl      : INTEGER;
    TQMVAh      : INTEGER;
    HitPatternl : INTEGER;
    HitPatternh : INTEGER;
    BendChi2l   : INTEGER;
    BendChi2h   : INTEGER;
    D0l         : INTEGER;
    D0h         : INTEGER;
    
    Chi2RZl     : INTEGER;
    Chi2RZh     : INTEGER;
    Z0l         : INTEGER;
    Z0h         : INTEGER;
    TanLl       : INTEGER;
    TanLh       : INTEGER;
    
    Chi2RPhil   : INTEGER;
    Chi2RPhih   : INTEGER;
    Phi0l       : INTEGER;
    Phi0h       : INTEGER;
    InvRl       : INTEGER;
    InvRh       : INTEGER;
    
    TrackValidi : INTEGER;
-- -----------------------------------------


    
    
  END RECORD;

  --CONSTANT bitloc                      : tFieldLocations := ( 0  , 14 ,   --InvR
  --                                                            15 , 26 ,   --Phi
  --                                                            27 , 30 ,   --TanlInt
  --                                                            31 , 42 ,   --Tanlfrac
  --                                                            43 , 47 ,   --Z0Int
  --                                                            48 , 54 ,   --Z0Frac
  --                                                            55 , 57 ,   --MVAQ
  --                                                            58 , 63 ,   --MVAres
  --                                                            0  , 5  ,   --D0Int
  --                                                            6  , 12 ,   --D0Frac
  --                                                            13 , 16 ,   --Chirphi
  --                                                            17 , 20 ,   --Chirz
  --                                                            21 , 23 ,   --BendChi
  --                                                            24 , 30 ,   --HitPattern
  --                                                            31         --TrackValid
  --                                                            );

  CONSTANT bitloc                      : tFieldLocations := (                     0  ,                                                           widthExtraMVA - 1 ,   --extra_MVA
                                                                       widthExtraMVA ,                                              widthTQMVA + widthExtraMVA - 1 ,   --TQ_MVA
                                                          widthTQMVA + widthExtraMVA ,                           widthHitPattern +  widthTQMVA + widthExtraMVA - 1 ,   --HitPattern
                                       widthHitPattern +  widthTQMVA + widthExtraMVA ,           widthBendChi2 + widthHitPattern +  widthTQMVA + widthExtraMVA - 1 ,   --BendChi2
                       widthBendChi2 + widthHitPattern +  widthTQMVA + widthExtraMVA , widthD0 + widthBendChi2 + widthHitPattern +  widthTQMVA + widthExtraMVA - 1 ,   --D0
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                 widthpartialTTTrack ,                       widthChi2RZ -1 + widthpartialTTTrack , --Chi2RZ
                                                   widthChi2RZ + widthpartialTTTrack ,             widthZ0 + widthChi2RZ -1 + widthpartialTTTrack , --Z0
                                         widthZ0 + widthChi2RZ + widthpartialTTTrack , widthTanL + widthZ0 + widthChi2RZ -1 + widthpartialTTTrack , --TanL
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
                                                               widthpartialTTTrack*2 ,                         widthChi2RPhi -1 + 2*widthpartialTTTrack ,   --Chi2RPhi
                                               widthChi2RPhi + 2*widthpartialTTTrack ,             widthPhi0 + widthChi2RPhi -1 + 2*widthpartialTTTrack ,   --Phi0
                                   widthPhi0 + widthChi2RPhi + 2*widthpartialTTTrack , widthInvR + widthPhi0 + widthChi2RPhi -1 + 2*widthpartialTTTrack ,   --InvR
                       widthInvR + widthPhi0 + widthChi2RPhi + 2*widthpartialTTTrack    --valid
);
  -- split across 2 different links!
  CONSTANT cNull                       : tData           := ( ( OTHERS => '0' ) ,  -- Valid
                                                              ( OTHERS => '0' ) ,  --ExtraMVA
                                                              ( OTHERS => '0' ) ,  --TQMVA
                                                              ( OTHERS => '0' ) ,  --HitPattern
                                                              ( OTHERS => '0' ) ,  --BendChi2
                                                              ( OTHERS => '0' ) ,  --D0

                                                              ( OTHERS => '0' ) ,  --Chi2RZ
                                                              ( OTHERS => '0' ) ,  --Z0
                                                              ( OTHERS => '0' ) ,  --TanL

                                                              ( OTHERS => '0' ) ,  --Chi2rphi
                                                              ( OTHERS => '0' ) ,  --Phi
                                                              ( OTHERS => '0' ) ,  --InvR

                                                               false ,             --DataValid
                                                               false               --FrameValid
                                                               );  
  FUNCTION ToStdLogicVector( aData     : tData ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;

  FUNCTION WriteHeader RETURN STRING;
  FUNCTION WriteData( aData : tData ) RETURN STRING;

-- -------------------------------------------------------------------------       

END DataType;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE BODY DataType IS

  FUNCTION ToStdLogicVector( aData : tData ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lRet                  : STD_LOGIC_VECTOR( widthTTTrack - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN

    lRet( bitloc.InvRh       DOWNTO bitloc.InvRl       )        := STD_LOGIC_VECTOR( aData.InvR       );
    lRet( bitloc.Phi0h       DOWNTO bitloc.Phi0l       )        := STD_LOGIC_VECTOR( aData.Phi0       );
    lRet( bitloc.TanLh       DOWNTO bitloc.TanLl       )        := STD_LOGIC_VECTOR( aData.TanL       );
    lRet( bitloc.Z0h         DOWNTO bitloc.Z0l         )        := STD_LOGIC_VECTOR( aData.Z0         );
    lRet( bitloc.TQMVAh      DOWNTO bitloc.TQMVAl      )        := STD_LOGIC_VECTOR( aData.TQMVA      );
    lRet( bitloc.extraMVAh   DOWNTO bitloc.extraMVAl   )        := STD_LOGIC_VECTOR( aData.extraMVA   );

    lRet( bitloc.D0h         DOWNTO bitloc.D0l         )         := STD_LOGIC_VECTOR( aData.D0         );
    lRet( bitloc.Chi2rphih   DOWNTO bitloc.Chi2rphil   )         := STD_LOGIC_VECTOR( aData.Chi2rphi   );
    lRet( bitloc.Chi2rzh     DOWNTO bitloc.Chi2rzl     )         := STD_LOGIC_VECTOR( aData.Chi2rz     );
    lRet( bitloc.BendChi2h   DOWNTO bitloc.BendChi2l   )         := STD_LOGIC_VECTOR( aData.BendChi2   );
    lRet( bitloc.Hitpatternh DOWNTO bitloc.Hitpatternl )         := STD_LOGIC_VECTOR( aData.Hitpattern );
    lRet( bitloc.TrackValidi DOWNTO bitloc.TrackValidi )         := STD_LOGIC_VECTOR( aData.TrackValid );


   

    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN

    lRet.InvR       := UNSIGNED ( aStdLogicVector( bitloc.InvRh       DOWNTO bitloc.InvRl       ) );        
    lRet.Phi0       := UNSIGNED ( aStdLogicVector( bitloc.Phi0h        DOWNTO bitloc.Phi0l        ) );        
    lRet.TanL       := UNSIGNED ( aStdLogicVector( bitloc.TanLh       DOWNTO bitloc.TanLl       ) );      
    lRet.Z0         := UNSIGNED ( aStdLogicVector( bitloc.Z0h         DOWNTO bitloc.Z0l         ) );

    lRet.D0         := UNSIGNED ( aStdLogicVector( bitloc.D0h         DOWNTO bitloc.D0l         ) );      
    lRet.Chi2rphi   := UNSIGNED ( aStdLogicVector( bitloc.Chi2rphih   DOWNTO bitloc.Chi2rphil   ) );        
    lRet.Chi2rz     := UNSIGNED ( aStdLogicVector( bitloc.Chi2rzh     DOWNTO bitloc.Chi2rzl     ) );        
    lRet.BendChi2   := UNSIGNED ( aStdLogicVector( bitloc.BendChi2h   DOWNTO bitloc.BendChi2l   ) );        
    lRet.Hitpattern := UNSIGNED ( aStdLogicVector( bitloc.Hitpatternh DOWNTO bitloc.Hitpatternl ) );        
    lRet.TQMVA      := UNSIGNED ( aStdLogicVector( bitloc.TQMVAh  DOWNTO bitloc.TQMVAl  ) );        
    lRet.extraMVA   := UNSIGNED ( aStdLogicVector( bitloc.extraMVAh   DOWNTO bitloc.extraMVAl   ) ); 
    lRet.TrackValid := UNSIGNED ( aStdLogicVector( bitloc.TrackValidi DOWNTO bitloc.TrackValidi ) ); 
    

    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "InvR" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Phi" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "TanL" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Z0" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "D0" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Chi2rphi" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Chi2rz" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "BendChi2 " ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Hitpattern" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "MVAtrackQ" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "OtherMVA" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "TrackValid" ) , RIGHT , 15 );
    
    WRITE( aLine , STRING' ( "FrameValid" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "DataValid" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , TO_INTEGER( aData.InvR ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Phi0 ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.TanL ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Z0) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.D0 ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Chi2rphi ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Chi2rz ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.BendChi2 ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Hitpattern ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.TQMVA  ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.extraMVA ) , RIGHT , 15 );
    WRITE( aLine ,  TO_INTEGER( aData.TrackValid)  , RIGHT , 15 );

    WRITE( aLine , aData.FrameValid , RIGHT , 15 );
    WRITE( aLine , aData.DataValid , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;



END DataType;
