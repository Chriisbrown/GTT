# RUFL: The Reusable Firmware Library

## projects/Common
Contains the reusable firmware itself.
There are components for many tasks, ranging from basic units like DataPipe and DataRam, to more complicated units such as BitonicSort and DistributionServer.
Using VHDL _libraries_ these components can be used for any user-defined data type, and for multiple types within one project.

The user must define a `package` for the data type, called `DataType`, defining a record type named `tData` with all of the fields of your type.
Examples can be found in:
`projects/VertexFinder/firmware/hdl/components`

Two boolean fields in `DataType` are expected by the components:
```
    DataValid    : BOOLEAN;
    FrameValid   : BOOLEAN;
```
FrameValid is generally held high during the Time Multiplexing frame, DataValid is held high only for 'valid' data.
When FrameValid and/or DataValid are low, most components will ignore them (e.g. they will not be written into a RAM).

Then the following functions must be defined (all, or a subset depending on which components are to be used):
```
  -- For sorting
  FUNCTION ">" ( Left , Right          : tData ) RETURN BOOLEAN;
  -- For using the RAM 
  FUNCTION ToStdLogicVector( aData     : tData ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;
  -- For the debugging
  FUNCTION WriteHeader RETURN STRING;
  FUNCTION WriteData( aData : tData ) RETURN STRING;
```

### RUFL and ipbb
To include RUFL firmware in a project built with ipbb, the syntax for the `.dep` file is, e.g.:
`src --vhdl2008 -c HGC-firmware:projects/Common -l ExampleLibrary ReuseableElements/PkgArrayTypes.vhd`

## VCC

## projects/Vertexing
Firmware for Vertex finding in the CMS Level 1 Trigger Phase II Upgrade, built using RUFL components.