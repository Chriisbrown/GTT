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
  SIGNAl Temp_fvld : BOOLEAN := FALSE;
  SIGNAL PrimaryVertex : UNSIGNED( 7 DOWNTO 0 ) := "00000000" ;

  SIGNAL Temp_vld : BOOLEAN := FALSE;
  
  SIGNAL WriteTotal : INTEGER := 0;




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

  VARIABLE Reading : BOOLEAN := FALSE;
  VARIABLE ReadTracks : INTEGER := 0;
  
  VARIABLE ReadTotal : INTEGER := 0;

  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      TempTrack <= Input( i );

      IF( TempTrack.FrameValid) THEN
        IF( TempTrack .DataValid ) THEN
          WriteAddr( i ) <= (WriteAddr( i ) + 1 ) MOD 512;
          WriteTotal <= WriteTotal + 1;
        END IF;
      END IF;

      IF (  TempTrack.FrameValid AND NOT Input( i ) .FrameValid) THEN
        ReadTotal := WriteTotal;
        WriteTotal <= 0;
      END IF;
        
      IF (PrimaryVertexPipeIn( 0 )( 0 ).DataValid) THEN
        PrimaryVertex <= PrimaryVertexPipeIn( 0 )( 0 ).Z0;
        ReadTracks := 0;
        Reading := TRUE;
      END IF;

      
      IF ReadTracks < ReadTotal THEN
        IF Reading THEN
          ReadAddr( i ) <= (ReadAddr( i ) + 1)  MOD 512;
          ReadTracks := ReadTracks + 1;
          Temp_vld <= True;  
        ELSE
          ReadTracks := ReadTracks;
          Temp_vld <= False;  
        END IF;

      ELSE
        Reading := FALSE;
        Temp_vld <= FALSE;
        ReadTotal := 0;
        ReadTracks := 0;

      END IF;

      Output( i ) <= OutTrack;
      Output( i ).PV <= PrimaryVertex;
      Output( i ).DataValid <= Temp_vld;
      Output( i ).FrameValid <= Temp_vld;
     
      
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