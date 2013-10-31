 
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
    METHOD PUBLIC OVERRIDE LOGICAL WriteBlock( INPUT FileNameOne AS CHARACTER, INPUT StartLineOne AS INTEGER, INPUT EndLineOne AS INTEGER, 
                                               INPUT FileNameTwo AS CHARACTER, INPUT StartLineTwo AS INTEGER, INPUT EndLineTwo AS INTEGER,
                                               INPUT CodeBlock   AS CHARACTER):
                        
        /* Attributes: lines, tokens */
        SaxWriter:START-ELEMENT ("duplication").
        
        /* Attributes: path, line */
        SaxWriter:WRITE-EMPTY-ELEMENT("file").
        SaxWriter:INSERT-ATTRIBUTE("path", FileNameOne).
        SaxWriter:INSERT-ATTRIBUTE("line", STRING(StartLineOne)).
        
        
        /* Attributes: path, line */
        SaxWriter:WRITE-EMPTY-ELEMENT("file").
        SaxWriter:INSERT-ATTRIBUTE("path", FileNameTwo).
        SaxWriter:INSERT-ATTRIBUTE("line", STRING(StartLineTwo)).
        
        SaxWriter:START-ELEMENT("codefragment").
        SaxWriter:WRITE-CHARACTERS(CodeBlock).
        SaxWriter:END-ELEMENT("codefragment").
        
        SaxWriter:END-ELEMENT("duplication").

    END METHOD.    

END CLASS.