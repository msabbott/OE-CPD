 
 /*------------------------------------------------------------------------
    File        : AbstractStrategy
    Purpose     : 
    Syntax      : 
    Description : Defines an Abstract detection strategy
    Author(s)   : mabbott
    Created     : Thu Oct 31 15:43:24 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
  
USING Progress.Lang.*.
USING OETools.cpd.Hash.AbstractHash.
USING OETools.cpd.Reporter.AbstractReporter.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Strategy.AbstractStrategy: 

	DEFINE PROTECTED PROPERTY Hash AS OETools.cpd.Hash.AbstractHash NO-UNDO 
	GET.
	SET. 

	DEFINE PROTECTED PROPERTY LinesPerHash AS INTEGER NO-UNDO 
	GET.
	SET. 
	
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
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AbstractStrategy ( INPUT oHash AS OETools.cpd.Hash.AbstractHash, INPUT iLinesPerHash AS INTEGER ):
	    
		SUPER ().
		
		ASSIGN Hash = oHash
		       LinesPerHash = iLinesPerHash.
		
	END CONSTRUCTOR.

	DESTRUCTOR PUBLIC AbstractStrategy ( ):

	END DESTRUCTOR.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LOGICAL Compare(  ):
	    
	    RETURN FALSE.

	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
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
        OR pcLine BEGINS "/*------------------------------------------------------------------------------"
        OR pcLine BEGINS "  Purpose:"
        OR pcLine BEGINS "  Parameters:"
        OR pcLine BEGINS "  Notes:"
        OR pcLine BEGINS "------------------------------------------------------------------------------*/"
        OR pcLine MATCHES "*src/web2/wrap-cgi.i*"
        OR pcLine BEGINS "/* DESIGN Window definition (used by the UIB)"
        OR pcLine BEGINS "CREATE WINDOW Procedure ASSIGN"
        OR pcLine BEGINS "/* END WINDOW DEFINITION */"
        
        /* Ignore common code lines */
        OR TRIM(pcLine) EQ "END."
        OR TRIM(pcLine) EQ "/*"
        OR TRIM(pcLine) EQ "*/"
        OR pcLine BEGINS "END PROCEDURE."
            THEN RETURN TRUE.
            
        RETURN FALSE.

	END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Processes an individual file
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL ProcessFile( INPUT cFileName AS CHARACTER ):
        
        RETURN FALSE.
        
    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LOGICAL Report( INPUT oReporter AS OETools.cpd.Reporter.AbstractReporter ):
        
        RETURN FALSE.

	END METHOD.

END CLASS.