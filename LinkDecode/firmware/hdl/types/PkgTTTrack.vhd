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

LIBRARY GTT;
USE GTT.GTTDataFormats.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS
-- -------------------------------------------------------------------------

--  Track Word 
  TYPE tData IS RECORD
  Pt           : UNSIGNED( PtWidth - 1         DOWNTO 0 ); 
  Z0           : UNSIGNED( VertexZ0Width - 1   DOWNTO 0 );
-- -------------------------------------------------------------------------
  Chi2rphi     : UNSIGNED( widthChi2RPhi - 1   DOWNTO 0 );
  Chi2rz       : UNSIGNED( widthChi2RZ - 1     DOWNTO 0 );
  BendChi2     : UNSIGNED( widthBendChi2 - 1   DOWNTO 0 );
  Hitpattern   : UNSIGNED( widthHitPattern - 1 DOWNTO 0 );
  -- --------------------------------------------------------------------------------------------
  PV           : UNSIGNED( VertexZ0Width - 1   DOWNTO 0 );

  Phi          : UNSIGNED( GlobalPhiWidth - 1  DOWNTO 0 );  
  Eta          : UNSIGNED( EtaWidth - 1        DOWNTO 0 ); 
-- --------------------------------------------
  DataValid    : BOOLEAN;
  FrameValid   : BOOLEAN;
END RECORD;

ATTRIBUTE SIZE : NATURAL;
ATTRIBUTE SIZE of tData : TYPE IS PtWidth +VertexZ0Width + widthChi2RPhi
                                + widthChi2RZ + widthBendChi2 + widthHitPattern 
                                + VertexZ0Width + GlobalPhiWidth + EtaWidth + 1 + 1; -- 
-- -------------------------------------------------------------------------       

-- A record to encode the bit location of each field of the tData record
-- when packaged into a std_logic_vector
  TYPE tFieldLocations IS RECORD
    Ptl         : INTEGER;
    Pth         : INTEGER;
    Z0l         : INTEGER;
    Z0h         : INTEGER;
-- ----------------------------------------
    Chi2rphil     : INTEGER;
    Chi2rphih     : INTEGER;
    Chi2rzl       : INTEGER;
    Chi2rzh       : INTEGER;
    BendChi2l     : INTEGER;
    BendChi2h     : INTEGER;
    Hitpatternl   : INTEGER;
    Hitpatternh   : INTEGER;

    PVl           : INTEGER;
    PVh           : INTEGER;

    Phil        : INTEGER;
    Phih        : INTEGER;
    Etal        : INTEGER;
    Etah        : INTEGER;

    Dvld          : INTEGER;
    Fvld          : INTEGER;
-- -----------------------------------------
    
  END RECORD;

  CONSTANT bitloc                      : tFieldLocations := ( 0  ,                                                               PtWidth - 1 ,   --pT
                                                         PtWidth ,                                               VertexZ0Width + PtWidth - 1 ,   --Z0
                                       VertexZ0Width +   PtWidth ,                               widthChi2RPhi + VertexZ0Width + PtWidth - 1 ,   --Chi2Rphi
                       widthChi2RPhi + VertexZ0Width +   PtWidth ,                 widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth - 1 ,   --Chi2RZ
         widthChi2RZ + widthChi2RPhi + VertexZ0Width +   PtWidth , widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth - 1 ,   --BendChi2

                  widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth , 
widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth - 1 ,   --HitPattern

                widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth , 
VertexZ0Width + widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth - 1 ,   --PV

                 VertexZ0Width + widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth ,  
GlobalPhiWidth + VertexZ0Width + widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth - 1 ,   --Phi

           GlobalPhiWidth + VertexZ0Width + widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth ,  
EtaWidth + GlobalPhiWidth + VertexZ0Width + widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth - 1 ,   --Eta

EtaWidth + GlobalPhiWidth + VertexZ0Width + widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth  ,  --Data Valid
EtaWidth + GlobalPhiWidth + VertexZ0Width + widthHitPattern + widthBendChi2 + widthChi2RZ + widthChi2RPhi + VertexZ0Width + PtWidth + 1 --Frame Valid
 
                                                              );

  CONSTANT cNull                       : tData           := ( ( OTHERS => '0' ) ,  --pT
                                                              ( OTHERS => '0' ) ,  --Z0
                                                              ( OTHERS => '0' ) ,  --Chirphi
                                                              ( OTHERS => '0' ) ,  --Chirz
                                                              ( OTHERS => '0' ) ,  --BendChi
                                                              ( OTHERS => '0' ) ,  --HitPattern
                                                              ( OTHERS => '0' ) ,  --PV
                                                              ( OTHERS => '0' ) ,  --Phi
                                                              ( OTHERS => '0' ) ,  --Eta
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
    VARIABLE lRet                  : STD_LOGIC_VECTOR( tData'SIZE - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN

    lRet( bitloc.Pth         DOWNTO bitloc.Ptl         )         := STD_LOGIC_VECTOR( aData.Pt         );
    lRet( bitloc.Z0h         DOWNTO bitloc.Z0l         )         := STD_LOGIC_VECTOR( aData.Z0         );
    lRet( bitloc.Chi2rphih   DOWNTO bitloc.Chi2rphil   )         := STD_LOGIC_VECTOR( aData.Chi2rphi   );
    lRet( bitloc.Chi2rzh     DOWNTO bitloc.Chi2rzl     )         := STD_LOGIC_VECTOR( aData.Chi2rz     );
    lRet( bitloc.BendChi2h   DOWNTO bitloc.BendChi2l   )         := STD_LOGIC_VECTOR( aData.BendChi2   );
    lRet( bitloc.Hitpatternh DOWNTO bitloc.Hitpatternl )         := STD_LOGIC_VECTOR( aData.Hitpattern );
    lRet( bitloc.PVh         DOWNTO bitloc.PVl         )         := STD_LOGIC_VECTOR( aData.PV         );  
    lRet( bitloc.Phih        DOWNTO bitloc.Phil        )         := STD_LOGIC_VECTOR( aData.Phi        );
    lRet( bitloc.etah        DOWNTO bitloc.etal        )         := STD_LOGIC_VECTOR( aData.eta        );

    lRet( bitloc.Dvld         )         := '1' WHEN aData.DataValid    ELSE '0'; 
    lRet( bitloc.Fvld         )         := '1' WHEN aData.FrameValid   ELSE '0'; 

    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN

    lRet.Pt         := UNSIGNED ( aStdLogicVector( bitloc.Pth         DOWNTO bitloc.Ptl  ) );           
    lRet.Z0         := UNSIGNED ( aStdLogicVector( bitloc.Z0h         DOWNTO bitloc.Z0l  ) );
    lRet.Chi2rphi   := UNSIGNED ( aStdLogicVector( bitloc.Chi2rphih   DOWNTO bitloc.Chi2rphil   ) );        
    lRet.Chi2rz     := UNSIGNED ( aStdLogicVector( bitloc.Chi2rzh     DOWNTO bitloc.Chi2rzl     ) );        
    lRet.BendChi2   := UNSIGNED ( aStdLogicVector( bitloc.BendChi2h   DOWNTO bitloc.BendChi2l   ) );        
    lRet.Hitpattern := UNSIGNED ( aStdLogicVector( bitloc.Hitpatternh DOWNTO bitloc.Hitpatternl ) );        
    lRet.PV         := UNSIGNED ( aStdLogicVector( bitloc.PVh         DOWNTO bitloc.PVl         ) );  
    
    lRet.Phi        := UNSIGNED ( aStdLogicVector( bitloc.Phih  DOWNTO bitloc.Phil ) );        
    lRet.eta        := UNSIGNED ( aStdLogicVector( bitloc.etah  DOWNTO bitloc.etal ) );    
 
    lRet.DataValid         := TRUE WHEN ( aStdLogicVector( bitloc.Dvld ) ) ELSE FALSE;
    lRet.FrameValid        := TRUE WHEN ( aStdLogicVector( bitloc.Fvld ) ) ELSE FALSE; 
      

    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "pt" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Phi" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Eta" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Z0" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Chi2rphi" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Chi2rz" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "BendChi2 " ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Hitpattern" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "PrimaryVertex" ) , RIGHT , 15 );

    WRITE( aLine , STRING' ( "FrameValid" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "DataValid" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , TO_INTEGER( aData.Pt ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Phi ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.eta ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Z0 ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Chi2rphi ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Chi2rz ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.BendChi2 ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Hitpattern ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.PV ) , RIGHT , 15 );


    WRITE( aLine , aData.FrameValid , RIGHT , 15 );
    WRITE( aLine , aData.DataValid , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;



END DataType;