 
 /*------------------------------------------------------------------------
    File        : DefaultStrategy
    Purpose     : 
    Syntax      : 
    Description : Define strategy for processing data using a default strategy
    Author(s)   : Mark Abbott
    Created     : Thu Oct 31 15:44:36 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.Strategy.AbstractStrategy.
USING OETools.cpd.Hash.AbstractHash.
USING OETools.cpd.Hash.DefaultHash.
USING OETools.cpd.Reporter.AbstractReporter.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Strategy.DefaultStrategy INHERITS AbstractStrategy: 

    /* Holds full lines of text from files */
    DEFINE PRIVATE TEMP-TABLE ttRawLine NO-UNDO
    
        FIELD FileName   AS CHARACTER
        FIELD LineNumber AS INTEGER
        FIELD Data       AS CHARACTER
        FIELD UseLine    AS LOGICAL
            
            INDEX PriKey IS PRIMARY UNIQUE FileName ASCENDING LineNumber ASCENDING
            INDEX UseKey                   FileName ASCENDING UseLine    ASCENDING LineNumber ASCENDING.
            
    /* Holds hashed contents of ttLine records */
    DEFINE PRIVATE TEMP-TABLE ttHash NO-UNDO
    
        FIELD FileName  AS CHARACTER
        FIELD StartLine AS INTEGER
        FIELD EndLine   AS INTEGER
        FIELD HashData  AS CHARACTER
        
        FIELD Reported  AS LOGICAL INITIAL FALSE
        
            INDEX PriKey  IS PRIMARY UNIQUE FileName ASCENDING StartLine ASCENDING
            INDEX HashKey                   HashData ASCENDING
            INDEX RepKey                    Reported ASCENDING.

    /* Holds Hash object to be used in algorithm */
    DEFINE PROTECTED PROPERTY Hash AS OETools.cpd.Hash.AbstractHash NO-UNDO 
    GET.
    SET. 

	/*------------------------------------------------------------------------------
	 Purpose: Default class constructor
	 Notes:
	------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC DefaultStrategy ( ):
        
        SUPER( ).
        
        CreateDefaultHash().
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Class Constructor which allows creator to set lines per code at creation time
     Notes:
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC DefaultStrategy ( INPUT piLinesPerCodeBlock AS INTEGER ):
	    
	    SUPER( INPUT piLinesPerCodeBlock ).
	    
	    CreateDefaultHash().
	    
	END CONSTRUCTOR.
	

    /*------------------------------------------------------------------------------
     Purpose: Class Constructor which allows creator to set lines per code, and Hash object at creation time
     Notes:
    ------------------------------------------------------------------------------*/	
	CONSTRUCTOR PUBLIC DefaultStrategy ( INPUT poHash AS OETools.cpd.Hash.AbstractHash, INPUT piLinesPerCodeBlock AS INTEGER ):
	    
		SUPER (piLinesPerCodeBlock).
		
		ASSIGN Hash = poHash.
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Compares hashed code blocks to each other
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Compare(  ):
                
        DEFINE BUFFER ttHash  FOR ttHash.
        DEFINE BUFFER bttHash FOR ttHash.
        
        DEFINE BUFFER ttFragment      FOR ttFragment.
        DEFINE BUFFER bttFragment     FOR ttFragment.
        DEFINE BUFFER ttFragmentFile  FOR ttFragmentFile.
        DEFINE BUFFER bttFragmentFile FOR ttFragmentFile.
        
        
        FOR EACH ttHash EXCLUSIVE-LOCK
           WHERE ttHash.Reported = FALSE,
        
            EACH bttHash EXCLUSIVE-LOCK
           WHERE bttHash.HashData = ttHash.HashData
             AND bttHash.Reported = FALSE
             AND (  (    bttHash.FileName  EQ ttHash.FileName
                     AND bttHash.StartLine NE ttHash.StartLine)
                  OR(bttHash.FileName NE ttHash.FileName)
                 ):
               
            ASSIGN ttHash.Reported  = TRUE
                   bttHash.Reported = TRUE.
                   
            /* Find a fragment record for the Hash being processed */
            FIND ttFragmentFile
                 WHERE ttFragmentFile.FileName  EQ ttHash.FileName
                   AND ttFragmentFile.StartLine LE ttHash.StartLine
                   AND ttFragmentFile.EndLine   GE ttHash.StartLine
                       EXCLUSIVE-LOCK NO-ERROR.
                       
            IF NOT AVAILABLE ttFragmentFile THEN
            DO:
                CREATE ttFragmentFile.
                
                ASSIGN ttFragmentFile.FragmentID = ?
                       ttFragmentFile.FileName   = ttHash.FileName
                       ttFragmentFile.StartLine  = ttHash.StartLine
                       ttFragmentFile.EndLine    = ttHash.EndLine.
            END.
            ELSE
            DO:
                ASSIGN ttFragmentFile.EndLine = ttHash.EndLine.
            END.
            
            /* Find a second fragment for the other hash found */
            FIND bttFragmentFile
                 WHERE bttFragmentFile.FileName  EQ bttHash.FileName
                   AND bttFragmentFile.StartLine LE bttHash.StartLine
                   AND bttFragmentFile.EndLine   GE bttHash.StartLine
                       EXCLUSIVE-LOCK NO-ERROR.
                       
            IF NOT AVAILABLE bttFragmentFile THEN
            DO:
                CREATE bttFragmentFile.
                
                ASSIGN bttFragmentFile.FragmentID = ?
                       bttFragmentFile.FileName   = bttHash.FileName
                       bttFragmentFile.StartLine  = bttHash.StartLine
                       bttFragmentFile.EndLine    = bttHash.EndLine.
            END.
            ELSE
            DO:
                ASSIGN bttFragmentFile.EndLine = bttHash.EndLine.
            END.
            
            /* Harmonise the Fragment ID, or create a new Fragment if required */
            IF ttFragmentFile.FragmentID NE ? AND bttFragmentFile.FragmentID EQ ? THEN
            DO:
                ASSIGN bttFragmentFile.FragmentID = ttFragmentFile.FragmentID.
            END.
            ELSE 
            IF ttFragmentFile.FragmentID EQ ? AND bttFragmentFile.FragmentID NE ? THEN
            DO:
                ASSIGN ttFragmentFile.FragmentID = bttFragmentFile.FragmentID.
            END.
            ELSE
            IF ttFragmentFile.FragmentID EQ ? AND bttFragmentFile.FragmentID EQ ? THEN
            DO:
                FIND LAST bttFragment NO-LOCK NO-ERROR.
                
                CREATE ttFragment.
                
                ASSIGN ttFragment.FragmentID      = (IF AVAILABLE bttFragment THEN bttFragment.FragmentID + 1 ELSE 1)
                       ttFragment.Data            = ""
                       ttFragmentFile.FragmentID  = ttFragment.FragmentID
                       bttFragmentFile.FragmentID = ttFragment.FragmentID.
            END.
            
            FIND ttBlock
                 WHERE ttBlock.FileNameOne  = ttHash.FileName
                   AND ttBlock.StartLineOne <= ttHash.StartLine
                   AND ttBlock.EndLineOne   >= ttHash.StartLine
                   AND ttBlock.FileNameTwo  = bttHash.FileName
                   AND ttBlock.StartLineTwo <= bttHash.StartLine
                   AND ttBlock.EndLineTwo   >= bttHash.StartLine
                       EXCLUSIVE-LOCK NO-ERROR.
                       
            IF AVAILABLE ttBlock THEN
            DO:
                ASSIGN ttBlock.EndLineOne = ttHash.EndLine
                       ttBlock.EndLineTwo = bttHash.EndLine.
            END.
            ELSE
            DO:
                CREATE ttBlock.
                
                ASSIGN ttBlock.FileNameOne  = ttHash.FileName
                       ttBlock.StartLineOne = ttHash.StartLine
                       ttBlock.EndLineOne   = ttHash.EndLine
                       ttBlock.FileNameTwo  = bttHash.FileName
                       ttBlock.StartLineTwo = bttHash.StartLine
                       ttBlock.EndLineTwo   = bttHash.EndLine.
            END.                    
            
        END.
        
        /* Loop through the fragments, and build up the code blocks */
        FOR EACH ttFragment EXCLUSIVE-LOCK,
           FIRST ttFragmentFile NO-LOCK
           WHERE ttFragmentFile.FragmentID = ttFragment.FragmentID,
            EACH ttRawLine NO-LOCK
           WHERE ttRawLine.FileName   EQ ttFragmentFile.FileName
             AND ttRawLine.LineNumber GE ttFragmentFile.StartLine
             AND ttRawLine.LineNumber LE ttFragmentFile.EndLine
              BY ttRawLine.FileName
              BY ttRawLine.LineNumber:
                  
            ASSIGN ttFragment.Data = ttFragment.Data + "~n"
                                   + ttRawLine.Data.
                  
        END.
        
        /* Loop through the matched blocks, and build up the output */
        FOR EACH ttBlock EXCLUSIVE-LOCK,
            EACH ttRawLine NO-LOCK
           WHERE ttRawLine.FileName = ttBlock.FileNameOne
             AND ttRawLine.LineNumber >= ttBlock.StartLineOne
             AND ttRawLine.LineNumber <= ttBlock.EndLineOne
              BY ttRawLine.FileName
              BY ttRawLine.LineNumber:
                  
            ASSIGN ttBlock.Data = ttBlock.Data + "~n"
                                + ttRawLine.Data.                  
                  
        END.

    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose: Creates a default Hash object
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID CreateDefaultHash(  ):
		
		ASSIGN Hash = NEW OETools.cpd.Hash.DefaultHash().

	END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Processes an individual file
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL ProcessFile( INPUT pcFileName AS CHARACTER ):
        
        DEFINE VARIABLE cLine       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iLineNumber AS INTEGER   NO-UNDO INITIAL 0.
        DEFINE VARIABLE cData       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iInnerLoop  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iMaxLine    AS INTEGER   NO-UNDO.
        
        DEFINE BUFFER bttRawLine FOR ttRawLine.
        
        /* If file has already been processed, then return false */
        IF CAN-FIND(FIRST ttRawLine NO-LOCK
                    WHERE ttRawLine.FileName = pcFileName) THEN RETURN FALSE.
        
        /* Open Input file */
        INPUT FROM VALUE(pcFileName).
        
        /* Read every line in the file, trimming and removing spaces, as we go */
        FileLoop:
        REPEAT:
            
            ASSIGN iLineNumber = iLineNumber + 1.
            
            IMPORT UNFORMATTED cLine.
            
            /* Create ttRawLine record */
            CREATE ttRawLine.
            
            ASSIGN ttRawLine.FileName   = pcFileName
                   ttRawLine.LineNumber = iLineNumber
                   ttRawLine.Data       = cLine
                   ttRawLine.UseLine    = FALSE. /* Assume that line is not useable */
            
            /* If this is a common line to exclude, then ignore it */
            IF ExcludeIfCommon(cLine) THEN NEXT FileLoop.
            
            /* Trim lines, and removal all other spaces */
            ASSIGN cLine = TRIM(cLine)
                   cLine = REPLACE(cLine, " ", "").
            
            /* Ignore blank lines */
            IF cLine = ? OR cLine = "" THEN NEXT FileLoop.
            
            /* Line has passed tests */
            ASSIGN ttRawLine.UseLine = TRUE.
            
        END.    
        
        /* Close input file */
        INPUT CLOSE.           
        
        /* Loop through the data, generating a hash for each "LinesPerCodeBlock" number of lines */
        FOR EACH ttRawLine NO-LOCK
           WHERE ttRawLine.FileName = pcFileName
             AND ttRawLine.UseLine  = TRUE
              /*BY ttRawLine.FileName*/
              BY ttRawLine.LineNumber:
                  
            ASSIGN cData    = ttRawLine.Data
                   iMaxLine = ttRawLine.LineNumber.
            
            /* Find the next "LinesPerCodeBlock" after this line */
            DO iInnerLoop = 1 TO LinesPerCodeBlock - 1:
                
                FIND FIRST bttRawLine
                     WHERE bttRawLine.FileName   = pcFileName
                       AND bttRawLine.LineNumber = ttRawLine.LineNumber + iInnerLoop
                           NO-LOCK NO-ERROR.
                           
                IF AVAILABLE bttRawLine THEN
                DO:
                    ASSIGN cData    = cData + REPLACE(TRIM(bttRawLine.Data), " ", "")
                           iMaxLine = bttRawLine.LineNumber.
                END.
                
            END.
            
            /* Create ttHash record */
            CREATE ttHash.
            
            ASSIGN ttHash.FileName  = ttRawLine.FileName
                   ttHash.StartLine = ttRawLine.LineNumber
                   ttHash.EndLine   = iMaxLine
                   ttHash.HashData  = Hash:Hash(cData).
             
        END.
        
        RETURN TRUE.      
        
    END METHOD.
	
END CLASS.