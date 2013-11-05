 
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

    /* Filename for where the XML document should be saved */    
    DEFINE PUBLIC PROPERTY FileName AS CHARACTER NO-UNDO 
    GET.
    SET. 

    /* SaxWriter property used to write XML document */
	DEFINE PROTECTED PROPERTY SaxWriter AS HANDLE NO-UNDO 
	GET.
	SET. 
	
	/* Holds the root element for the XML document */
	DEFINE PROTECTED VARIABLE RootElement AS CHARACTER NO-UNDO INITIAL "report".
    
	/*------------------------------------------------------------------------------
	 Purpose: Default class contrstructor
	 Notes:
	------------------------------------------------------------------------------*/
		
	CONSTRUCTOR PUBLIC AbstractXMLReporter ( INPUT cFileName AS CHARACTER ):
        SUPER ().
        
        ASSIGN FileName = cFileName.
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Initialises XML document and creates root node
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Initialise(  ):
        
        CREATE SAX-WRITER SaxWriter.
        
        SaxWriter:SET-OUTPUT-DESTINATION ("FILE", FileName).
        SaxWriter:START-DOCUMENT().
        SaxWriter:START-ELEMENT(RootElement).

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Closes root node, and ends XML document
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Shutdown(  ):
        
        SaxWriter:END-ELEMENT(RootElement).
        SaxWriter:END-DOCUMENT().
        
    END METHOD.    

END CLASS.