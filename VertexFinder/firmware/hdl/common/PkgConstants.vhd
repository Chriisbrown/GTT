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

-- Remember to adjust UCF file...
  CONSTANT cTimeMultiplexingPeriod : INTEGER := 18;
  CONSTANT cFramesPerBx            : INTEGER := 12;

  CONSTANT cPacketLength           : INTEGER := cTimeMultiplexingPeriod * cFramesPerBx;
-- CONSTANT cNumberOfLinksIn          : INTEGER := cNumberOfQuadsIn * 4;

END constants;
