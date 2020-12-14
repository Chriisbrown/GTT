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


  FUNCTION SquareRoot ( x : UNSIGNED) return UNSIGNED IS
  VARIABLE X_in : UNSIGNED(31 DOWNTO 0) := x;
  VARIABLE Y_out : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
  VARIABLE left,right,remain : UNSIGNED(17 DOWNTO 0) := (OTHERS => '0');
  BEGIN
    FOR i IN Y_out'Range LOOP
      right( 0 ) :=  '1' ;
      right( 1 ) := remain( 17 );
      right(17 DOWNTO 2) := Y_out;
      left(1 DOWNTO 0) := X_in(31 DOWNTO 30);
      left(17 DOWNTO 2) := remain(15 DOWNTO 0);
      X_in(31 DOWNTO 2) := X_in(29 DOWNTO 0);  --shifting by 2 bit.
      IF ( remain(17) = '1') THEN
        remain := left + right;
      ELSE
        remain := left - right;
      END IF;
      Y_out(15 DOWNTO 1) := Y_out(14 DOWNTO 0);
      Y_out(0) := NOT remain(17);
    END LOOP;
  RETURN Y_out;
  END FUNCTION SquareRoot;

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

  
  BEGIN
    InputEt <= SectorEtPipeIn( 0 );
    PROCESS( clk )
      VARIABLE Px : INTEGER := 0;
      VARIABLE Py : INTEGER := 0;

      VARIABLE tempPx : INTEGER := 0;
      VARIABLE tempPy : INTEGER := 0;
      VARIABLE tempPx2 : INTEGER := 0;
      VARIABLE tempPy2 : INTEGER := 0;
      VARIABLE tempPx3 : INTEGER := 0;
      VARIABLE tempPy3 : INTEGER := 0;
      
      VARIABLE SquareSum : INTEGER := 0;
      VARIABLE RootSum   : INTEGER := 0;

    BEGIN
      
      IF RISING_EDGE( clk ) THEN
        tempfvld1 <= AnyFrameValid(InputEt);
        tempfvld2 <= tempfvld1;
        tempfvld3 <= tempfvld2;
        tempfvld4 <= tempfvld3;
        tempfvld5 <= tempfvld4;

        IF tempfvld5 AND NOT tempfvld4 THEN
          tempPx := 0;
          tempPy := 0;
          tempPx2 := 0;
          tempPy2 := 0;
          tempPx3 := 0;
          tempPy3 := 0;
          Px := 0;
          Py := 0;
          SquareSum := 0;
          RootSum := 0;
          Output( 0 ) <= ET.DataType.cNull;


        ELSIF AnyDataValid(InputEt) THEN 
            tempPx := SumPx( InputEt );
            tempPy := SumPy( InputEt );

            tempPx2 := tempPx2 + tempPx;
            tempPy2 := tempPy2 + tempPy;

            tempPx3 := tempPx2;
            tempPy3 := tempPy2;
            
            SquareSum := (tempPx2*tempPx2)/4 + (tempPy2*tempPy2)/4;

            Px := tempPx3;
            Py := tempPy3;

            RootSum := TO_INTEGER(SquareRoot(TO_UNSIGNED(SquareSum,32))*2);

            Output( 0 ) .Px <= TO_SIGNED(Px,16);
            Output( 0 ) .Py <= TO_SIGNED(Py,16);
            Output( 0 ) .Et <= TO_UNSIGNED(RootSum,16);

        END IF;
        
        
        Output( 0 ) .DataValid  <= tempfvld4 AND NOT tempfvld3;
        Output( 0 ) .FrameValid <= tempfvld4;
  
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