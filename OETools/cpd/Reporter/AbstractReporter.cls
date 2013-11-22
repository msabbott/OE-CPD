 
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
    
    /* Temp-table and Dataset definitions for Code Fragments */
    {OETools\cpd\Strategy\ttFragment.i PROTECTED}
    {OETools\cpd\Strategy\dsFragment.i PROTECTED}
    
    /* Temp-table and Dataset definitions for Files with Matching Code Fragments */
    {OETools\cpd\Strategy\ttFragmentFile.i PROTECTED}
    {OETools\cpd\Strategy\dsFragmentFile.i PROTECTED}
    
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
     Purpose: Write fragments and linked files to report document
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL WriteReport(INPUT DATASET dsFragment, INPUT DATASET dsFragmentFile):
        
        RETURN FALSE.

    END METHOD.
	
	

END CLASS.