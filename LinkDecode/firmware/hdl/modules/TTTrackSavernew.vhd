LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY Utilities;
USE Utilities.Utilities.ALL;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY Vertex;
USE Vertex.DataType;
USE Vertex.ArrayTypes;

ENTITY TTTrackSaver IS

  PORT(
    clk     : IN STD_LOGIC := '0'; -- The algorithm clock
    TTTrackPipeIn   : IN TTTrack.ArrayTypes.VectorPipe;
    PrimaryVertexPipeIn : IN  Vertex.ArrayTypes.VectorPipe;
    TTTrackPipeOut      : OUT TTTrack.ArrayTypes.VectorPipe
  );
END TTTrackSaver;

ARCHITECTURE rtl OF TTTrackSaver IS
  
  SIGNAL Output       : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  SIGNAL Input        : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  
  
BEGIN


Input <= TTTrackPipeIn(0);


g1 : FOR i IN 0 TO 17 GENERATE
  SIGNAL WriteAddr    : NATURAL RANGE 0 TO 511 := 0;
  SIGNAL ReadAddr     : NATURAL RANGE 0 TO 511 := 0;

  SIGNAL OutTrack  : TTTrack.DataType.tData := TTTrack.DataType.cNull;
  SIGNAL NextOutTrack  : TTTrack.DataType.tData := TTTrack.DataType.cNull;

  SIGNAL PrimaryVertex : UNSIGNED( 7 DOWNTO 0 ) := "00000000" ;

  SIGNAL reset : STD_LOGIC := '0';

BEGIN 


  RAM : ENTITY TTTrack.DataRam
  GENERIC MAP(
    Count => 512,
    Style => "block"
  )
  PORT MAP(
    clk         => clk , -- The algorithm clock
    WriteAddr   => WriteAddr ,
    DataIn      => Input( i ) ,                        
    WriteEnable => Input( i ).DataValid ,
    ReadAddr    => ReadAddr ,
    DataOut     => OutTrack
  );

  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( Input( i ).FrameValid) THEN
        IF( Input( i ) .DataValid ) THEN
          WriteAddr <= (WriteAddr + 1 ) MOD 512;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF (PrimaryVertexPipeIn( 0 )( 0 ).DataValid) THEN
        PrimaryVertex <= PrimaryVertexPipeIn( 0 )( 0 ).Z0;
        reset <= '1';
      END IF;
    END IF;
  END PROCESS;

  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF reset THEN
        ReadAddr <= (ReadAddr + 1)  MOD 512;    
      END IF;
    END IF;
  END PROCESS;

  NextOutTrack <= OutTrack;

  reset <= '0' WHEN OutTrack.FrameValid AND NOT NextOutTrack.FrameValid ELSE '1';
  
  Output( i ).Pt <= NextOutTrack.Pt;
  Output( i ).FrameValid <= NextOutTrack.FrameValid;
  Output( i ).DataValid <= True;
  Output( i ).PV <= PrimaryVertex;
     
END GENERATE;



      

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
OutputPipeInstance : ENTITY TTTrack.DataPipe
PORT MAP( clk , Output , TTTrackPipeOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
DebugInstance : ENTITY TTTrack.Debug
GENERIC MAP( "TrackSaver" )
PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;