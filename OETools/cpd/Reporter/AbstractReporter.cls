 
 /*------------------------------------------------------------------------
    File        : AbstractReporter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mabbott
    Created     : Thu Oct 31 17:41:22 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Reporter.AbstractReporter:  
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC AbstractReporter (  ):
        SUPER ().
        
    END CONSTRUCTOR.

    DESTRUCTOR PUBLIC AbstractReporter ( ):

    END DESTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL Initialise(  ):
        
        RETURN FALSE.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL Shutdown(  ):
        
        RETURN FALSE.
        
    END METHOD.    

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LOGICAL WriteBlock( INPUT FileNameOne AS CHARACTER, INPUT StartLineOne AS INTEGER, INPUT EndLineOne AS INTEGER, 
	                                  INPUT FileNameTwo AS CHARACTER, INPUT StartLineTwo AS INTEGER, INPUT EndLineTwo AS INTEGER,
	                                  INPUT CodeBlock   AS CHARACTER):
		
		RETURN FALSE.

	END METHOD.

END CLASS.