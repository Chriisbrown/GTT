-- .library VertexFinder

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY Vertex;
USE Vertex.DataType.ALL;
USE Vertex.ArrayTypes.ALL;

LIBRARY VertexFinder;

-- Fanout each endpoint of the 18 -> 64 router to another 4 endpoints
-- Making a 18 -> 256 router
ENTITY Fanout64_256 IS
PORT(
  clk           : IN STD_LOGIC;
  VertexPipeIn  : IN VectorPipe; --(0 to 63);
  VertexPipeOut : OUT VectorPipe --(0 to 255)
);
END Fanout64_256;

ARCHITECTURE Behavioral OF Fanout64_256 IS

  SIGNAL Output : Vector( 0 TO 255 ) := NullVector( 256 );

BEGIN

--Fanout:
--for i in 0 to 63 generate
--  process(clk)
--  begin
--    case std_logic_vector(to_unsigned(VertexPipeIn(0)(i).SortKey, 2)) is
--      when "00" => VertexPipeOut(4 * (i+i) - 1 downto 4 * i) <= (0 => ( 4 * i => VertexPipeIn(0)(i), others => cNull));
--      when "01" => VertexPipeOut(4 * (i+i) - 1 downto 4 * i) <= (0 => (4 * i + 1 => VertexPipeIn(0)(i), others => cNull));
--      when "10" => VertexPipeOut(4 * (i+i) - 1 downto 4 * i) <= (0 => (4 * i + 2 => VertexPipeIn(0)(i), others => cNull));
--      when "11" => VertexPipeOut(4 * (i+i) - 1 downto 4 * i) <= (0 => (4 * i + 3 => VertexPipeIn(0)(i), others => cNull));
--      when others => VertexPipeOut(4 * (i + 1) - 1 downto 4 * i) <= (0 => (others => cNull));
--    end case;
--  end process;
--end generate;

Fanout :
FOR i IN 0 TO 255 GENERATE
  PROCESS( VertexPipeIn )
  BEGIN
    IF TO_INTEGER( UNSIGNED( STD_LOGIC_VECTOR( VertexPipeIn( 0 )( i / 4 ) .z0( 1 DOWNTO 0 ) ) ) ) = i MOD 4 THEN
      Output( i ) <= VertexPipeIn( 0 )( i / 4 );
    ELSE
      Output( i )             <= cNull;
      Output( i ) .FrameValid <= VertexPipeIn( 0 )( i / 4 ) .FrameValid;
    END IF;
  END PROCESS;
END GENERATE;

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY Vertex.DataPipe
  PORT MAP( clk , Output , VertexPipeOut );

END Behavioral;
