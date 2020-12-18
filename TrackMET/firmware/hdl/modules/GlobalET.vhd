-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY ET;
USE ET.DataType.ALL;
USE ET.ArrayTypes.ALL;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;

LIBRARY TrackMET;
USE TrackMET.ROMConstants.all;
USE TrackMET.CordicSqrt;

-- -------------------------------------------------------------------------
ENTITY GlobalET IS

  PORT(
    clk                  : IN  STD_LOGIC := '0'; -- The algorithm clock
    SectorEtPipeIn       : IN VectorPipe;
    EtOut                : OUT VectorPipe
  );
END GlobalET;


  ARCHITECTURE rtl OF GlobalET IS

  FUNCTION SumPx (EtVector : Vector) return Integer IS
  VARIABLE temp_px : INTEGER := 0;
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).DataValid THEN
        temp_px := temp_px + TO_INTEGER(EtVector( i ).Px);
      ELSE
        temp_px := temp_px;
      END IF;
    END LOOP;

  RETURN temp_px; 
  END FUNCTION SumPx;

  FUNCTION SumPy (EtVector : Vector) return Integer IS
  VARIABLE temp_py : INTEGER := 0;
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).DataValid THEN
        temp_py := temp_py + TO_INTEGER(EtVector( i ).Py);
      ELSE
        temp_py := temp_py;
      END IF;
    END LOOP;

  RETURN temp_py;
  END FUNCTION SumPy;

  FUNCTION AnyFrameValid (EtVector : Vector) return BOOLEAN IS
  VARIABLE valid_count : INTEGER := 0;
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).FrameValid THEN
        valid_count := valid_count + 1;
      ELSE
        valid_count := valid_count;
      END IF;
    END LOOP;
  RETURN valid_count > 0;
  END FUNCTION AnyFrameValid;

  FUNCTION AnyDataValid (EtVector : Vector) return BOOLEAN IS
  VARIABLE valid_count : INTEGER := 0;
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).DataValid THEN
        valid_count := valid_count + 1;
      ELSE
        valid_count := valid_count;
      END IF;
    END LOOP;
  RETURN valid_count > 0;
  END FUNCTION AnyDataValid;

  SIGNAL Output : Vector( 0 TO 0 ) := NullVector( 1 );
  SIGNAL InputEt : Vector( 0 TO 17 ) := NullVector( 18 );

  SIGNAL tempfvld1 : BOOLEAN := FALSE;
  SIGNAL tempfvld2 : BOOLEAN := FALSE;
  SIGNAL tempfvld3 : BOOLEAN := FALSE;
  SIGNAL tempfvld4 : BOOLEAN := FALSE;
  SIGNAL tempfvld5 : BOOLEAN := FALSE;
  SIGNAL tempfvld6 : BOOLEAN := FALSE;
  SIGNAL tempfvld7 : BOOLEAN := FALSE;
  SIGNAL tempfvld8 : BOOLEAN := FALSE;
  SIGNAL tempfvld9 : BOOLEAN := FALSE;
  SIGNAL tempfvld10 : BOOLEAN := FALSE;
  SIGNAL tempfvld11 : BOOLEAN := FALSE;

  SIGNAL tempdvld1 : BOOLEAN := FALSE;

  SIGNAL tempPx1 : INTEGER := 0;
  SIGNAL tempPy1 : INTEGER := 0;
  SIGNAL tempPx2 : INTEGER := 0;
  SIGNAL tempPy2 : INTEGER := 0;
  --SIGNAL tempPx3 : INTEGER := 0;
  --SIGNAL tempPy3 : INTEGER := 0;
  --SIGNAL tempPx4 : INTEGER := 0;
  --SIGNAL tempPy4 : INTEGER := 0;
  --SIGNAL tempPx5 : INTEGER := 0;
  --SIGNAL tempPy5 : INTEGER := 0;
  --SIGNAL tempPx6 : INTEGER := 0;
  --SIGNAL tempPy6 : INTEGER := 0;
  --SIGNAL tempPx7 : INTEGER := 0;
  --SIGNAL tempPy7 : INTEGER := 0;
  --SIGNAL tempPx8 : INTEGER := 0;
  --SIGNAL tempPy8 : INTEGER := 0;
  --SIGNAL tempPx9 : INTEGER := 0;
  --SIGNAL tempPy9 : INTEGER := 0;
  --SIGNAL tempPx10 : INTEGER := 0;
  --SIGNAL tempPy10 : INTEGER := 0;

  SIGNAL RootSum   : SIGNED(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL tempEt    : INTEGER := 0;

  SIGNAL tempPxSum : INTEGER := 0;
  SIGNAL tempPySum : INTEGER := 0;

  COMPONENT CordicSqrt IS
  GENERIC(n_steps : NATURAL RANGE 1 TO 8 := 4);
  PORT(
    clk  : IN STD_LOGIC; -- clock
    Xin  : IN SIGNED ( 15 DOWNTO 0 )  := ( OTHERS => '0' );
    Yin  : IN SIGNED ( 15 DOWNTO 0 )  := ( OTHERS => '0' );
    Root : OUT SIGNED ( 15 DOWNTO 0 ) := ( OTHERS => '0' )
  );
END COMPONENT CordicSqrt;

  BEGIN
    Sqrt : CordicSqrt
    GENERIC MAP (n_steps => 4)
    PORT MAP(
      clk => clk,
      Xin => TO_SIGNED(tempPx2,16),
      Yin => TO_SIGNED(tempPy2,16),
      Root  => RootSum
    );


    InputEt <= SectorEtPipeIn( 0 );
    PROCESS( clk )

      VARIABLE tempPxSum : INTEGER := 0;
      VARIABLE tempPySum : INTEGER := 0;
      
    BEGIN
      
      IF RISING_EDGE( clk ) THEN
-- ----------------------------------------------------------------------------------------------
-- Clock 1
        tempfvld1 <= AnyFrameValid(InputEt);
        tempdvld1 <= AnyDataValid(InputEt);
        tempPx1 <= SumPx( InputEt );
        tempPy1 <= SumPy( InputEt );
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 2
        IF tempdvld1 THEN
          tempPxSum := tempPxSum + tempPx1;
          tempPySum := tempPySum + tempPy1;
        ELSE
          tempPxSum := tempPxSum;
          tempPySum := tempPySum;
        END IF;
      
  
        tempPx2 <= tempPxSum;
        tempPy2 <= tempPySum;
        tempfvld2 <= tempfvld1;
-- ----------------------------------------------------------------------------------------------
-- CORDIC BEGINS for 8 Clocks
-- ----------------------------------------------------------------------------------------------
-- Clock 3
        --tempPx3 <= tempPx2;
        --tempPy3 <= tempPy2;
        tempfvld3 <= tempfvld2;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 4
        --tempPx4 <= tempPx3;
        --tempPy4 <= tempPy3;
        tempfvld4 <= tempfvld3;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 5
        --tempPx5 <= tempPx4;
        --tempPy5 <= tempPy4;
        tempfvld5 <= tempfvld4;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 6
        --tempPx6 <= tempPx5;
        --tempPy6 <= tempPy5;
        tempfvld6 <= tempfvld5;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 7
        --tempPx7 <= tempPx6;
        --tempPy7 <= tempPy6;
        tempfvld7 <= tempfvld6;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 8
        --tempPx8 <= tempPx7;
        --tempPy8 <= tempPy7;
        tempfvld8 <= tempfvld7;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 9
        --tempPx9 <= tempPx8;
        --tempPy9 <= tempPy8;
        tempfvld9 <= tempfvld8;
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 10
        --tempPx10 <= tempPx9;
        --tempPy10 <= tempPy9;
        tempfvld10 <= tempfvld9;
        tempEt <= (TO_INTEGER(RootSum)*39901)/2**15;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 11
        tempfvld11 <= tempfvld10;

        IF tempfvld11 AND NOT tempfvld10 THEN
          tempPxSum := 0;
          tempPySum := 0;
          Output( 0 ) <= ET.DataType.cNull;
        ELSE
            --Output( 0 ) .Px <= TO_SIGNED(tempPx10,16);
            --Output( 0 ) .Py <= TO_SIGNED(tempPy10,16);
            Output( 0 ) .Et <= TO_UNSIGNED(tempEt,16);
            
        END IF;
        
        Output( 0 ) .DataValid  <= tempfvld10 AND NOT tempfvld9;
        Output( 0 ) .FrameValid <= tempfvld10;
  
      END IF;
  END PROCESS;

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY Et.DataPipe
  PORT MAP( clk , Output , EtOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY Et.Debug
  GENERIC MAP( "GlobalET" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;