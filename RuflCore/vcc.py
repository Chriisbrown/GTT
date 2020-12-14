#! /usr/bin/python2
#! /usr/bin/python3

from __future__ import print_function

import argparse
from os.path import isdir , isfile , join , abspath , dirname , basename , isabs , split , splitext
from os import getcwd , chdir
from sys import stderr , version , executable
from subprocess import call
from re import compile , match
 

gDebug = False


# ===============================================================================================================================
def ToForwardSlashes( aPath ):
  return str( aPath ).replace( "\\" , "/" )
# ===============================================================================================================================


# ===============================================================================================================================  
class VhdlFile:

  IncludePaths = [ getcwd() ]
  FileList = []
  LibraryList = []

  LibraryRe =   compile( r'\s*--\s*\.library\s+(\S+)\s*\Z' )
  IncludeInRe = compile( r'\s*--\s*\.include\s+(.+?)\s+in\s+(\S+)\s*\Z' )
  IncludeRe =   compile( r'\s*--\s*\.include\s+(.+)\s*\Z' )
  
  @classmethod 
  def addIncludePath( aClass , aPath ):
    lPath = abspath( aPath )
    if not isdir( lPath ): raise NotADirectoryError( "Requested include path '{0}' does not exist".format( lPath ) ) 
    aClass.IncludePaths.append( lPath ) 
    if gDebug: print ( "Adding include path: '{0}' -> {1}".format( aPath , lPath ) )

    
  def __init__( self , aFilename , aParent = None , aLibrary = None ):
    self.Filename = None
    self.Parent = aParent
    self.Library = aLibrary
    self.Import = not ( aLibrary is None )    
    self.Include = []
    
    # Absolute filename - ensure that file exists
    if isabs( aFilename ):
      if isfile( aFilename ): self.Filename = abspath( aFilename )
    else:    
      # Check whether file is in same directory as including file
      if aParent:
        lFilename = abspath( join( dirname( aParent.Filename ) , aFilename ) )
        if isfile( lFilename ): self.Filename = lFilename
        
      # Check the other include paths
      if self.Filename == None:
        for i in self.IncludePaths:
          lFilename = abspath( join( i , aFilename ) )
          if isfile( lFilename ): self.Filename = lFilename
        
    # Not an absolute path, a path local to the includer, or in any of the include paths - throw
    if self.Filename == None: raise Exception( "File '{0}' not found".format( aFilename ) )

    lCheck = self.RecursiveIncludeCheck()
    if lCheck: raise RecursionError( "Cyclic dependency detected:\n" + "\n -> ".join( lCheck ) ) 
      
    if gDebug: print ( "Adding VHDL file: '{0}' -> {1}".format( aFilename , lFilename ) )

    # Now parse the file
    with open( self.Filename , "r" ) as lFile:
      for lLine in lFile.readlines():
        
        lMatch = match( self.LibraryRe , lLine )
        if lMatch : 
          if self.Library: raise SyntaxError( "A file can specify precisely one library: '{0}' requested but already set to '{1}'".format( lMatch.group(1) , self.Library ) )
          else :
            self.Library = lMatch.group(1)
            if gDebug: print ( "  Set library to '{0}'".format( self.Library ) )

        # Any other regexes should be parsed here to avoid the "continue" below
        
        try:
          lMatch = match( self.IncludeInRe , lLine )
          if lMatch:
            if lMatch.group(2) == ".": self.Include.append( VhdlFile( lMatch.group(1) , self , self.Library ) )
            else :                     self.Include.append( VhdlFile( lMatch.group(1) , self , lMatch.group(2) ) )           
            continue # Don't try to match gIncludeRe if already matched IncludeInRe
            
          lMatch = match( self.IncludeRe , lLine )
          if lMatch:
            self.Include.append( VhdlFile( lMatch.group(1) , self ) )
        except Exception as e:
          raise Exception( "{0}\n  included in file '{1}'".format( e , self.Filename ) )
    
    if not self.Library: raise ImportError( "No library specified for file '{0}'".format(self.Filename) )

    if not self in self.FileList : self.FileList.append( self )
    if not self.Library in self.LibraryList : self.LibraryList.append( self.Library )
    
  def String( self , indent ):
    lStr = ""
    if indent: lStr = "\n" + (" "*indent*2)
    lStr += str( self.Filename ) + " => " + str( self.Library )
    if self.Import : lStr += "*"

    for i in self.Include: lStr += i.String( indent + 1 )
    return lStr

  def __str__( self ):
    return ("="*80) + "\n" + self.String( 0 ) + "\n" + ("="*80)

  def __eq__( self , other ):
    return ( self.Filename == other.Filename ) and ( self.Library == other.Library )

  def RecursiveIncludeCheck( self , aFilename = None , aDepth = 0 ):
    if aFilename:
      lFilename = aFilename
      if self.Filename == lFilename : return [ self.Filename ]
    else:
      lFilename = self.Filename
    
    if self.Parent:
      lRet = self.Parent.RecursiveIncludeCheck( lFilename )
      if lRet: lRet.append( self.Filename )
      return lRet
        
    return None
# ===============================================================================================================================


# ===============================================================================================================================
def VivadoTcl( aScript , aFile ):
  lPreamble = """
file mkdir {top}
# Cheekily making a folder for DebugFiles
file mkdir {top}/DebugFiles
create_project top {top} -part xc7vx690tffg1927-2 -force
if {{[lsearch [get_filesets] constrs_1] == -1}} {{create_fileset -constrset constrs_1}}
if {{[lsearch [get_filesets] sources_1] == -1}} {{create_fileset -srcset sources_1}}
"""

  lImport = """
# Import {src} into {lib}
file mkdir {cp}
add_files -norecurse -force -copy_to {cp} {src}
set_property FILE_TYPE {{VHDL 2008}} [get_files {nn}]
set_property library {lib} [get_files  {nn}]
file attribute {nn} -permissions 00444
"""
  
  lInclude = """
# Include {src} in {lib}
add_files -norecurse {src}
set_property FILE_TYPE {{VHDL 2008}} [get_files {src}]
set_property library {lib} [get_files  {src}]
"""

  path,ext = splitext( aScript )
  ImportScript = path + ".import" + ext
  ChecksScript = path + ".checks" + ext

  with open( aScript , "w" ) as lFile:
    lTopDir = ToForwardSlashes( abspath( join( dirname( aScript ) , "top" ) ) )
    lFile.write( lPreamble.format( top=lTopDir ) )
    lFile.write( 'source "{0}"\n'.format( ToForwardSlashes( ImportScript ) ) )
    lFile.write( 'source "{0}"\n'.format( ToForwardSlashes( ChecksScript ) ) )
    
  with open( ImportScript , "w" ) as lFile:    
    for lSrc in aFile.FileList: 
      lSrcFile  = ToForwardSlashes( lSrc.Filename )
      # Technically these are only used in "Import", not "Include", but VCC source-code looks cleaner this way
      lCopyPath = ToForwardSlashes( abspath( join( lTopDir , "top.srcs/sources_1/imports" , lSrc.Library ) ) )
      lNewName  = ToForwardSlashes( abspath( join( lCopyPath , basename( lSrcFile ) ) ) )

      if lSrc.Import: lTemplate = lImport
      else:           lTemplate = lInclude
    
      lFile.write( lTemplate.format( src=lSrcFile , lib=lSrc.Library , cp=lCopyPath , nn=lNewName ) )

  with open( ChecksScript , "w" ) as lFile:    
    lFile.write( 'puts "\\n\\n"\n' )
    lFile.write( '# Suppress the info that this method is the human-readable version\n' )
    lFile.write( 'set_msg_config -id "Vivado 12-3442" -suppress\n' )
    lFile.write( 'report_compile_order -missing_instances -used_in Synthesis\n' )
    lFile.write( 'puts "\\n\\n"\n' )
    lFile.write( '# Suppress the warning over positional arguments\n' )
    lFile.write( 'set_msg_config -id "HDL 9-1720" -suppress\n' )
    lFile.write( 'check_syntax\n' )

# ===============================================================================================================================


# ===============================================================================================================================
def ModelsimTcl( aScript , aFile ):

  lPreamble = """
# Cheekily making a folder for DebugFiles
file mkdir {top}/DebugFiles
file mkdir {top}/top.sim/sim_1/behav/modelsim/modelsim_lib/msim
cd {top}/top.sim/sim_1/behav/modelsim

vlib modelsim_lib/work
vlib modelsim_lib/msim
# project new {top} top
"""  

  lLibrary = """
vlib modelsim_lib/msim/{lib}
vmap {lib} modelsim_lib/msim/{lib}
"""

  lCompile = """
vcom -64 -2008 -work {lib} "{src}"
"""

  lRun = """
vsim -voptargs="+acc" {liblist} -lib xil_defaultlib {toplib}.top
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

force sim:/debugging/TimeStamp [clock format [clock second]]

if {{ ! [batch_mode] }} {{
  noview *
  view wave
  config wave -signalnamewidth 1
  add wave -dec sim:/debugging/SimulationClockCounter
  add wave -divider
}} 

"""
  
  
  with open( aScript , "w" ) as lFile:
    lTopDir = ToForwardSlashes( abspath( join( dirname( aScript ) , "top" ) ) )
    lFile.write( lPreamble.format( top=lTopDir ) )
    lFile.write( lLibrary.format( lib="xil_defaultlib" ) )
    
    lLibList = ""
    for lLib in aFile.LibraryList:
      lFile.write( lLibrary.format( lib=lLib ) )
      lLibList += " -L {0}".format( lLib )

    for lSrc in aFile.FileList: lFile.write( lCompile.format( src=ToForwardSlashes( lSrc.Filename) , lib=lSrc.Library ) )
    lFile.write( lRun.format( liblist=lLibList , toplib=aFile.Library ) )  
# ===============================================================================================================================


# ===============================================================================================================================
def GnuDfile( aScript , aFile ):
 
  aFileName = splitext( aScript )
  aFileName = aFileName[0] + ".d"
  with open( aFileName , "w" ) as lFile:
    lFile.write( ToForwardSlashes( aScript ) )
    lFile.write( ":" )
    for lSrc in aFile.FileList: 
      lFile.write( " \\\n{0}".format( ToForwardSlashes( lSrc.Filename ) ) )

    lFile.write( "\n" )
    for lSrc in aFile.FileList: 
      lFile.write( "\n{0}:\n".format( ToForwardSlashes( lSrc.Filename ) ) )

    lFile.write( "\n" )
# ===============================================================================================================================




# ===============================================================================================================================
# Parse the command-line arguments
parser = argparse.ArgumentParser( description="Parse VHDL files and analyse dependencies" )
parser.add_argument( "-d", action="store_true", help="Produce GNU .d file" )
parser.add_argument( "-v" , "--verbose", action="store_true", help="Increase output verbosity" )
parser.add_argument( "-I" , metavar="Include-path" , action="append" , help="An include-path" )
parser.add_argument( "-o" , "--output" , metavar="Output-file" , help="File to produce: options are 'vivado.tcl' or 'modelsim.tcl' (and eventally more). Paths are allowed." )
parser.add_argument( "--run" , nargs="?" , choices=["batch","interactive"] , const="interactive" , help="Run the generated script. Assumes 'interactive'." )

parser.add_argument( "VhdlFile" , metavar="VHDL-File" , help="The top-level VHDL file" )
args = parser.parse_args()

# Set the debugging level
gDebug = args.verbose

# Some debugging information
if gDebug: 
  print( version , "|" , executable )

# Add the include-paths
if not args.I is None:
  for i in args.I : 
    VhdlFile.addIncludePath( i )

# Parse the top-level VHDL file
try:
  TopFile = VhdlFile( args.VhdlFile )
except Exception as e:
  print( "ERROR:" , e , file=stderr )
  exit( 1 )
# ===============================================================================================================================


# ===============================================================================================================================
if not args.output:
  print( TopFile ) 
else:
  lScript = abspath( args.output )
  lScriptPath = split( lScript )

  lCwd = getcwd()
  chdir( lScriptPath[0] )
  
  try:
    if lScriptPath[1] == "vivado.tcl": 
      if args.d: GnuDfile( lScript , TopFile )
      VivadoTcl( lScript , TopFile )
      if args.run:
        lCommand = "vivado -source vivado.tcl"
        if args.run == "batch" : lCommand += " -mode batch"
        if gDebug: print( "Invoking '{0}'".format( lCommand ) )
        call( lCommand , shell=True )   
    elif lScriptPath[1] == "modelsim.tcl": 
      if args.d: GnuDfile( lScript , TopFile )
      ModelsimTcl( lScript , TopFile )
      if args.run:
        lCommand = "vsim -do modelsim.tcl"
        if args.run == "batch" : lCommand += " -batch"
        if gDebug: print( "Invoking '{0}'".format( lCommand ) )
        call( lCommand , shell=True )   
        
    # ... Process other script names ...
    else: 
      parser.print_help( stderr )
      raise Exception( "Value '{0}' not allowed for option '-o'/'--output'".format( lScriptPath[1] ) , file=stderr )
  
  except (KeyboardInterrupt, SystemExit):
    print( "Processing interrupted" , file=stderr )
  except Exception as e:
    print( "ERROR:" , e , file=stderr )
    exit( 1 )

  chdir( lCwd )    
    
# ===============================================================================================================================
