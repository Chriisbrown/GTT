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

LIBRARY Utilities;
USE Utilities.Utilities.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS
-- -------------------------------------------------------------------------

--  Track Word 
  TYPE tData IS RECORD
  InvR         :   SIGNED( 14 DOWNTO 0 );
  Phi          :   SIGNED( 11 DOWNTO 0 );
  TanLInt      :   SIGNED( 3  DOWNTO 0 );
  TanLFrac     : UNSIGNED( 11 DOWNTO 0 );
  Z0Int        : UNSIGNED( 4  DOWNTO 0 );
  Z0Frac       :   SIGNED( 6  DOWNTO 0 );
  MVAtrackQ    : UNSIGNED( 2  DOWNTO 0 );
  OtherMVA     : UNSIGNED( 5  DOWNTO 0 );
-- --------------------------------------------
  D0Int        :   SIGNED( 5 DOWNTO 0 );
  D0Frac       : UNSIGNED( 6 DOWNTO 0 );
  Chi2rphi     : UNSIGNED( 3 DOWNTO 0 );
  Chi2rz       : UNSIGNED( 3 DOWNTO 0 );
  BendChi2     : UNSIGNED( 2 DOWNTO 0 );
  Hitpattern   : UNSIGNED( 6 DOWNTO 0 );
  TrackValid   : UNSIGNED( 0 DOWNTO 0 );
-- --------------------------------------------
  DataValid    : BOOLEAN;
  FrameValid   : BOOLEAN;
END RECORD;

ATTRIBUTE SIZE : NATURAL;
ATTRIBUTE SIZE of tData : TYPE IS 96; -- Actual is 104, roundup to 108 for 3*36 for BRAM boundary

-- -------------------------------------------------------------------------       

-- A record to encode the bit location of each field of the tData record
-- when packaged into a std_logic_vector
  TYPE tFieldLocations IS RECORD
    InvRl         : INTEGER;
    InvRh         : INTEGER;
    Phil          : INTEGER;
    Phih          : INTEGER;
    TanLintl      : INTEGER;
    TanLinth      : INTEGER;
    TanLfracl     : INTEGER;
    TanLfrach     : INTEGER;
    Z0intl        : INTEGER;
    Z0inth        : INTEGER;
    Z0fracl       : INTEGER;
    Z0frach       : INTEGER;
    MVAtrackQl    : INTEGER;
    MVAtrackQh    : INTEGER;
    OtherMVAl     : INTEGER;
    OtherMVAh     : INTEGER;
-- ----------------------------------------
    D0intl        : INTEGER;
    D0inth        : INTEGER;
    D0fracl       : INTEGER;
    D0frach       : INTEGER;
    Chi2rphil     : INTEGER;
    Chi2rphih     : INTEGER;
    Chi2rzl       : INTEGER;
    Chi2rzh       : INTEGER;
    BendChi2l     : INTEGER;
    BendChi2h     : INTEGER;
    Hitpatternl   : INTEGER;
    Hitpatternh   : INTEGER;
    TrackValidi   : INTEGER;
-- -----------------------------------------


    
    
  END RECORD;

  CONSTANT bitloc                      : tFieldLocations := ( 0  , 14 ,   --InvR
                                                              15 , 26 ,   --Phi
                                                              27 , 30 ,   --TanlInt
                                                              31 , 42 ,   --Tanlfrac
                                                              43 , 47 ,   --Z0Int
                                                              48 , 54 ,   --Z0Frac
                                                              55 , 57 ,   --MVAQ
                                                              58 , 63 ,   --MVAres
                                                              0  , 5  ,   --D0Int
                                                              6  , 12 ,   --D0Frac
                                                              13 , 16 ,   --Chirphi
                                                              17 , 20 ,   --Chirz
                                                              21 , 23 ,   --BendChi
                                                              24 , 30 ,   --HitPattern
                                                              31         --TrackValid
                                                              );
  -- split across 2 different links!
  CONSTANT cNull                       : tData           := ( ( OTHERS => '0' ) ,  --InvR
                                                              ( OTHERS => '0' ) ,  --Phi
                                                              ( OTHERS => '0' ) ,  --TanlInt
                                                              ( OTHERS => '0' ) ,  --TanlFrac
                                                              ( OTHERS => '0' ) ,  --Z0Int
                                                              ( OTHERS => '0' ) ,  --Z0Frac
                                                              ( OTHERS => '0' ) ,  --MVAQ
                                                              ( OTHERS => '0' ) ,  --MVAres
                                                              ( OTHERS => '0' ) ,  --D0Int
                                                              ( OTHERS => '0' ) ,  --D0Frac
                                                              ( OTHERS => '0' ) ,  --Chirphi
                                                              ( OTHERS => '0' ) ,  --Chirz
                                                              ( OTHERS => '0' ) ,  --BendChi
                                                              ( OTHERS => '0' ) ,  --HitPattern
                                                              ( OTHERS => '0' ) ,  --TrackValid
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
    VARIABLE lRet                  : STD_LOGIC_VECTOR( 135 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN

    lRet( bitloc.InvRh       DOWNTO bitloc.InvRl       )        := STD_LOGIC_VECTOR( aData.InvR       );
    lRet( bitloc.Phih        DOWNTO bitloc.Phil        )        := STD_LOGIC_VECTOR( aData.Phi        );
    lRet( bitloc.TanLinth    DOWNTO bitloc.TanLintl    )        := STD_LOGIC_VECTOR( aData.TanLInt    );
    lRet( bitloc.TanLfrach   DOWNTO bitloc.TanLfracl   )        := STD_LOGIC_VECTOR( aData.TanLFrac   );
    lRet( bitloc.Z0inth      DOWNTO bitloc.Z0intl      )        := STD_LOGIC_VECTOR( aData.Z0Int      );
    lRet( bitloc.Z0frach     DOWNTO bitloc.Z0fracl     )        := STD_LOGIC_VECTOR( aData.Z0Frac     );
    lRet( bitloc.MVAtrackQh  DOWNTO bitloc.MVAtrackQl  )        := STD_LOGIC_VECTOR( aData.MVAtrackQ  );
    lRet( bitloc.OtherMVAh   DOWNTO bitloc.OtherMVAl   )        := STD_LOGIC_VECTOR( aData.OtherMVA   );

    lRet( 64 + bitloc.D0inth      DOWNTO 64 + bitloc.D0intl     )          := STD_LOGIC_VECTOR( aData.D0Int      );
    lRet( 64 + bitloc.D0frach     DOWNTO 64 + bitloc.D0fracl      )        := STD_LOGIC_VECTOR( aData.D0Frac     );
    lRet( 64 + bitloc.Chi2rphih   DOWNTO 64 + bitloc.Chi2rphil   )         := STD_LOGIC_VECTOR( aData.Chi2rphi   );
    lRet( 64 + bitloc.Chi2rzh     DOWNTO 64 + bitloc.Chi2rzl     )         := STD_LOGIC_VECTOR( aData.Chi2rz     );
    lRet( 64 + bitloc.BendChi2h   DOWNTO 64 + bitloc.BendChi2l   )         := STD_LOGIC_VECTOR( aData.BendChi2   );
    lRet( 64 + bitloc.Hitpatternh DOWNTO 64 + bitloc.Hitpatternl )         := STD_LOGIC_VECTOR( aData.Hitpattern );
    lRet( 64 + bitloc.TrackValidi DOWNTO 64 + bitloc.TrackValidi )         := STD_LOGIC_VECTOR( aData.TrackValid );


   

    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN

    lRet.InvR       :=   SIGNED ( aStdLogicVector( bitloc.InvRh       DOWNTO bitloc.InvRl       ) );        
    lRet.Phi        :=   SIGNED ( aStdLogicVector( bitloc.Phih        DOWNTO bitloc.Phil        ) );        
    lRet.TanLInt    :=   SIGNED ( aStdLogicVector( bitloc.TanLinth    DOWNTO bitloc.TanLintl    ) );  
    lRet.TanLFrac   := UNSIGNED ( aStdLogicVector( bitloc.TanLfrach   DOWNTO bitloc.TanLfracl   ) );      
    lRet.Z0Int      := UNSIGNED ( aStdLogicVector( bitloc.Z0inth      DOWNTO bitloc.Z0intl      ) );
    lRet.Z0Frac     :=   SIGNED ( aStdLogicVector( bitloc.Z0frach     DOWNTO bitloc.Z0fracl     ) ); 

    lRet.D0Int      :=   SIGNED ( aStdLogicVector( 64 + bitloc.D0inth      DOWNTO 64 + bitloc.D0intl      ) );   
    lRet.D0Frac     := UNSIGNED ( aStdLogicVector( 64 + bitloc.D0frach     DOWNTO 64 + bitloc.D0fracl     ) );     
    lRet.Chi2rphi   := UNSIGNED ( aStdLogicVector( 64 + bitloc.Chi2rphih   DOWNTO 64 + bitloc.Chi2rphil   ) );        
    lRet.Chi2rz     := UNSIGNED ( aStdLogicVector( 64 + bitloc.Chi2rzh     DOWNTO 64 + bitloc.Chi2rzl     ) );        
    lRet.BendChi2   := UNSIGNED ( aStdLogicVector( 64 + bitloc.BendChi2h   DOWNTO 64 + bitloc.BendChi2l   ) );        
    lRet.Hitpattern := UNSIGNED ( aStdLogicVector( 64 + bitloc.Hitpatternh DOWNTO 64 + bitloc.Hitpatternl ) );        
    lRet.MVAtrackQ  := UNSIGNED ( aStdLogicVector( 64 + bitloc.MVAtrackQh  DOWNTO 64 + bitloc.MVAtrackQl  ) );        
    lRet.OtherMVA   := UNSIGNED ( aStdLogicVector( 64 + bitloc.OtherMVAh   DOWNTO 64 + bitloc.OtherMVAl   ) ); 
    lRet.TrackValid := UNSIGNED ( aStdLogicVector( 64 + bitloc.TrackValidi DOWNTO 64 + bitloc.TrackValidi ) ); 
    

    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "InvR" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Phi" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "TanLInt" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "TanLFrac" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Z0Int" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Z0Frac" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "D0Int" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "D0Frac" ) , RIGHT , 15 );
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
    WRITE( aLine , TO_INTEGER( aData.Phi ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.TanLInt ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.TanLFrac ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Z0Int ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Z0Frac ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.D0Int ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.D0Frac ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Chi2rphi ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Chi2rz ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.BendChi2 ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Hitpattern ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.MVAtrackQ ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.OtherMVA ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.TrackValid ) , RIGHT , 15 );

    WRITE( aLine , aData.FrameValid , RIGHT , 15 );
    WRITE( aLine , aData.DataValid , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;



END DataType;
