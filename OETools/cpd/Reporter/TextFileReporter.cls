 
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

    /*------------------------------------------------------------------------------
     Purpose: Write fragments and linked files to report document
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL WriteReport(INPUT DATASET dsFragment, INPUT DATASET dsFragmentFile):
        
        FOR EACH ttFragment NO-LOCK
              BY ttFragment.FragmentID:
            
            /* Output Fragment header */
            PUT STREAM sOutput UNFORMATTED
                (IF ttFragment.FragmentID GT 1 THEN "****************************************************" ELSE "") SKIP
                "Fragment Number: " ttFragment.FragmentID SKIP.

            /* Output Files that match the fragment */                
            FOR EACH ttFragmentFile NO-LOCK
               WHERE ttFragmentFile.FragmentID = ttFragment.FragmentID
                  BY ttFragmentFile.FragmentID 
                  BY ttFragmentFile.FileName 
                  BY ttFragmentFile.StartLine 
                  BY ttFragmentFile.EndLine:
                      
                PUT STREAM sOutput UNFORMATTED
                    "File: " ttFragmentFile.FileName
                    " Lines: " ttFragmentFile.StartLine "-" ttFragmentFile.EndLine SKIP.                                          
                      
            END.
            
            /* Output Code */
            PUT STREAM sOutput UNFORMATTED
                SKIP
                ttFragment.Data
                SKIP.  
        END.
        
        RETURN TRUE.

    END METHOD.
    
        
    

END CLASS.