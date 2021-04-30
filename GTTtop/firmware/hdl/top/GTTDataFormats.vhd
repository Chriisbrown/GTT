-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE GTTDataFormats IS

-- -----------TTTrack Config ------------------------------------
CONSTANT widthExtraMVA           : NATURAL :=  6;  
CONSTANT widthTQMVA              : NATURAL :=  3;  
CONSTANT widthHitPattern         : NATURAL :=  7;  
CONSTANT widthBendChi2           : NATURAL :=  3;  
CONSTANT widthChi2RPhi           : NATURAL :=  4;  
CONSTANT widthChi2RZ             : NATURAL :=  4;  
CONSTANT widthD0                 : NATURAL :=  13;  
CONSTANT widthZ0                 : NATURAL :=  12;  
CONSTANT widthTanL               : NATURAL :=  16;  
CONSTANT widthPhi0               : NATURAL :=  12;  
CONSTANT widthInvR               : NATURAL :=  15;  

CONSTANT widthTTTrack            : NATURAL :=  96;
CONSTANT widthpartialTTTrack     : NATURAL :=  32;


-- -----------Internal Config ------------------------------------

CONSTANT VertexZ0Width  : NATURAL  := 8;
CONSTANT EtaWidth       : NATURAL  := 12; --10;
CONSTANT PtWidth        : NATURAL  := widthInvR; --14;
CONSTANT GlobalPhiWidthExtra : NATURAL  := 3; --11 + 3;
CONSTANT GlobalPhiWidth : NATURAL  := 8 + GlobalPhiWidthExtra;


CONSTANT SectorWidth : NATURAL := 4;

-- -----------Output Config ------------------------------------

CONSTANT METMagWidth    : NATURAL := 15;
CONSTANT METPhiWidth    : NATURAL := 14;
CONSTANT METNtrackWidth : NATURAL := 8;

END GTTDataFormats;