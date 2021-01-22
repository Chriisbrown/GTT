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

LIBRARY LinkDecode;
USE LinkDecode.Constants.all;

ENTITY TTTrackSaver IS

  PORT(
    clk                 : IN STD_LOGIC; -- The algorithm clock
    TTTrackPipeIn       : IN TTTrack.ArrayTypes.VectorPipe  := TTTrack.ArrayTypes.NullVectorPipe( 10 , 18 )
    PrimaryVertexPipeIn : IN  Vertex.ArrayTypes.VectorPipe  := Vertex.ArrayTypes.NullVectorPipe( 10 , 1 );
    TTTrackPipeOut      : OUT TTTrack.ArrayTypes.VectorPipe := TTTrack.ArrayTypes.NullVectorPipe( 10 , 18 );
    ReadAddrOut         : OUT INTEGER_VECTOR(0 TO 17) := (OTHERS => 0);
    WriteAddrOut        : OUT INTEGER_VECTOR(0 TO 17) := (OTHERS => 0)
  );
END TTTrackSaver;

ARCHITECTURE rtl OF TTTrackSaver IS
  
  SIGNAL   Output      : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  CONSTANT ram_depth   : INTEGER                              := RAMDepth; --Max number of tracks per FIFO, (18 FIFOs Total)

BEGIN 

g1 : FOR i IN 0 TO 17 GENERATE

  SIGNAL OutTrack      : TTTrack.DataType.tData := TTTrack.DataType.cNull;

  -- Addresses for reading and writing, cannot be larger than the RAM depth and access non existent RAM
  SIGNAL WriteAddr     : INTEGER RANGE 0 TO ram_depth - 1 := 0;
  SIGNAL ReadAddr      : INTEGER RANGE 0 TO ram_depth - 1 := 0;

  -- Signal to store PV when it arrives

  SIGNAL PrimaryVertex : UNSIGNED( 7 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL Track_vld     : BOOLEAN                := FALSE;

  -- Delay to frame valid

  SIGNAL frame_signal  : BOOLEAN  := FALSE;

  -- Counters and reset for FIFO input and output

  SIGNAL WriteTotal    : INTEGER := 0;  --Total Tracks Written into FIFO
  SIGNAL NumReadTracks : INTEGER := 0;  --Total Track read out of FIFO
  SIGNAL Read_Reset    : BOOLEAN := FALSE; --Flag to initiate reading

BEGIN 
  RAM : ENTITY TTTrack.DataRam
  GENERIC MAP(  Count => ram_depth,
                Style => "block")
  PORT MAP(
    clk         => clk , -- The algorithm clock
    WriteAddr   => WriteAddr ,
    DataIn      => TTTrackPipeIn( 0 )( i ) ,                        
    WriteEnable => TTTrackPipeIn( 0 )( i ).DataValid ,
    ReadAddr    => ReadAddr ,
    DataOut     => OutTrack
  );

  PROCESS( clk )

  VARIABLE ReadTotal : INTEGER := 0;
  
  BEGIN
    IF ( RISING_EDGE( clk ) ) THEN
      IF ( TTTrackPipeIn( 0 )( i ).FrameValid ) THEN
        frame_signal <= TRUE;  --Store Frame valid
        IF ( TTTrackPipeIn( 0 )( i ).DataValid ) THEN
          WriteAddr  <= ( WriteAddr + 1 ) MOD ram_depth;  --Increment Write Pointer If Track is Valid. wrap if > ram_depth
          WriteTotal <=  WriteTotal + 1;      -- Update Track Totals
        ELSE
          WriteTotal <= WriteTotal;
          WriteAddr <= WriteAddr;
        END IF;
      ELSIF NOT TTTrackPipeIn( 0 )( i ).FrameValid AND frame_signal THEN -- Check if end of tracks being read in
        ReadTotal := WriteTotal;     -- Copy Track totals to number of tracks to be read
        WriteTotal <= 0;             -- Reset Track Totals
        WriteAddr <= WriteAddr;
        frame_signal <= FALSE;
      ELSE
        ReadTotal := ReadTotal;
        WriteTotal <= WriteTotal;
        WriteAddr <= WriteAddr;
        frame_signal <= FALSE;
      END IF;
        
      IF ( PrimaryVertexPipeIn( 0 )( 0 ).DataValid ) THEN   -- Wait for Primary Vertex valid
        PrimaryVertex <= PrimaryVertexPipeIn( 0 )( 0 ).Z0; -- Store PV
        NumReadTracks <= 0;     -- Reset Number of read tracks
        Read_Reset <= TRUE;     -- Start Reading
        ReadAddr <= ReadAddr;
        Track_vld <= FALSE;

      ELSIF NumReadTracks < ReadTotal THEN  -- If Number of read tracks < total number stored tracks
        IF Read_Reset THEN  
          ReadAddr      <= ( ReadAddr + 1 ) MOD ram_depth; -- Increment Read pointer if reading wrap if > ram_depth
          NumReadTracks <= NumReadTracks + 1;              -- Update read totals
          Track_vld     <= True;                           -- Track is Valid
          PrimaryVertex <= PrimaryVertex;
        ELSE     
          ReadAddr <= ReadAddr;
          NumReadTracks <= NumReadTracks;
          PrimaryVertex <= PrimaryVertex;
          Track_vld <= False;                   
        END IF;
        
      ELSE
        ReadAddr <= ReadAddr;  -- Store Previous Read Addrss
        Read_Reset    <= FALSE;  -- Finished reading 
        Track_vld     <= FALSE;   -- Not valid track
        ReadTotal     := 0;       -- Reset track totals
        NumReadTracks <= 0;
        PrimaryVertex <= TO_UNSIGNED(0,8);
      END IF;

      Output( i )            <= OutTrack;
      Output( i ).PV         <= PrimaryVertex;
      Output( i ).DataValid  <= Track_vld;
      Output( i ).FrameValid <= Track_vld;

      ReadAddrOut( i ) <= ReadAddr;
      WriteAddrOut( i ) <= WriteAddr;
    
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