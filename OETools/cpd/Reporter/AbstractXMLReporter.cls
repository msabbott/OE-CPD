 
 /*------------------------------------------------------------------------
    File        : AbstractXMLReporter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mark Abbott
    Created     : Thu Oct 31 21:26:38 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.Reporter.AbstractReporter.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Reporter.AbstractXMLReporter INHERITS AbstractReporter:  
    
    DEFINE STREAM sOutput.
    
    DEFINE PUBLIC PROPERTY FileName AS CHARACTER NO-UNDO 
    GET.
    SET. 

	DEFINE PROTECTED PROPERTY SaxWriter AS HANDLE NO-UNDO 
	GET.
	SET. 
	
	DEFINE PROTECTED VARIABLE RootElement AS CHARACTER NO-UNDO INITIAL "report".
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	CONSTRUCTOR PUBLIC AbstractXMLReporter ( INPUT cFileName AS CHARACTER ):
        SUPER ().
        
        ASSIGN FileName = cFileName.
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Initialise(  ):
        
        CREATE SAX-WRITER SaxWriter.
        
        SaxWriter:SET-OUTPUT-DESTINATION ("FILE", FileName).
        SaxWriter:START-DOCUMENT().
        SaxWriter:START-ELEMENT(RootElement).

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Shutdown(  ):
        
        SaxWriter:END-ELEMENT(RootElement).
        SaxWriter:END-DOCUMENT().
        
    END METHOD.    

END CLASS.