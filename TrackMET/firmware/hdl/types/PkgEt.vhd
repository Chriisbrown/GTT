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

-- .library Vertex
-- .include ReuseableElements/PkgUtilities.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;
USE GTT.GTTDataFormats.ALL;

LIBRARY Utilities;
USE Utilities.Utilities.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS

-- -------------------------------------------------------------------------       
  TYPE tData IS RECORD
    Px                 : SIGNED( PtWidth DOWNTO 0 );
    Py                 : SIGNED( PtWidth DOWNTO 0 );
    Sector             : UNSIGNED( SectorWidth - 1 DOWNTO 0 );
    Et                 : UNSIGNED( METMagWidth - 1 DOWNTO 0 );
    Phi                : UNSIGNED( METPhiWidth - 1 DOWNTO 0 );
    NumTracks          : UNSIGNED( METNtrackWidth - 1 DOWNTO 0 );
 
    DataValid    : BOOLEAN;
    FrameValid   : BOOLEAN;
  END RECORD;
  
  ATTRIBUTE SIZE : NATURAL;
  ATTRIBUTE SIZE of tData : TYPE IS PtWidth+ PtWidth + SectorWidth + METMagWidth + METPhiWidth + METNtrackWidth; -- Actual is 34, roundup to 36 for BRAM boundary

-- A record to encode the bit location of each field of the tData record
-- when packaged into a std_logic_vector
  TYPE tFieldLocations IS RECORD
    Pxl     : INTEGER;
    Pxh     : INTEGER;
    Pyl : INTEGER;
    Pyh : INTEGER;
    Sectorl : INTEGER;
    Sectorh : INTEGER;
    Etl : INTEGER;
    Eth : INTEGER;
    Phil : INTEGER;
    Phih : INTEGER;
    Ntrackl : INTEGER;
    Ntrackh : INTEGER;


  END RECORD;

  CONSTANT bitloc                      : tFieldLocations := ( 0 ,                                                                      PtWidth - 1 ,
                                                        PtWidth ,                                                            PtWidth + PtWidth - 1 , 
                                              PtWidth + PtWidth ,                                              SectorWidth + PtWidth + PtWidth - 1 ,
                               SectorWidth +  PtWidth + PtWidth ,                                METMagWidth + SectorWidth + PtWidth + PtWidth - 1 ,
                 METMagWidth + SectorWidth +  PtWidth + PtWidth ,                  METPhiWidth + METMagWidth + SectorWidth + PtWidth + PtWidth - 1 ,
   METPhiWidth + METMagWidth + SectorWidth +  PtWidth + PtWidth , METNtrackWidth + METPhiWidth + METMagWidth + SectorWidth + PtWidth + PtWidth - 1 ); 
  CONSTANT cNull                       : tData           := ( ( OTHERS => '0' ) ,
                                                              ( OTHERS => '0' ) , 
                                                              ( OTHERS => '0' ) , 
                                                              ( OTHERS => '0' ) ,
                                                              ( OTHERS => '0' ) , 
                                                              ( OTHERS => '0' ) , 
                                                              false , 
                                                              false );

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
    VARIABLE lRet                  : STD_LOGIC_VECTOR( tData'Size-1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    lRet( bitloc.Pxh     DOWNTO bitloc.Pxl     )    := STD_LOGIC_VECTOR( aData.Px );
    lRet( bitloc.Pyh     DOWNTO bitloc.Pyl     )    := STD_LOGIC_VECTOR( aData.Py );
    lRet( bitloc.Sectorh DOWNTO bitloc.Sectorl )    := STD_LOGIC_VECTOR( aData.Sector );
    lRet( bitloc.Eth     DOWNTO bitloc.Etl     )    := STD_LOGIC_VECTOR( aData.Et );
    lRet( bitloc.Phih    DOWNTO bitloc.Phil    )    := STD_LOGIC_VECTOR( aData.Phi );
    lRet( bitloc.Ntrackh DOWNTO bitloc.Ntrackl )    := STD_LOGIC_VECTOR( aData.NumTracks );
    lRet( bitloc.Ntrackh + 1 )                      := to_std_logic( aData.DataValid );
    
    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN
    lRet.Px           :=   SIGNED(   aStdLogicVector( bitloc.Pxh     DOWNTO bitloc.Pxl ) );
    lRet.Py           :=   SIGNED(   aStdLogicVector( bitloc.Pyh     DOWNTO bitloc.Pyl ) );
    lRet.Sector       := UNSIGNED(   aStdLogicVector( bitloc.Sectorh DOWNTO bitloc.Sectorl ) );
    lRet.Et           := UNSIGNED(   aStdLogicVector( bitloc.Eth     DOWNTO bitloc.Etl ) );
    lRet.Phi          := UNSIGNED(   aStdLogicVector( bitloc.Phih    DOWNTO bitloc.Phil ) );
    lRet.NumTracks    := UNSIGNED(   aStdLogicVector( bitloc.Ntrackh    DOWNTO bitloc.Ntrackl ) );
    lRet.DataValid    := to_boolean( aStdLogicVector( bitloc.Ntrackh + 1 ) );

    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "Px" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Py" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Sector" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Et" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Phi" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Ntrack" ) , RIGHT , 15 );

    WRITE( aLine , STRING' ( "FrameValid" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "DataValid" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , TO_INTEGER( aData.Px ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Py ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Sector ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Et ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Phi ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.NumTracks ) , RIGHT , 15 );

    WRITE( aLine , aData.FrameValid , RIGHT , 15 );
    WRITE( aLine , aData.DataValid , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;

END DataType;
