 
 /*------------------------------------------------------------------------
    File        : PMDReporter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mabbott
    Created     : Thu Oct 31 21:26:38 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.Reporter.AbstractXMLReporter.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Reporter.PMDReporter INHERITS AbstractXMLReporter:  
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	CONSTRUCTOR PUBLIC PMDReporter ( INPUT cFileName AS CHARACTER ):
        SUPER (cFileName).
        
        ASSIGN RootElement = "pmd-cpd".
        
    END CONSTRUCTOR.

	DESTRUCTOR PUBLIC PMDReporter ( ):

	END DESTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL WriteBlock( INPUT pcFileNameOne AS CHARACTER, INPUT piStartLineOne AS INTEGER, INPUT piEndLineOne AS INTEGER, 
                                               INPUT pcFileNameTwo AS CHARACTER, INPUT piStartLineTwo AS INTEGER, INPUT piEndLineTwo AS INTEGER,
                                               INPUT pcCodeBlock   AS CHARACTER):
                        
        /* Attributes: lines, tokens */
        SaxWriter:START-ELEMENT ("duplication").
        
        /* Attributes: path, line */
        SaxWriter:WRITE-EMPTY-ELEMENT("file").
        SaxWriter:INSERT-ATTRIBUTE("path", pcFileNameOne).
        SaxWriter:INSERT-ATTRIBUTE("line", STRING(piStartLineOne)).
        
        
        /* Attributes: path, line */
        SaxWriter:WRITE-EMPTY-ELEMENT("file").
        SaxWriter:INSERT-ATTRIBUTE("path", pcFileNameTwo).
        SaxWriter:INSERT-ATTRIBUTE("line", STRING(piStartLineTwo)).
        
        SaxWriter:START-ELEMENT("codefragment").
        SaxWriter:WRITE-CHARACTERS(pcCodeBlock).
        SaxWriter:END-ELEMENT("codefragment").
        
        SaxWriter:END-ELEMENT("duplication").

    END METHOD.    

END CLASS.