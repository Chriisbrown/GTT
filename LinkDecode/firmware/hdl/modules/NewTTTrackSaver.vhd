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
    TTTrackPipeIn       : IN TTTrack.ArrayTypes.VectorPipe;
    PrimaryVertexPipeIn : IN  Vertex.ArrayTypes.VectorPipe;
    TTTrackPipeOut      : OUT TTTrack.ArrayTypes.VectorPipe;
    ReadAddrOut         : OUT INTEGER_VECTOR(0 TO 17) := (OTHERS => 0);
    WriteAddrOut        : OUT INTEGER_VECTOR(0 TO 17) := (OTHERS => 0)
  );
END TTTrackSaver;

ARCHITECTURE rtl OF TTTrackSaver IS
  
  SIGNAL   Output      : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  CONSTANT ram_depth   : INTEGER                              := RAMDepth; --Max number of tracks per FIFO, (18 FIFOs Total)

  SUBTYPE tAddress        IS INTEGER RANGE 0 TO ram_depth-1;
  TYPE tAddressArray      IS ARRAY( 0 TO 17 ) OF tAddress;

  SUBTYPE tAddressDelta   IS INTEGER RANGE -ram_depth TO ram_depth-1;
  TYPE tAddressDeltaArray IS ARRAY( 0 TO 17 ) OF tAddressDelta;

-- --------   

  SIGNAL Delta        : tAddressDeltaArray                  := ( OTHERS => 0 );
  SIGNAL WriteAddr    : tAddressArray                       := ( OTHERS => 0 );
  SIGNAL ReadAddr     : tAddressArray                       := ( OTHERS => 0 );


  PROCEDURE DeltaProc(signal ReadAddr     : in tAddress;
                      signal WriteAddr    : in tAddress;
                      signal Delta        : out tAddressDelta) IS
  BEGIN
    -- Calculate the distance between the read and write pointers (previously done in "RAM" module)      
    -- NEW: keep the delta working when either pointer wraps around
    -- NOTE: this method means that delta > 255 is not allowed, and incorrect behavior will occur
    -- TODO: add a flag monitoring the delta validity?

    IF ReadAddr < WriteAddr THEN -- if r < w
      IF ABS( ReadAddr - WriteAddr ) < ABS( ReadAddr - WriteAddr + ram_depth ) THEN -- if abs(r - w) < abs(r - w + 512)
        Delta <= ReadAddr - WriteAddr;
      ELSE
        Delta <= ReadAddr - WriteAddr + ram_depth;
      END IF;
    ELSE -- else (r >= w)
      IF ABS( ReadAddr - WriteAddr ) < ABS( ReadAddr - WriteAddr - ram_depth ) THEN
        Delta <= ReadAddr - WriteAddr;
      ELSE
        Delta <= ReadAddr - WriteAddr - ram_depth;
      END IF;
    END IF;

END PROCEDURE;

BEGIN 

g1 : FOR i IN 0 TO 17 GENERATE

  SIGNAL OutTrack      : TTTrack.DataType.tData := TTTrack.DataType.cNull;

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
    WriteAddr   => WriteAddr( i ),
    DataIn      => TTTrackPipeIn( 0 )( i ) ,                        
    WriteEnable => TTTrackPipeIn( 0 )( i ).DataValid ,
    ReadAddr    => ReadAddr( i ) ,
    DataOut     => OutTrack
  );

  PROCESS( clk )

  VARIABLE ReadTotal : INTEGER := 0;
  
  BEGIN
    IF ( RISING_EDGE( clk ) ) THEN
      IF ( TTTrackPipeIn( 0 )( i ).FrameValid ) THEN
        frame_signal      <= TRUE;  --Store Frame valid
        IF ( TTTrackPipeIn( 0 )( i ).DataValid ) THEN
          WriteAddr( i )  <= ( WriteAddr( i ) + 1 ) MOD ram_depth;  --Increment Write Pointer If Track is Valid. wrap if > ram_depth
          WriteTotal      <=  WriteTotal + 1;      -- Update Track Totals
        ELSE
          WriteTotal      <= WriteTotal;
          WriteAddr( i )  <= WriteAddr( i );
        END IF;
      ELSIF NOT TTTrackPipeIn( 0 )( i ).FrameValid AND frame_signal THEN -- Check if end of tracks being read in
        ReadTotal := WriteTotal;
        WriteTotal        <= 0;             -- Reset Track Totals
        WriteAddr( i )    <= WriteAddr( i );
        frame_signal      <= FALSE;
      ELSE
        ReadTotal := ReadTotal;
        WriteTotal        <= WriteTotal;
        WriteAddr( i )    <= WriteAddr( i );
        frame_signal      <= FALSE;
      END IF;

      DeltaProc(ReadAddr( i ),WriteAddr( i ),Delta( i ));
        
      IF ( PrimaryVertexPipeIn( 0 )( 0 ).DataValid ) THEN   -- Wait for Primary Vertex valid
        PrimaryVertex            <= PrimaryVertexPipeIn( 0 )( 0 ).Z0; -- Store PV
        Read_Reset               <= TRUE;     -- Start Reading
        ReadAddr( i )   <= ReadAddr( i );
        Track_vld                <= FALSE;

      ELSIF NumReadTracks < ReadTotal THEN  -- If Number of read tracks < total number stored tracks
        IF Read_Reset THEN  
          ReadAddr( i ) <= ( ReadAddr( i ) + 1 ) MOD ram_depth; -- Increment Read pointer if reading wrap if > ram_depth
          NumReadTracks          <= NumReadTracks + 1;
          Track_vld              <= True;                           -- Track is Valid
          PrimaryVertex          <= PrimaryVertex;
        ELSIF ReadTotal = 0 AND Delta( i ) /= 0 THEN
          ReadAddr( i ) <= WriteAddr( i );  
          NumReadTracks          <= NumReadTracks;     
          Track_vld              <= FALSE;                           
          PrimaryVertex          <= PrimaryVertex;
        ELSE     
          ReadAddr( i ) <= ReadAddr( i );
          NumReadTracks <= NumReadTracks;
          PrimaryVertex          <= PrimaryVertex;
          Track_vld              <= False;                   
        END IF;
        
      ELSE
        ReadAddr( i )   <= ReadAddr( i );  -- Store Previous Read Addrss
        Read_Reset               <= FALSE;  -- Finished reading 
        Track_vld                <= FALSE;   -- Not valid track
        ReadTotal     := 0;       -- Reset track totals
        NumReadTracks <= 0;
        PrimaryVertex            <= TO_UNSIGNED(0,8);
      END IF;

      Output( i )            <= OutTrack;
      Output( i ).PV         <= PrimaryVertex;
      Output( i ).DataValid  <= Track_vld;
      Output( i ).FrameValid <= Track_vld;

      ReadAddrOut ( i ) <= ReadAddr( i );
      WriteAddrOut( i ) <= WriteAddr( i ) ;
    
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