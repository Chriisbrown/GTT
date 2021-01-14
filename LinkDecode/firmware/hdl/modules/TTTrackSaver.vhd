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

  SUBTYPE tAddress        IS INTEGER RANGE 0 TO 511;
  TYPE tAddressArray      IS ARRAY( 0 TO 17 ) OF tAddress;

  SIGNAL WriteAddr    : tAddressArray      := ( OTHERS => 0 );
  SIGNAL ReadAddr     : tAddressArray      := ( OTHERS => 0 );


BEGIN

Input <= TTTrackPipeIn(0);


g1 : FOR i IN 0 TO 17 GENERATE

  SIGNAL OutTrack  : TTTrack.DataType.tData := TTTrack.DataType.cNull;
  SIGNAL TempTrack : TTTrack.DataType.tData := TTTrack.DataType.cNull;

  SIGNAL PrimaryVertex : UNSIGNED( 7 DOWNTO 0 ) := "00000000" ;
  SIGNAL Track_vld : BOOLEAN := FALSE;


BEGIN 
  RAM : ENTITY TTTrack.DataRam
  PORT MAP(
    clk         => clk , -- The algorithm clock
    WriteAddr   => WriteAddr( i ) ,
    DataIn      => TempTrack ,                        
    WriteEnable => TempTrack.DataValid ,
    ReadAddr    => ReadAddr( i ) ,
    DataOut     => OutTrack
  );

  PROCESS( clk )

  VARIABLE Read_Reset : BOOLEAN := FALSE;

  VARIABLE NumReadTracks : INTEGER := 0;
  VARIABLE ReadTotal     : INTEGER := 0;
  VARIABLE WriteTotal    : INTEGER := 0;

  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      TempTrack <= Input( i );  -- Delay Input Tracks by 1 clock
      IF( TempTrack.FrameValid) THEN
        IF( TempTrack .DataValid ) THEN
          WriteAddr( i ) <= (WriteAddr( i ) + 1 ) MOD 512;  --Increment Write Pointer If Track is Valid
          WriteTotal := WriteTotal + 1;      -- Update Track Totals
        END IF;
      END IF;

      IF (  TempTrack.FrameValid AND NOT Input( i ) .FrameValid) THEN  -- Check if end of tracks being read in
        ReadTotal := WriteTotal;     -- Copy Track totals to number of tracks to be read
        WriteTotal := 0;             -- Reset Track Totals
      END IF;
        
      IF (PrimaryVertexPipeIn( 0 )( 0 ).DataValid) THEN   -- Wait for Primary Vertex valid
        PrimaryVertex <= PrimaryVertexPipeIn( 0 )( 0 ).Z0; -- Store PV
        NumReadTracks := 0;     -- Reset Number of read tracks
        Read_Reset := TRUE;     -- Start Reading
      END IF;

      
      IF NumReadTracks < ReadTotal THEN  -- If Number of read tracks < total number stored tracks
        IF Read_Reset THEN  
          ReadAddr( i ) <= (ReadAddr( i ) + 1)  MOD 512;  -- Increment Read pointer if reading
          NumReadTracks := NumReadTracks + 1;  -- Update read totals
          Track_vld <= True;  -- Track is Valid
        END IF;
      ELSE
        Read_Reset := FALSE;  -- Finished reading 
        Track_vld <= FALSE;   -- Not valid track
        ReadTotal := 0;       -- Update track totals
        NumReadTracks := 0;
      END IF;

      Output( i ) <= OutTrack;
      Output( i ).PV <= PrimaryVertex;
      Output( i ).DataValid <= Track_vld;
      Output( i ).FrameValid <= Track_vld;
     
      
    END IF;
  END PROCESS;
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