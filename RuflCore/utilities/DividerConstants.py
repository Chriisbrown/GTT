for i in range( 32 ):
  for j in range( 16 ):

    k = ( 16 * i ) + j
 
    if k: print( "{0:6}, ".format( int( round( float(0xFFFFFF)/float(k*k) ) ) ) , end='' )
    else: print( "{0} , ".format( -1 ) , end='' )
    
  print( "" )
