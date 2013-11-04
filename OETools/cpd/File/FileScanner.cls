 
 /*------------------------------------------------------------------------
    File        : FileScanner
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mabbott
    Created     : Fri Nov 01 08:47:14 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.File.FileList.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.File.FileScanner:
    
    
	DEFINE PUBLIC PROPERTY MaxRecurseLevel AS INTEGER INITIAL ? NO-UNDO 
	GET.
	SET. 

	DEFINE PUBLIC PROPERTY RecurseDirectories AS LOGICAL INITIAL TRUE NO-UNDO 
	GET.
	SET. 
	
	DEFINE PROTECTED PROPERTY FileList AS OETools.cpd.File.FileList NO-UNDO
    GET.
    SET. 
	

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC FileScanner ( INPUT poFileList AS OETools.cpd.File.FileList ):
		SUPER ().
		
		/* By default, recurse into directories with no limit on depth */
		ASSIGN RecurseDirectories = TRUE
		       MaxRecurseLevel    = ?
		       FileList           = poFileList.
		
	END CONSTRUCTOR.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PROTECTED LOGICAL ScanAndRecurse( INPUT pcDirectory AS CHARACTER, INPUT pcPattern AS CHARACTER, INPUT piRecurseLevel AS INTEGER ):
	    
	    DEFINE VARIABLE cLine       AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cName       AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cFullPath   AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cAttributes AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE iLoop       AS INTEGER NO-UNDO.
	    		
		/* Ensure that we have no recursed any further than needed */
		IF MaxRecurseLevel NE ? AND piRecurseLevel > MaxRecurseLevel THEN RETURN FALSE.
		
		/* Read from directory */
		INPUT FROM OS-DIR(pcDirectory).
		
		RepeatLoop:
		REPEAT:
		    
		    IMPORT UNFORMATTED cLine.
		    
		    /* Ignore "." and ".." entries */
		    IF cLine BEGINS '"."' OR cLine BEGINS '".."' THEN NEXT RepeatLoop.
		    
		    ASSIGN cName       = TRIM(ENTRY(1, cLine, " "), '"')
		           cAttributes = TRIM(ENTRY(NUM-ENTRIES(cLine, " "), cLine, " "), '"').

            /* Pull out the full path to the file, including any spaces in the file name */
            ASSIGN cFullPath = "".		           
		    DO iLoop = 2 TO NUM-ENTRIES(cLine, " ") - 1:
		        
		        ASSIGN cFullPath = cFullPath
		                         + (IF cFullPath = "" THEN "" ELSE " ")
		                         + ENTRY(iLoop, cLine, " ").
		        
		    END.
		    
		    ASSIGN cFullPath = TRIM(cFullPath, '"').
		    
		    /* Process item */
		    IF cAttributes MATCHES "*F*" THEN
		    DO:
		        /* Check if file name matches the pattern */
		        IF cName MATCHES pcPattern THEN
		        DO:
		            FileList:AddFile(INPUT cFullPath).
		        END.
		    END.
		    ELSE IF cAttributes MATCHES "*D*" THEN
		    DO:
		        /* Recurse into directory */
		        ScanAndRecurse( INPUT cFullPath, INPUT pcPattern, INPUT piRecurseLevel  + 1 ).
	        END.		               
		    
		END.
		
		INPUT CLOSE.

	END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL ScanDirectory( INPUT pcDirectory AS CHARACTER, INPUT pcPattern AS CHARACTER ):
        
        /* If pcDirectory is blank or ?, then assume the current directory */
        IF pcDirectory = ? OR TRIM(pcDirectory) = "" THEN ASSIGN pcDirectory = ".".
        
        /* If pcPattern is blank or ?, then assume all files */
        IF pcPattern = ? OR TRIM(pcPattern) = "" THEN ASSIGN pcPattern = "*".
        
        ScanAndRecurse(INPUT pcDirectory, INPUT pcPattern, INPUT 0).
        
        RETURN TRUE.

    END METHOD.
	

END CLASS.