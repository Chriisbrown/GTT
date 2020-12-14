-- .library VertexFinder

-- .include ReuseableElements/DistributionServer.vhd in Vertex


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY Vertex;
USE Vertex.DataType.ALL;
USE Vertex.ArrayTypes.ALL;

LIBRARY VertexFinder;

-- 18 -> 64 router for histogram objects
-- First stage is 6 x (3 -> 8) (1 dummy input)
-- Second stage is 8 * (6 -> 8)

ENTITY VertexDistribution IS
PORT(
  clk           : IN STD_LOGIC;
  VertexPipeIn  : IN VectorPipe; --(0 to 17); 
  VertexPipeOut : OUT VectorPipe --(0 to 63)
);
END VertexDistribution;

ARCHITECTURE Behavioral OF VertexDistribution IS

-- Signal Groups
  SIGNAL l0i_grp : Matrix( 0 TO 5 )( 0 TO 2 ) := NullMatrix( 6 , 3 ); -- Input to Route Layer 0 (6 grps of 3)
  SIGNAL l0o_grp : Matrix( 0 TO 5 )( 0 TO 7 ) := NullMatrix( 6 , 8 ); -- Output of Route Layer 0 (6 grps of 8)

  SIGNAL l1i_grp : Matrix( 0 TO 7 )( 0 TO 5 ) := NullMatrix( 8 , 6 ); -- Input to Route Layer 1 (8 grps of 6)
  SIGNAL l1o_grp : Matrix( 0 TO 7 )( 0 TO 7 ) := NullMatrix( 8 , 8 ); -- Output of Route Layer 1 (8 grps of 8)

  SIGNAL Output  : Vector( 0 TO 63 )          := NullVector( 64 );

BEGIN

-- Group the input: each group goes to one router node
GrpInput :
FOR i IN 0 TO 17 GENERATE
  PROCESS( clk )
    VARIABLE SortKeyAssigned : tData := cNull;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      SortKeyAssigned         := VertexPipeIn( 0 )( i );
      SortKeyAssigned.SortKey := TO_INTEGER( SortKeyAssigned.z0( 7 DOWNTO 5 ) );
--SortKeyAssigned.SortKey := to_integer(unsigned(std_logic_vector(SortKeyAssigned.z0(7 downto 5))));
      l0i_grp( i / 3 )( i MOD 3 ) <= SortKeyAssigned;
    END IF;
  END PROCESS;
--l0i_grp(i / 4)(i mod 4) <= VertexPipeIn(0)(i);
-- The SortKey for the first layer is the 3 MSBs
-- ie the layer routes into 8'ths
--l0i_grp(i / 4)(i mod 4).SortKey <= to_integer(unsigned(std_logic_vector(VertexPipeIn(0)(i).z0(7 downto 5))));
END GENERATE;
-- The dummy input to the router
--l0i_grp( 5 )( 2 ) <= cNull;

RouteLayer0 :
FOR i IN 0 TO 5 GENERATE
  Node : ENTITY Vertex.DistributionServer
  generic map(interleaving => 3)
  PORT MAP( clk => clk , DataIn => l0i_grp( i ) , DataOut => l0o_grp( i ) );
END GENERATE;

-- Connect the output groups from layer 0 to the input groups of layer 1
-- The j'th element in group i connects to the i'th element in group j of the next layer
Connect0to1a :
FOR i IN 0 TO 5 GENERATE
Connect0to1b :
  FOR j IN 0 TO 7 GENERATE
-- The sortkey for the next layer is the 3 bits below the 3 MSBs
    PROCESS( clk )
      VARIABLE shiftedaddr : tData := cNull;
      BEGIN
      IF( RISING_EDGE( clk ) ) THEN
        shiftedaddr         := l0o_grp( i )( j );
        shiftedaddr.SortKey := TO_INTEGER( shiftedaddr.z0( 4 DOWNTO 2 ) );
--shiftedaddr.SortKey := to_integer(unsigned(std_logic_vector(shiftedaddr.z0(4 downto 2))));
        l1i_grp( j )( i ) <= shiftedaddr;
      END IF;
    END PROCESS;
--l1i_grp(j)(i) <= l0o_grp(i)(j);
  END GENERATE;
END GENERATE;

RouteLayer1 :
FOR i IN 0 TO 7 GENERATE
  Node : ENTITY Vertex.DistributionServer
generic map(interleaving => 3)
  PORT MAP( clk => clk , DataIn => l1i_grp( i ) , DataOut => l1o_grp( i ) );
END GENERATE;

ConnectOutput :
FOR i IN 0 TO 63 GENERATE
  Output( i ) <= l1o_grp( i / 8 )( i MOD 8 );
END GENERATE;

-- Store the result in a pipeline
OutputPipeInstance : ENTITY Vertex.DataPipe
PORT MAP( clk , Output , VertexPipeOut );

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY Vertex.Debug
  GENERIC MAP( "VertexDistribution" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END Behavioral;
