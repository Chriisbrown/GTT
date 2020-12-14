-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE std.textio.ALL;
-- -------------------------------------------------------------------------


PACKAGE FunkyMiniBus IS

-- -------------------------------------------------------------------------
  TYPE tFMBusInfo IS RECORD
    Name          : STRING( 1 TO 12 );
    Size          : INTEGER;
    Width         : INTEGER;
    ChainPosition : INTEGER;
  END RECORD;

  TYPE tStdLogicInfoSpace IS ARRAY( NATURAL RANGE <> ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  TYPE tFMBusState IS( Ignore , Data , ReadData , WriteData , Lock , Unlock , Reset , ERROR );

  TYPE tFMBusLink IS RECORD
    Data        : STD_LOGIC;
    Instruction : tFMBusState;
    Info        : tFMBusInfo;
  END RECORD;

  TYPE tFMBus         IS ARRAY( INTEGER RANGE <> ) OF tFMBusLink;
  SUBTYPE tDummyFMBus IS tFMBus( INTEGER'LOW TO INTEGER'LOW );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  CONSTANT DoRuntimeAsserts : BOOLEAN := FALSE
-- pragma synthesis_off
  OR TRUE
-- pragma synthesis_on
;
-- -------------------------------------------------------------------------

-- FUNCTION CreateFMBusInfo( Name : STRING ; Size : INTEGER ; Width : INTEGER ; PrecedingInfo : tFMBusInfo ) RETURN tFMBusInfo;
  FUNCTION ToStdLogicVector( FMBus : tFMBus ) RETURN tStdLogicInfoSpace;
  FUNCTION Strip( lStr             : STRING ) RETURN STRING;

  FILE FunkyMiniBusAddressTable    : TEXT OPEN write_mode IS "FunkyMiniBusAddressTable.txt";

END PACKAGE FunkyMiniBus;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
PACKAGE BODY FunkyMiniBus IS

-- FUNCTION CreateFMBusInfo( Name : STRING ; Size : INTEGER ; Width : INTEGER ; PrecedingInfo : tFMBusInfo ) RETURN tFMBusInfo IS
-- VARIABLE lInfo : tFMBusInfo := ( ( OTHERS => CHARACTER'VAL( 0 ) ) , 0 , 0 , 0 );
-- BEGIN
-- ASSERT( Size < 2 ** 24 ) REPORT( "Total endpoint size must be less than 2^24 bits. Module '" & Strip( Name ) & "' does not comply." ) SEVERITY FAILURE;
-- ASSERT( Width < 2 ** 8 ) REPORT( "Endpoint width must be less than 2^8 bits. Module '" & Strip( Name ) & "' does not comply." ) SEVERITY FAILURE;

-- lInfo.Name( Name'RANGE ) := Name;
-- lInfo.Size := Size;
-- lInfo.Width := Width;
-- lInfo.ChainPosition := PrecedingInfo.ChainPosition + 1;
-- RETURN lInfo;
-- END FUNCTION CreateFMBusInfo;


  FUNCTION ToStdLogicVector( FMBus : tFMBus ) RETURN tStdLogicInfoSpace IS
    VARIABLE StdLogicName          : STD_LOGIC_VECTOR( 95 DOWNTO 0 )                   := ( OTHERS => '0' );
    VARIABLE lInfoSpace            : tStdLogicInfoSpace( 0 TO( 4 * FMBus'LENGTH ) -1 ) := ( OTHERS => ( OTHERS => '0' ) );
  BEGIN

    FOR j IN FMBus'RANGE LOOP
-- -------------------------------------------------------------------------
-- String BusName to std logic vector
      FOR i IN FMBus( j ) .Info .Name'RANGE LOOP
        StdLogicName( ( i * 8 ) - 1 DOWNTO( i - 1 ) * 8 ) := STD_LOGIC_VECTOR( TO_UNSIGNED( CHARACTER'pos( FMBus( j ) .Info .Name( i ) ) , 8 ) );
      END LOOP;
-- -------------------------------------------------------------------------
-- Add the info from the current module
      lInfoSpace( ( 4 * j ) + 0 )( 23 DOWNTO 0 )  := STD_LOGIC_VECTOR( TO_UNSIGNED( FMBus( j ) .Info.Size , 24 ) );
      lInfoSpace( ( 4 * j ) + 0 )( 31 DOWNTO 24 ) := STD_LOGIC_VECTOR( TO_UNSIGNED( FMBus( j ) .Info.Width , 8 ) );
      FOR i IN 1 TO 3 LOOP
        lInfoSpace( ( 4 * j ) + i ) := StdLogicName( ( i * 32 ) - 1 DOWNTO( i - 1 ) * 32 );
      END LOOP;
-- -------------------------------------------------------------------------
    END LOOP;

    RETURN lInfoSpace;
  END FUNCTION ToStdLogicVector;


  FUNCTION Strip( lStr : STRING ) RETURN STRING IS
    VARIABLE j         : INTEGER := 0;
  BEGIN
    FOR i IN lStr'RANGE LOOP
      IF lStr( i ) = CHARACTER'val( 0 ) THEN
        EXIT;
      END IF;
      j := j + 1;
    END LOOP;

    RETURN lStr( 1 TO j );
  END FUNCTION Strip;

END PACKAGE BODY FunkyMiniBus;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.FunkyMiniBus.ALL;

ENTITY FMBusRamDecoder IS
  GENERIC(
    BusName : STRING := STRING' ( "TEST" )
  );
  PORT(
    BusIn     : IN tFMBus;
    BusOut    : OUT tFMBus;
    BusClk    : IN STD_LOGIC  := '0';
    ClkOut    : OUT STD_LOGIC := '0';
    AddrOut   : OUT STD_LOGIC_VECTOR;
    DataOut   : OUT STD_LOGIC_VECTOR;
    DataValid : OUT STD_LOGIC := '0';
    DataIn    : IN STD_LOGIC_VECTOR
  );
END ENTITY FMBusRamDecoder;

ARCHITECTURE rtl OF FMBusRamDecoder IS
  SIGNAL LinkIn , LinkOut : tFMBusLink                                 := ( '0' , Ignore , ( ( OTHERS => CHARACTER'VAL( 0 ) ) , 0 , 0 , 0 ) );
  CONSTANT DataWidth      : INTEGER                                    := DataOut'LENGTH;
  CONSTANT WordCount      : INTEGER                                    := 2 ** AddrOut'LENGTH;

  SIGNAL WordCounter      : INTEGER RANGE 0 TO WordCount               := 0;
  SIGNAL BitCounter       : INTEGER RANGE 0 TO DataWidth - 1           := 0;
--attribute use_dsp48 : string;
--attribute use_dsp48 of WordCounter : variable is "yes";
--attribute use_dsp48 of BitCounter : variable is "yes";

  SIGNAL DataReg          : STD_LOGIC_VECTOR( DataWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL State            : tFMBusState                                := Lock;
BEGIN

  LinkIn                               <= BusIn( BusIn'LOW );
  BusOut( BusOut'LOW )                 <= LinkOut;

  ClkOut                               <= BusClk;
-- LinkOut.Info <= CreateFMBusInfo( BusName , WordCount * DataWidth , DataWidth , LinkIn.Info );
    LinkOut.Info.Name( BusName'RANGE ) <= BusName;
    LinkOut.Info.Size                  <= WordCount * DataWidth;
    LinkOut.Info.Width                 <= DataWidth;

-- Check that the infospace is consistenet with the Bus itself
  G0 : IF DoRuntimeAsserts GENERATE
    LinkOut.Info.ChainPosition <= LinkIn.Info.ChainPosition + 1;

    ConsistencyCheck         : PROCESS( BusClk )
      VARIABLE uninitialized : BOOLEAN := TRUE;
    BEGIN
      IF uninitialized AND RISING_EDGE( BusClk ) THEN
        ASSERT( LinkIn.Info.ChainPosition = BusOut'LOW ) REPORT( "Bus location " & INTEGER'IMAGE( LinkIn.Info.ChainPosition ) & " of module '" & Strip( BusName ) & "' does not match infospace ID " & INTEGER'IMAGE( BusOut'LOW ) ) SEVERITY FAILURE;
        ASSERT( WordCount * DataWidth < 2 ** 24 ) REPORT( "Total endpoint size must be less than 2^24 bits. Module '" & Strip( BusName ) & "' does not comply." ) SEVERITY FAILURE;
        ASSERT( DataWidth < 2 ** 8 ) REPORT( "Endpoint width must be less than 2^8 bits. Module '" & Strip( BusName ) & "' does not comply." ) SEVERITY FAILURE;
        ASSERT( Strip( BusName ) 'LENGTH <= 12 ) REPORT( "Endpoint Name must be a maximum of 12 characters. Module '" & Strip( BusName ) & "' does not comply." ) SEVERITY FAILURE;
        uninitialized := FALSE;
      END IF;
    END PROCESS;
  END GENERATE G0;


  prc : PROCESS( BusClk )
  BEGIN
    IF RISING_EDGE( BusClk ) THEN

-- Unless we say otherwise , remove the data out and tell subsequent modules that it is an invalid bit
      LinkOut.Data        <= '0';
      LinkOut.Instruction <= Ignore;

-- Don'tData access the RAM unless we explicitly say so
      DataValid           <= '0';

      CASE State IS
-- -------------------------------------------------------------------------
        WHEN ReadData =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN Data =>

              LinkOut.Data                      <= DataReg( 0 );
              LinkOut.Instruction               <= Data;
              DataReg( DataWidth - 1 DOWNTO 0 ) <= '0' & DataReg( DataWidth - 1 DOWNTO 1 );

              IF BitCounter = 0 THEN
                WordCounter <= WordCounter + 1;
              END IF;

              IF BitCounter = DataWidth - 1 THEN
                DataReg    <= DataIn;
                BitCounter <= 0;

                IF WordCounter = WordCount THEN
                  State <= Unlock;
                END IF;
              ELSE
                BitCounter <= BitCounter + 1;
              END IF;
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore =>
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
            WHEN Unlock | ReadData | WriteData | Lock => -- ERROR!
              State               <= Lock;
              LinkOut.Instruction <= ERROR;
-- -------------------------------------------------------------------------
            WHEN Reset =>
              State               <= Lock;
              LinkOut.Instruction <= Reset;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN WriteData =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN Data =>
              DataReg( DataWidth - 1 DOWNTO 0 ) <= LinkIn.Data & DataReg( DataWidth - 1 DOWNTO 1 );

              IF BitCounter = DataWidth - 1 THEN
                DataValid   <= '1';
                BitCounter  <= 0;
                WordCounter <= WordCounter + 1;
                IF WordCounter = WordCount - 1 THEN
                  State <= Unlock;
                END IF;
              ELSE
                BitCounter <= BitCounter + 1;
              END IF;
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore =>
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
            WHEN Unlock | ReadData | WriteData | Lock => -- ERROR!
              State               <= Lock;
              LinkOut.Instruction <= ERROR;
-- -------------------------------------------------------------------------
            WHEN Reset =>
              State               <= Lock;
              LinkOut.Instruction <= Reset;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN Lock =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN Unlock => -- We are locked , this unlock is for us
              State <= Unlock;
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore | Data | ReadData | WriteData | Lock | Reset => -- We are locked - just pass it on
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN Unlock =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore | Data | Unlock => -- If the data bit is valid or null , then just pass it on. If we are unlocked , then another unlock instruction must be for the next block in the chain
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
            WHEN ReadData | WriteData | Lock => -- Else , this is an instruction for us!
              State       <= LinkIn.Instruction;
              DataReg     <= DataIn;
              WordCounter <= 0;
              BitCounter  <= 0;
-- -------------------------------------------------------------------------
            WHEN Reset =>
              State               <= Lock;
              LinkOut.Instruction <= Reset;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN Ignore | Data | Reset | ERROR => -- Should never end up in these states
          NULL;
      END CASE;

      AddrOut <= STD_LOGIC_VECTOR( TO_UNSIGNED( WordCounter , AddrOut'LENGTH ) );

    END IF;
  END PROCESS;

  DataOut <= DataReg;

END ARCHITECTURE rtl;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.FunkyMiniBus.ALL;

ENTITY FMBusRegDecoder IS
  GENERIC(
    BusName : STRING := STRING' ( "TEST" )
  );
  PORT(
    BusIn     : IN tFMBus;
    BusOut    : OUT tFMBus;
    BusClk    : IN STD_LOGIC  := '0';
    ClkOut    : OUT STD_LOGIC := '0';
    DataOut   : OUT STD_LOGIC_VECTOR;
    DataValid : OUT STD_LOGIC := '0';
    DataIn    : IN STD_LOGIC_VECTOR
  );
END ENTITY FMBusRegDecoder;

ARCHITECTURE rtl OF FMBusRegDecoder IS
  SIGNAL LinkIn , LinkOut : tFMBusLink                                 := ( '0' , Ignore , ( ( OTHERS => CHARACTER'VAL( 0 ) ) , 0 , 0 , 0 ) );
  CONSTANT DataWidth      : INTEGER                                    := DataOut'LENGTH;

  SIGNAL BitCounter       : INTEGER RANGE 0 TO DataWidth - 1           := 0;
--attribute use_dsp48 : string;
--attribute use_dsp48 of BitCounter : SIGNAL is "yes";
  SIGNAL DataReg          : STD_LOGIC_VECTOR( DataWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL State            : tFMBusState                                := Lock;

BEGIN

  LinkIn                               <= BusIn( BusIn'LOW );
  BusOut( BusOut'LOW )                 <= LinkOut;

  ClkOut                               <= BusClk;
-- LinkOut.Info <= CreateFMBusInfo( BusName , DataWidth , DataWidth , LinkIn.Info );

    LinkOut.Info.Name( BusName'RANGE ) <= BusName;
    LinkOut.Info.Size                  <= DataWidth;
    LinkOut.Info.Width                 <= DataWidth;

-- Check that the infospace is consistenet with the Bus itself
  G0 : IF DoRuntimeAsserts GENERATE
    LinkOut.Info.ChainPosition <= LinkIn.Info.ChainPosition + 1;

    ConsistencyCheck         : PROCESS( BusClk )
      VARIABLE uninitialized : BOOLEAN := TRUE;
    BEGIN
      IF uninitialized AND RISING_EDGE( BusClk ) THEN
        ASSERT( LinkIn.Info.ChainPosition = BusOut'LOW ) REPORT( "Bus location " & INTEGER'IMAGE( LinkIn.Info.ChainPosition ) & " of module '" & Strip( BusName ) & "' does not match infospace ID " & INTEGER'IMAGE( BusOut'LOW ) ) SEVERITY FAILURE;
        ASSERT( DataWidth < 2 ** 8 ) REPORT( "Endpoint width must be less than 2^8 bits. Module '" & Strip( BusName ) & "' does not comply." ) SEVERITY FAILURE;
        ASSERT( Strip( BusName ) 'LENGTH <= 12 ) REPORT( "Endpoint Name must be a maximum of 12 characters. Module '" & Strip( BusName ) & "' does not comply." ) SEVERITY FAILURE;
        uninitialized := FALSE;
      END IF;
    END PROCESS;
  END GENERATE G0;

  prc : PROCESS( BusClk )
  BEGIN
    IF RISING_EDGE( BusClk ) THEN

-- Unless we say otherwise , remove the data out and tell subsequent modules that it is an invalid bit
      LinkOut.Data        <= '0';
      LinkOut.Instruction <= Ignore;

-- Don'tData access the REG unless we explicitly say so
      DataValid           <= '0';

      CASE State IS
-- -------------------------------------------------------------------------
        WHEN ReadData =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN Data =>
              LinkOut.Data                      <= DataReg( 0 );
              LinkOut.Instruction               <= Data;
              DataReg( DataWidth - 1 DOWNTO 0 ) <= '0' & DataReg( DataWidth - 1 DOWNTO 1 );

              IF BitCounter = DataWidth - 1 THEN
                State <= Unlock;
              ELSE
                BitCounter <= BitCounter + 1;
              END IF;
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore =>
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
            WHEN Unlock | ReadData | WriteData | Lock => -- ERROR!
              State               <= Lock;
              LinkOut.Instruction <= ERROR;
-- -------------------------------------------------------------------------
            WHEN Reset =>
              State               <= Lock;
              LinkOut.Instruction <= Reset;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN WriteData =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN Data =>
              DataReg( DataWidth - 1 DOWNTO 0 ) <= LinkIn.Data & DataReg( DataWidth - 1 DOWNTO 1 );

              IF BitCounter = DataWidth - 1 THEN
                State     <= Unlock;
                DataValid <= '1';
              ELSE
                BitCounter <= BitCounter + 1;
              END IF;
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore =>
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
            WHEN Unlock | ReadData | WriteData | Lock => -- ERROR!
              State               <= Lock;
              LinkOut.Instruction <= ERROR;
-- -------------------------------------------------------------------------
            WHEN Reset =>
              State               <= Lock;
              LinkOut.Instruction <= Reset;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN Lock =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN Unlock => -- We are locked , this unlock is for us
              State <= Unlock;
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore | Data | ReadData | WriteData | Lock | Reset => -- We are locked - just pass it on
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN Unlock =>
          CASE LinkIn.Instruction IS
-- -------------------------------------------------------------------------
            WHEN ERROR | Ignore | Data | Unlock => -- If the data bit is valid or null , then just pass it on. If we are unlocked , then another unlock instruction must be for the next block in the chain
              LinkOut.Data        <= LinkIn.Data;
              LinkOut.Instruction <= LinkIn.Instruction;
-- -------------------------------------------------------------------------
            WHEN ReadData | WriteData | Lock => -- Else , this is an instruction for us!
              State      <= LinkIn.Instruction;
              DataReg    <= DataIn;
              BitCounter <= 0;
-- -------------------------------------------------------------------------
            WHEN Reset =>
              State               <= Lock;
              LinkOut.Instruction <= Reset;
-- -------------------------------------------------------------------------
          END CASE;
-- -------------------------------------------------------------------------
        WHEN Ignore | Data | Reset | ERROR => -- Should never end up in these states
          NULL;
      END CASE;

    END IF;
  END PROCESS;

  DataOut <= DataReg;


END ARCHITECTURE rtl;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.FunkyMiniBus.ALL;

USE std.textio.ALL;

ENTITY FMBusMaster IS
  GENERIC(
    MaxInfoSpaceSize : INTEGER := 512
  );
  PORT(
    Clk              : IN STD_LOGIC;
    BusIn            : OUT tFMBus;
    BusOut           : IN tFMBus;
    BusClk           : OUT STD_LOGIC;
--Info : IN tFMBusInfoSpace;

    VectorInfoSpace  : OUT tStdLogicInfoSpace( 0 TO( 4 * MaxInfoSpaceSize ) -1 ) := ( OTHERS => ( OTHERS => '0' ) );
    InfoSpaceSize    : OUT INTEGER                                               := 0;
    Counters         : OUT tStdLogicInfoSpace( 0 TO 15 )                         := ( OTHERS => ( OTHERS => '0' ) );

    InstructionIn    : IN tFMBusState                                            := Ignore;
    InstructionValid : BOOLEAN                                                   := FALSE;

    DataIn           : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
    DataInValid      : IN BOOLEAN := FALSE;

    DataOut          : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
    DataOutPop       : IN BOOLEAN  := FALSE;

    Ready            : OUT BOOLEAN := TRUE;
    Done             : OUT BOOLEAN := TRUE
  );
END ENTITY FMBusMaster;

ARCHITECTURE rtl OF FMBusMaster IS

  SIGNAL BusStart , BusEnd                : tFMBusLink; --                                       := NullFMBusLink;

  SIGNAL lStartCounters , lEndCounters    : tStdLogicInfoSpace( 0 TO 7 )                          := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL lVectorInfoSpace                 : tStdLogicInfoSpace( 0 TO( 4 * MaxInfoSpaceSize ) -1 ) := ( OTHERS => ( OTHERS => '0' ) );
  ATTRIBUTE rom_style                     : STRING;
  ATTRIBUTE rom_style OF lVectorInfoSpace : SIGNAL IS "block";

BEGIN

-- Turn the array of records into a set of bytes
  lVectorInfoSpace( 0 TO( 4 * BusOut'LENGTH ) -1 ) <= ToStdLogicVector( BusOut );
  VectorInfoSpace                                  <= lVectorInfoSpace;
  Counters( 0 TO 7 )                               <= lStartCounters;
  Counters( 8 TO 15 )                              <= lEndCounters;

-- The daisy chain
  BusIn( 0 )                                       <= BusStart;
  G1   : IF BusIn'HIGH > 0 GENERATE
    G2 : FOR i IN 1 TO BusIn'HIGH GENERATE
      BusIn( i ) <= BusOut( i - 1 );
    END GENERATE G2;
  END GENERATE G1;
  BusEnd <= BusOut( BusOut'HIGH );

-- Initialize the start of the bus
  BusClk <= Clk;

-- Check that the infospace is consistent with the bus itself
  G0 : IF DoRuntimeAsserts GENERATE
    BusStart.Info.ChainPosition <= 0;

    ConsistencyCheck         : PROCESS( Clk )
      VARIABLE uninitialized : BOOLEAN := TRUE;
      VARIABLE l             : LINE;
    BEGIN
      IF uninitialized AND RISING_EDGE( Clk ) THEN
        ASSERT( BusEnd.Info.ChainPosition = BusOut'LENGTH ) REPORT( STRING' ( "Config bus size " ) & INTEGER'IMAGE( BusOut'LENGTH ) & STRING' ( " does not match chain size " ) & INTEGER'IMAGE( BusEnd.Info.ChainPosition ) ) SEVERITY FAILURE;

        L1   : FOR i IN BusOut'RANGE LOOP
          L2 : FOR j IN BusOut'RANGE LOOP
            IF i /= j THEN
              ASSERT( BusOut( i ) .Info .Name /= BusOut( j ) .Info .Name ) REPORT( STRING' ( "Duplicate name label '" ) & Strip( BusOut( i ) .Info .Name ) & STRING' ( "' for FunkyMiniBus endpoints " ) & INTEGER'IMAGE( i ) & STRING' ( " & " ) & INTEGER'IMAGE( j ) ) SEVERITY FAILURE;
            END IF;
          END LOOP L2;
        END LOOP L1;

        L3 : FOR i IN BusOut'RANGE LOOP
          write( l , STRING' ( "'" ) );
          write( l , Strip( BusOut( i ) .Info .Name ) );
          write( l , STRING' ( "' : " ) );
          write( l , BusOut( i ) .Info .Size );
          write( l , STRING' ( " bits" ) );
          writeline( FunkyMiniBusAddressTable , l );
        END LOOP L3;

        uninitialized := FALSE;
      END IF;
    END PROCESS;
  END GENERATE;

-- Output the bus length
  InfoSpaceSize <= BusOut'LENGTH;

  prc : PROCESS( Clk )
  TYPE tFIFO IS ARRAY( 0 TO 511 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
  VARIABLE Fifo                           : tFIFO                           := ( OTHERS => ( OTHERS => '0' ) );
  VARIABLE FifoWrPtr , FifoRdPtr          : INTEGER RANGE 0 TO 511          := 0;

  VARIABLE DataInReg , DataOutReg         : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( OTHERS => '0' );
  VARIABLE DataInCounter , DataOutCounter : INTEGER RANGE 0 TO 32           := 0;

  ATTRIBUTE ram_style                     : STRING;
  ATTRIBUTE ram_style OF Fifo             : VARIABLE IS "block";

  BEGIN
    IF RISING_EDGE( Clk ) THEN

      lStartCounters( tFMBusState'POS( BusStart.Instruction ) ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( TO_INTEGER( UNSIGNED( lStartCounters( tFMBusState'POS( BusStart.Instruction ) ) ) ) + 1 , 32 ) );
      lEndCounters( tFMBusState'POS( BusEnd.Instruction ) )     <= STD_LOGIC_VECTOR( TO_UNSIGNED( TO_INTEGER( UNSIGNED( lEndCounters( tFMBusState'POS( BusEnd.Instruction ) ) ) ) + 1 , 32 ) );

      Ready                                                     <= TRUE;
      Done                                                      <= FALSE;
      BusStart.Data                                             <= '0';
      BusStart.Instruction                                      <= Ignore;

      IF DataOutPop THEN
        FifoRdPtr := ( FifoRdPtr + 1 ) MOD 512;
      END IF;
      DataOut <= Fifo( FifoRdPtr );

      IF InstructionValid THEN
        BusStart.Instruction <= InstructionIn;
        DataOutCounter := 31; -- Read Data
        FifoWrPtr      := 0;
        FifoRdPtr      := 0;
      ELSIF DataInValid THEN
        DataInReg     := DataIn;
        DataInCounter := 32; -- Write Data
      END IF;

      IF DataInCounter > 0 THEN
        Ready                <= FALSE;
        BusStart.Data        <= DataInReg( 0 );
        BusStart.Instruction <= Data;
        DataInReg     := '0' & DataInReg( 31 DOWNTO 1 );
        DataInCounter := DataInCounter - 1;

        IF DataInCounter = 0 THEN
          Done <= TRUE;
        END IF;
      END IF;

      IF BusEnd.Instruction = Data THEN -- Read Data
        DataOutReg := BusEnd.Data & DataOutReg( 31 DOWNTO 1 );

        IF DataOutCounter = 0 THEN
          Fifo( FifoWrPtr ) := DataOutReg;
          FifoWrPtr         := ( FifoWrPtr + 1 ) MOD 512;
          DataOutCounter    := 31;
        ELSE
          DataOutCounter := DataOutCounter - 1;
        END IF;

      END IF;

    END IF;
  END PROCESS;

END ARCHITECTURE rtl;
