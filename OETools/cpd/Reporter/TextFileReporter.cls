 
 /*------------------------------------------------------------------------
    File        : TextFileReporter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mark Abbott
    Created     : Thu Oct 31 17:41:58 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.Reporter.AbstractReporter.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Reporter.TextFileReporter INHERITS AbstractReporter: 
    
    /* Stream used to save report through */
    DEFINE STREAM sOutput.
    
    /* File name where report will be stored */
	DEFINE PUBLIC PROPERTY FileName AS CHARACTER NO-UNDO 
	GET.
	SET. 

	/*------------------------------------------------------------------------------
	 Purpose: Default Class Constructor
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC TextFileReporter ( INPUT cFileName AS CHARACTER ):
		SUPER ().
		
		ASSIGN FileName = cFileName.
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Initialise output document
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Initialise(  ):
        
        OUTPUT STREAM sOutput TO VALUE(FileName).

    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose: Shutdown output document
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC OVERRIDE LOGICAL Shutdown(  ):
		
        OUTPUT STREAM sOutput CLOSE.
        
	END METHOD.    

    /*------------------------------------------------------------------------------
     Purpose: Write code block to report document
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL WriteBlock( INPUT pcFileNameOne AS CHARACTER, INPUT piStartLineOne AS INTEGER, INPUT piEndLineOne AS INTEGER, 
                                               INPUT pcFileNameTwo AS CHARACTER, INPUT piStartLineTwo AS INTEGER, INPUT piEndLineTwo AS INTEGER,
                                               INPUT pcCodeBlock   AS CHARACTER):
        
        PUT STREAM sOutput UNFORMATTED "File: " pcFileNameOne
                        " Lines: " piStartLineOne "-" piEndLineOne SKIP
                        "File: " pcFileNameTwo
                        " Lines: " piStartLineTwo "-" piEndLineTwo SKIP
                        pcCodeBlock SKIP(3).

    END METHOD.    
    

END CLASS.