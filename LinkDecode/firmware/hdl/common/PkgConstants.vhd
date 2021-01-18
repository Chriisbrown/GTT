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

-- .library VertexFinder

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE constants IS

  CONSTANT WordLength : INTEGER := 64;

  CONSTANT RAMDepth : INTEGER := 128;

  CONSTANT ZMax : INTEGER := 15;
  CONSTANT ZSaturate : INTEGER_VECTOR := (0,255);
  CONSTANT ZIntScale : INTEGER_VECTOR := (8,2);
  CONSTANT ZFracScale : INTEGER_VECTOR := (8,64);
  CONSTANT ZConstant : INTEGER : 128;

  CONSTANT PhiShift : INTEGER := 1024;
  CONSTANT PhiMin : INTEGER := 0;
  CONSTANT PhiMax : INTEGER := 6268;

  CONSTANT InvRtoPtNormalisation : INTEGER := 700573;
  CONSTANT FracScale : INTEGER := 262144;
END constants;
