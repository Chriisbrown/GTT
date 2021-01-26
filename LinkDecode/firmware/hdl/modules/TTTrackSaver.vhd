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
    clk                : IN STD_LOGIC; -- The algorithm clock
    TTTrackPipeIn       : IN TTTrack.ArrayTypes.VectorPipe;
    PrimaryVertexPipeIn : IN  Vertex.ArrayTypes.VectorPipe;
    TTTrackPipeOut      : OUT TTTrack.ArrayTypes.VectorPipe;
    ReadAddrOut         : OUT INTEGER_VECTOR(0 TO 17) := (OTHERS => 0);
    WriteAddrOut        : OUT INTEGER_VECTOR(0 TO 17) := (OTHERS => 0);
    FIFOOut             : OUT INTEGER_VECTOR(0 TO 17) := (OTHERS => 0)
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

  SIGNAL WriteTotal    : INTEGER_VECTOR(0 TO 1) := (OTHERS => 0);  --Total Tracks Written into FIFO
  SIGNAL NumReadTracks : INTEGER := 0;  --Total Track read out of FIFO
  SIGNAL Read_Reset    : BOOLEAN := FALSE; --Flag to initiate reading
  SIGNAL FIFOFull      : INTEGER := 0;
  

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

  
  BEGIN
    IF ( RISING_EDGE( clk ) ) THEN
      IF ( TTTrackPipeIn( 0 )( i ).FrameValid ) THEN
        frame_signal <= TRUE;  --Store Frame valid
        IF ( TTTrackPipeIn( 0 )( i ).DataValid ) THEN
          WriteAddr  <= ( WriteAddr + 1 ) MOD ram_depth;  --Increment Write Pointer If Track is Valid. wrap if > ram_depth
          WriteTotal( 0 ) <=  WriteTotal( 0 ) + 1;      -- Update Track Totals
        END IF;

      ELSIF NOT TTTrackPipeIn( 0 )( i ).FrameValid AND frame_signal THEN -- Check if end of tracks being read in
        WriteTotal( 1 )  <=  WriteTotal( 0 );
        WriteTotal( 0 )  <= 0;
        frame_signal <= FALSE;
      ELSE
        frame_signal <= FALSE;
      END IF;
        
      IF ( PrimaryVertexPipeIn( 0 )( 0 ).DataValid ) THEN   -- Wait for Primary Vertex valid
        PrimaryVertex <= PrimaryVertexPipeIn( 0 )( 0 ).Z0; -- Store PV
        NumReadTracks <= 0;     -- Reset Number of read tracks
        Read_Reset <= TRUE;     -- Start Reading
        Track_vld <= FALSE;

      ELSIF NumReadTracks < WriteTotal( 1 ) THEN  -- If Number of read tracks < total number stored tracks
        IF Read_Reset THEN  
          ReadAddr      <= ( ReadAddr + 1 ) MOD ram_depth; -- Increment Read pointer if reading wrap if > ram_depth
          NumReadTracks <= NumReadTracks + 1;              -- Update read totals
          Track_vld     <= True;                           -- Track is Valid
          PrimaryVertex <= PrimaryVertex;
        ELSE     
          Track_vld <= False;                   
        END IF;
        
      ELSE
        Read_Reset    <= FALSE;  -- Finished reading 
        Track_vld     <= FALSE;   -- Not valid track
      END IF;

      Output( i )            <= OutTrack;
      Output( i ).PV         <= PrimaryVertex;
      Output( i ).DataValid  <= Track_vld;
      Output( i ).FrameValid <= Track_vld;

      ReadAddrOut( i ) <= ReadAddr;
      WriteAddrOut( i ) <= WriteAddr;
      FIFOOut( i ) <= FIFOFull;

      --IF FIFOFull = 0 AND WriteAddr /= ReadAddr THEN
      --  ReadAddr <= WriteAddr; 
      --END IF;

      --IF reset='1' THEN
      --  ReadAddr <= 0;
      --  WriteAddr <= 0;
      --  FIFOFull <= 0;
      -- ReadTotal := 0;
      --  WriteTotal <= 0;
      --  NumReadTracks <= 0;
      --  Read_Reset <= FALSE;
      --  PrimaryVertex <= TO_UNSIGNED(0,8);
      --  frame_signal <= FALSE;
      --END IF;
    
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