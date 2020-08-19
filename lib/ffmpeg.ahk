class FFMPEG {
    __New() {

    }
    setffmpegpath(ffmpegpath) {
        this.ffmpegpath := ffmpegpath
    }
    inputfile(inputfile) {
        this.inputfile := inputfile
    }
    run() {
        testing := this.inputfile
        StdOutStream( this.ffmpegpath " -y -i " this.inputfile " output.mp4", "maincall")
    }
}

StdOutStream( sCmd, Callback = "" ) {
  Static StrGet := "StrGet"
                                    
  DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
  DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )

  if(a_ptrSize=8){
    VarSetCapacity( STARTUPINFO, 104, 0  )
    NumPut( 68,         STARTUPINFO,  0 )
    NumPut( 0x100,      STARTUPINFO, 60 )
    NumPut( hPipeWrite, STARTUPINFO, 88 )
    NumPut( hPipeWrite, STARTUPINFO, 96 )
    VarSetCapacity( PROCESS_INFORMATION, 32 )
  }else{
    VarSetCapacity( STARTUPINFO, 68, 0  )
    NumPut( 68,         STARTUPINFO,  0 )
    NumPut( 0x100,      STARTUPINFO, 44 )
    NumPut( hPipeWrite, STARTUPINFO, 60 )
    NumPut( hPipeWrite, STARTUPINFO, 64 )
    VarSetCapacity( PROCESS_INFORMATION, 16 )
  }
  If ! DllCall( "CreateProcess", UInt,0, UInt,&sCmd, UInt,0, UInt,0
              , UInt,1, UInt,0x08000000, UInt,0, UInt,0
              , UInt,&STARTUPINFO, UInt,&PROCESS_INFORMATION ) 
   Return "" 
   , DllCall( "CloseHandle", UInt,hPipeWrite ) 
   , DllCall( "CloseHandle", UInt,hPipeRead )
   , DllCall( "SetLastError", Int,-1 )     

  hProcess := NumGet( PROCESS_INFORMATION, 0 )                 
  if(a_is64bitOS)
    hThread  := NumGet( PROCESS_INFORMATION, 8 )                      
  else
    hThread  := NumGet( PROCESS_INFORMATION, 4 )                      
  DllCall( "CloseHandle", UInt,hPipeWrite )

  AIC := ( SubStr( A_AhkVersion, 1, 3 ) = "1.0" )
  VarSetCapacity( Buffer, 4096, 0 ), nSz := 0 
  
  While DllCall( "ReadFile", UInt,hPipeRead, UInt,&Buffer, UInt,4094, UIntP,nSz, Int,0 ) {

   tOutput := ( AIC && NumPut( 0, Buffer, nSz, "Char" ) && VarSetCapacity( Buffer,-1 ) ) 
              ? Buffer : %StrGet%( &Buffer, nSz, "CP850" )

   Isfunc( Callback ) ? %Callback%( tOutput, A_Index ) : sOutput .= tOutput

  }                   
 
  DllCall( "GetExitCodeProcess", UInt,hProcess, UIntP,ExitCode )
  DllCall( "CloseHandle",  UInt,hProcess  )
  DllCall( "CloseHandle",  UInt,hThread   )
  DllCall( "CloseHandle",  UInt,hPipeRead )
  DllCall( "SetLastError", UInt,ExitCode  )

Return Isfunc( Callback ) ? %Callback%( "", 0 ) : sOutput      
}
maincall( data, n ) {
	FileAppend, %data%, %n%
  	if ! ( n ) {
    	Return
  	}
}