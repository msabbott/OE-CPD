 
 /*------------------------------------------------------------------------
    File        : AbstractStrategy
    Purpose     : 
    Syntax      : 
    Description : Defines an Abstract detection strategy
    Author(s)   : Mark Abbott
    Created     : Thu Oct 31 15:43:24 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
  
USING Progress.Lang.*.
USING OETools.cpd.Hash.AbstractHash.
USING OETools.cpd.Reporter.AbstractReporter.
USING OETools.cpd.File.FileList.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Strategy.AbstractStrategy: 
    
    {OETools\cpd\File\ttFile.i PROTECTED}
    {OETools\cpd\File\dsFile.i PROTECTED}

    /* Defines number of lines to group into one scanned code block */
	DEFINE PROTECTED PROPERTY LinesPerCodeBlock AS INTEGER NO-UNDO 
	GET.
	SET. 
	
	/* Defines two similar code blocks */
	DEFINE PROTECTED TEMP-TABLE ttBlock NO-UNDO
	   
	   FIELD FileNameOne  AS CHARACTER
	   FIELD StartLineOne AS INTEGER
	   FIELD EndLineOne   AS INTEGER
	   
	   FIELD FileNameTwo  AS CHARACTER
       FIELD StartLineTwo AS INTEGER
       FIELD EndLineTwo   AS INTEGER
       
       FIELD Data         AS CHARACTER
       
        INDEX PriKey IS PRIMARY UNIQUE FileNameOne  ASCENDING
                                       StartLineOne ASCENDING
                                       EndLineOne   ASCENDING
                                       FileNameTwo  ASCENDING
                                       StartLineTwo ASCENDING
                                       EndLineTwo   ASCENDING.

	/*------------------------------------------------------------------------------
	 Purpose: Default Class Constructor
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AbstractStrategy (  ):
	    
	    SUPER ().
	    
	    ASSIGN LinesPerCodeBlock = 5. /* Default number */
	    
	END CONSTRUCTOR.
	
	/*------------------------------------------------------------------------------
     Purpose: Class Constructor which allows creator to set lines per code at creation time
     Notes:
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AbstractStrategy ( INPUT piLinesPerCodeBlock AS INTEGER ):
	    
		SUPER ().
		
		ASSIGN LinesPerCodeBlock = piLinesPerCodeBlock.
		
	END CONSTRUCTOR.

	/*------------------------------------------------------------------------------
	 Purpose: Default implementation of code block comparison
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LOGICAL Compare(  ):
	    
	    RETURN FALSE.

	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose: Checks for common lines that should be ignored
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC LOGICAL ExcludeIfCommon( INPUT pcLine AS CHARACTER ):
		
        /* Ignore AppBuilder markup */
        IF pcLine BEGINS "&ANALYZE-"
        OR pcLine BEGINS "/* _UIB"
        OR pcLine BEGINS "&Scoped-define PROCEDURE-TYPE"
        OR pcLine BEGINS "&Scoped-define DB-AWARE"
        OR pcLine BEGINS "/* ********************  Preprocessor Definitions  ******************** */"
        OR pcLine BEGINS "/* *********************** Procedure Settings ************************ */"
        OR pcLine BEGINS "/* Settings for THIS-PROCEDURE"
        OR pcLine BEGINS "/* *************************  Create Window  ************************** */"
        OR pcLine BEGINS "/* ************************* Included-Libraries *********************** */"
        OR pcLine BEGINS "/* ************************  Main Code Block  *********************** */"
        OR pcLine BEGINS "  Purpose:"
        OR pcLine BEGINS "  Parameters:"
        OR pcLine BEGINS "  Notes:"
        OR pcLine BEGINS "    Notes       :"
        OR TRIM(pcLine) MATCHES "/~~*--*--"
        OR TRIM(pcLine) MATCHES "--*--~~*/"
        OR pcLine MATCHES "*src/web2/wrap-cgi.i*"
        OR pcLine BEGINS "/* DESIGN Window definition (used by the UIB)"
        OR pcLine BEGINS "CREATE WINDOW Procedure ASSIGN"
        OR pcLine BEGINS "/* END WINDOW DEFINITION */"
        OR pcLine BEGINS "USING Progress.Lang.*."
        OR pcLine BEGINS "ROUTINE-LEVEL ON ERROR UNDO, THROW."
        
        /* Ignore common code lines */
        OR TRIM(pcLine) EQ "END."
        OR TRIM(pcLine) EQ "/*"
        OR TRIM(pcLine) EQ "*/"
        OR TRIM(pcLine) BEGINS "SUPER ()."
        OR TRIM(pcLine) BEGINS "END PROCEDURE."
        OR TRIM(pcLine) BEGINS "END METHOD."
        OR TRIM(pcLine) BEGINS "END FUNCTION."
            THEN RETURN TRUE.
            
        RETURN FALSE.

	END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Processes an individual file
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL ProcessFile( INPUT pcFileName AS CHARACTER ):
        
        RETURN FALSE.
        
    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose: Processes the contents of a FileList
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID ProcessFileList( INPUT poFileList AS OETools.cpd.File.FileList ):
		
		/* Fetch data */
		poFileList:FetchAll(OUTPUT DATASET dsFile).
		
		FOR EACH ttFile NO-LOCK:
		    
		    ProcessFile(INPUT ttFile.FileName).
		    
		END.

	END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Report data through Reporter
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL Report( INPUT poReporter AS OETools.cpd.Reporter.AbstractReporter ):
        
        poReporter:Initialise().
        
        FOR EACH ttBlock NO-LOCK:
                       
            poReporter:WriteBlock(ttBlock.FileNameOne, ttBlock.StartLineOne, ttBlock.EndLineOne,
                                  ttBlock.FileNameTwo, ttBlock.StartLineTwo, ttBlock.EndLineTwo,
                                  ttBlock.Data).
            
        END.
        
        poReporter:ShutDown().

    END METHOD.

END CLASS.