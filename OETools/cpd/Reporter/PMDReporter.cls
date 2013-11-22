 
 /*------------------------------------------------------------------------
    File        : PMDReporter
    Purpose     : Reports in PMD format (xml)
    Syntax      : 
    Description : 
    Author(s)   : Mark Abbott
    Created     : Thu Oct 31 21:26:38 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.Reporter.AbstractXMLReporter.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Reporter.PMDReporter INHERITS AbstractXMLReporter:  
    
	/*------------------------------------------------------------------------------
	 Purpose: Default class contrstructor
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC PMDReporter ( INPUT cFileName AS CHARACTER ):
        SUPER (cFileName).
        
        /* Set root element to PMD-CPD standard */
        ASSIGN RootElement = "pmd-cpd".
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Write fragments and linked files to report document in PMD format
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL WriteReport(INPUT DATASET dsFragment, INPUT DATASET dsFragmentFile):
        
        /* Loop through Fragments and all files attached to this Fragment */
        FOR EACH ttFragment NO-LOCK,            
            EACH ttFragmentFile NO-LOCK
           WHERE ttFragmentFile.FragmentID = ttFragment.FragmentID
           BREAK BY ttFragmentFile.FragmentID 
                 BY ttFragmentFile.FileName 
                 BY ttFragmentFile.StartLine 
                 BY ttFragmentFile.EndLine:
                     
            /* Write attributes on "duplication" element */
            IF FIRST-OF(ttFragmentFile.FragmentID) THEN
            DO:
                /* Attributes: lines, tokens */
                SaxWriter:START-ELEMENT ("duplication").
                SaxWriter:INSERT-ATTRIBUTE("lines", STRING((ttFragmentFile.EndLine - ttFragmentFile.StartLine) + 1)).
            END.
            
            /* Attributes: path, line */
            SaxWriter:WRITE-EMPTY-ELEMENT("file").
            SaxWriter:INSERT-ATTRIBUTE("path", ttFragmentFile.FileName).
            SaxWriter:INSERT-ATTRIBUTE("line", STRING(ttFragmentFile.StartLine)).
            
            /* Write data at end of list of files */
            IF LAST-OF(ttFragmentFile.FragmentID) THEN
            DO:
                /* Write out code */
                SaxWriter:START-ELEMENT("codefragment").
                SaxWriter:WRITE-CHARACTERS(ttFragment.Data).
                SaxWriter:END-ELEMENT("codefragment").
    
                /* End duplication element */            
                SaxWriter:END-ELEMENT("duplication").
            END.
        END.
        
    END METHOD.

END CLASS.