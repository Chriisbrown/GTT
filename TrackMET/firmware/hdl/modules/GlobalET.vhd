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
USE TrackMET.UnclockedSquareRoot;

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

  SIGNAL tempdvld1 : BOOLEAN := FALSE;

  SIGNAL tempPx1 : INTEGER := 0;
  SIGNAL tempPy1 : INTEGER := 0;

  SIGNAL tempPx2 : INTEGER := 0;
  SIGNAL tempPy2 : INTEGER := 0;

  SIGNAL tempPx3 : INTEGER := 0;
  SIGNAL tempPy3 : INTEGER := 0;

  SIGNAL tempPx4 : INTEGER := 0;
  SIGNAL tempPy4 : INTEGER := 0;

  SIGNAL tempPx5 : INTEGER := 0;
  SIGNAL tempPy5 : INTEGER := 0;

  SIGNAL tempPxSquared : INTEGER := 0;
  SIGNAL tempPySquared : INTEGER := 0;

  SIGNAL SquareSum : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL RootSum   : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL RootSum2   : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');

  COMPONENT UnclockedSquareRoot IS
  PORT(
    ValueIn   : IN UNSIGNED ( 31 DOWNTO 0 ) := ( OTHERS => '0' );
    Result : OUT UNSIGNED ( 15 DOWNTO 0 ) := ( OTHERS => '0' )
  );
END COMPONENT UnclockedSquareRoot;

  BEGIN
    Sqrt : UnclockedSquareRoot
    PORT MAP(
      ValueIn => SquareSum,
      Result  => RootSum
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

-- ----------------------------------------------------------------------------------------------
-- Clock 3
        tempPxSquared <= (tempPx2*tempPx2);
        tempPySquared <= (tempPy2*tempPy2);

        tempPx3 <= tempPx2;
        tempPy3 <= tempPy2;
        tempfvld3 <= tempfvld2;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 4
        SquareSum <= TO_UNSIGNED((tempPxSquared/4 + tempPySquared/4),32);

        tempPx4 <= tempPx3;
        tempPy4 <= tempPy3;
        tempfvld4 <= tempfvld3;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 5
        RootSum2 <= RootSum;
        tempPx5 <= tempPx4;
        tempPy5 <= tempPy4;
        tempfvld5 <= tempfvld4;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 6
        tempfvld6 <= tempfvld5;

        IF tempfvld6 AND NOT tempfvld5 THEN
          tempPxSum := 0;
          tempPySum := 0;
          Output( 0 ) <= ET.DataType.cNull;
        ELSE
            Output( 0 ) .Px <= TO_SIGNED(tempPx5,16);
            Output( 0 ) .Py <= TO_SIGNED(tempPy5,16);
            Output( 0 ) .Et <= TO_UNSIGNED((TO_INTEGER(RootSum2)*2),16);
        END IF;
        
        Output( 0 ) .DataValid  <= tempfvld5 AND NOT tempfvld4;
        Output( 0 ) .FrameValid <= tempfvld5;
  
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