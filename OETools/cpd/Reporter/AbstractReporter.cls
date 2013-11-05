 
 /*------------------------------------------------------------------------
    File        : AbstractReporter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mark Abbott
    Created     : Thu Oct 31 17:41:22 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Reporter.AbstractReporter:  
    
    /*------------------------------------------------------------------------------
     Purpose: Default class contrstructor
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC AbstractReporter (  ):
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Initialises report document
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL Initialise(  ):
        
        RETURN FALSE.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Shuts down report document
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL Shutdown(  ):
        
        RETURN FALSE.
        
    END METHOD.    

	/*------------------------------------------------------------------------------
	 Purpose: Writes a single code block to the report document
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LOGICAL WriteBlock( INPUT pcFileNameOne AS CHARACTER, INPUT piStartLineOne AS INTEGER, INPUT piEndLineOne AS INTEGER, 
	                                  INPUT pcFileNameTwo AS CHARACTER, INPUT piStartLineTwo AS INTEGER, INPUT piEndLineTwo AS INTEGER,
	                                  INPUT pcCodeBlock   AS CHARACTER):
		
		RETURN FALSE.

	END METHOD.

END CLASS.