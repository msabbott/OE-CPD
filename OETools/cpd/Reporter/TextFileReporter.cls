 
 /*------------------------------------------------------------------------
    File        : TextFileReporter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mabbott
    Created     : Thu Oct 31 17:41:58 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.Reporter.AbstractReporter.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Reporter.TextFileReporter INHERITS AbstractReporter: 
    
    DEFINE STREAM sOutput.
    
	DEFINE PUBLIC PROPERTY FileName AS CHARACTER NO-UNDO 
	GET.
	SET. 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC TextFileReporter ( INPUT cFileName AS CHARACTER ):
		SUPER ().
		
		ASSIGN FileName = cFileName.
		
	END CONSTRUCTOR.

	DESTRUCTOR PUBLIC TextFileReporter ( ):

	END DESTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Initialise(  ):
        
        OUTPUT STREAM sOutput TO VALUE(FileName).

    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC OVERRIDE LOGICAL Shutdown(  ):
		
        OUTPUT STREAM sOutput CLOSE.
        
	END METHOD.    

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL WriteBlock( INPUT FileNameOne AS CHARACTER, INPUT StartLineOne AS INTEGER, INPUT EndLineOne AS INTEGER, 
                                               INPUT FileNameTwo AS CHARACTER, INPUT StartLineTwo AS INTEGER, INPUT EndLineTwo AS INTEGER,
                                               INPUT CodeBlock   AS CHARACTER):
        
        PUT STREAM sOutput UNFORMATTED "File: " FileNameOne
                        " Lines: " StartLineOne "-" EndLineOne SKIP
                        "File: " FileNameTwo
                        " Lines: " StartLineTwo "-" EndLineTwo SKIP
                        CodeBlock SKIP(3).

    END METHOD.    
    

END CLASS.