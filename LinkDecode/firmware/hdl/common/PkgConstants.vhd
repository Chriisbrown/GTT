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
LIBRARY GTT;
USE GTT.GTTDataFormats.ALL;
-- -------------------------------------------------------------------------
PACKAGE constants IS

  CONSTANT WordLength : INTEGER := 64;

  CONSTANT RAMDepth : INTEGER := 128;


  CONSTANT InvRtoPtNormalisation : INTEGER := 700573;
  CONSTANT FracScale : INTEGER := 262144;
END constants;
