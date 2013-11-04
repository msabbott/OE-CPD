 
 /*------------------------------------------------------------------------
    File        : FileList
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mabbott
    Created     : Fri Nov 01 11:10:30 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.File.FileList: 
    
    {OETools\cpd\File\ttFile.i PROTECTED}
    {OETools\cpd\File\dsFile.i PROTECTED}
    
	DEFINE PUBLIC PROPERTY Scanner AS OETools.cpd.File.FileScanner NO-UNDO 
	GET.
	SET. 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC FileList (  ):
		SUPER ().
		
		/* Create file scanner object */
		ASSIGN Scanner = NEW OETools.cpd.File.FileScanner(THIS-OBJECT).
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID AddFile( INPUT pcFileName AS CHARACTER ):
        
        IF NOT CAN-FIND(FIRST ttFile NO-LOCK
                        WHERE ttFile.FileName = pcFileName) THEN
        DO:
            CREATE ttFile.
            
            ASSIGN ttFile.FileName = pcFileName.
        END.
        
        RETURN.

    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID FetchAll( OUTPUT DATASET dsFile ):
               
        /* Contents of dataset should already be filled */

	END METHOD.	
	

END CLASS.