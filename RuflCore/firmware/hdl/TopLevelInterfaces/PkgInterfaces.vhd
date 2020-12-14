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

-- .library Interfaces

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;
-- -------------------------------------------------------------------------
USE work.mp7_data_types.ALL;


-- -------------------------------------------------------------------------
PACKAGE DataType IS

  TYPE tData IS
    RECORD
      data   : lword;
      DataValid  : BOOLEAN;
    END RECORD;

  CONSTANT cNull : tData := ( LWORD_NULL, FALSE );

  FUNCTION WriteHeader RETURN STRING;
  FUNCTION WriteData( aData : tData ) RETURN STRING;

END DataType;

PACKAGE BODY DataType is

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine, STRING' ( "data" ) , RIGHT , 15 );
    WRITE( aLine, STRING' ( "valid" ) , RIGHT , 15 );
    WRITE( aLine, STRING' ( "start" ) , RIGHT , 15 );
    WRITE( aLine, STRING' ( "strobe" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , aData.data.data , RIGHT , 15 );
    WRITE( aLine , aData.data.valid , RIGHT , 15 );
    WRITE( aLine , aData.data.start , RIGHT , 15 );
    WRITE( aLine , aData.data.strobe , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;

END DataType;
