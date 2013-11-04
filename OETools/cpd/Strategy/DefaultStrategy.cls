 
 /*------------------------------------------------------------------------
    File        : DefaultStrategy
    Purpose     : 
    Syntax      : 
    Description : Define strategy for processing data using a default strategy
    Author(s)   : mabbott
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

    DEFINE PRIVATE TEMP-TABLE ttLine NO-UNDO
    
        FIELD FileName   AS CHARACTER
        FIELD LineNumber AS INTEGER
        FIELD Data       AS CHARACTER
            
            INDEX PriKey IS PRIMARY UNIQUE FileName ASCENDING LineNumber ASCENDING.

    DEFINE PRIVATE TEMP-TABLE ttRawLine NO-UNDO
    
        FIELD FileName   AS CHARACTER
        FIELD LineNumber AS INTEGER
        FIELD Data       AS CHARACTER
            
            INDEX PriKey IS PRIMARY UNIQUE FileName ASCENDING LineNumber ASCENDING.
            
    
    DEFINE PRIVATE TEMP-TABLE ttHash NO-UNDO
    
        FIELD FileName  AS CHARACTER
        FIELD StartLine AS INTEGER
        FIELD EndLine   AS INTEGER
        FIELD HashData  AS CHARACTER
        
        FIELD Reported  AS LOGICAL INITIAL FALSE
        
            INDEX PriKey  IS PRIMARY UNIQUE FileName ASCENDING StartLine ASCENDING
            INDEX HashKey                   HashData ASCENDING
            INDEX RepKey                    Reported ASCENDING.

    DEFINE PROTECTED PROPERTY Hash AS OETools.cpd.Hash.AbstractHash NO-UNDO 
    GET.
    SET. 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC DefaultStrategy ( INPUT piLinesPerHash AS INTEGER ):
	    
	    SUPER( INPUT piLinesPerHash ).
	    
	    ASSIGN Hash = NEW OETools.cpd.Hash.DefaultHash().
	    
	END CONSTRUCTOR.
		
	CONSTRUCTOR PUBLIC DefaultStrategy ( INPUT poHash AS OETools.cpd.Hash.AbstractHash, INPUT piLinesPerHash AS INTEGER ):
	    
		SUPER (piLinesPerHash).
		
		ASSIGN Hash = poHash.
		
	END CONSTRUCTOR.

	DESTRUCTOR PUBLIC DefaultStrategy ( ):

	END DESTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Compare(  ):
        
        DEFINE BUFFER ttHash  FOR ttHash.
        DEFINE BUFFER bttHash FOR ttHash.
        DEFINE BUFFER ttLine  FOR ttLine.
        DEFINE BUFFER bttLine FOR ttLine.
        
        FOR EACH ttHash EXCLUSIVE-LOCK
           WHERE ttHash.Reported = FALSE,
        
            EACH bttHash EXCLUSIVE-LOCK
           WHERE bttHash.HashData = ttHash.HashData
             AND bttHash.Reported = FALSE
             AND (  (    bttHash.FileName  EQ ttHash.FileName
                     AND bttHash.StartLine NE ttHash.StartLine)
                  OR(bttHash.FileName NE ttHash.FileName)
                 ),
                 
           FIRST ttLine NO-LOCK
           WHERE ttLine.FileName   = ttHash.FileName
             AND ttLine.LineNumber = ttHash.StartLine,
                 
           FIRST bttLine NO-LOCK
           WHERE bttLine.FileName   = bttHash.FileName
             AND bttLine.LineNumber = bttHash.StartLine
           :
               
            ASSIGN ttHash.Reported  = TRUE
                   bttHash.Reported = TRUE.
                   
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
     Purpose: Processes an individual file
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL ProcessFile( INPUT pcFileName AS CHARACTER ):
        
        DEFINE VARIABLE cLine       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iLineNumber AS INTEGER   NO-UNDO INITIAL 0.
        DEFINE VARIABLE cData       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iInnerLoop  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iMaxLine    AS INTEGER   NO-UNDO.
        
        DEFINE BUFFER bttLine FOR ttLine.
        
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
                   ttRawLine.Data       = cLine.
            
            /* If this is a common line to exclude, then ignore it */
            IF ExcludeIfCommon(cLine) THEN NEXT FileLoop.
            
            /* Trim lines, and removal all other spaces */
            ASSIGN cLine = TRIM(cLine)
                   cLine = REPLACE(cLine, " ", "").
            
            /* Ignore blank lines */
            IF cLine = ? OR cLine = "" THEN NEXT FileLoop.
            
            /* Create record */
            CREATE ttLine.
            
            ASSIGN ttLine.FileName   = pcFileName
                   ttLine.LineNumber = iLineNumber
                   ttLine.Data       = cLine.
            
        END.    
        
        /* Close input file */
        INPUT CLOSE.           
        
        /* Loop through the data, generating a hash for each "LinesPerHash" number of lines */
        FOR EACH ttLine NO-LOCK
           WHERE ttLine.FileName = pcFileName
              BY ttLine.FileName
              BY ttLine.LineNumber:
                  
            ASSIGN cData    = ttLine.Data
                   iMaxLine = ttLine.LineNumber.
            
            /* Find the next "LinesPerHash" after this line */
            DO iInnerLoop = 1 TO LinesPerHash - 1:
                
                FIND FIRST bttLine
                     WHERE bttLine.FileName   = pcFileName
                       AND bttLine.LineNumber = ttLine.LineNumber + iInnerLoop
                           NO-LOCK NO-ERROR.
                           
                IF AVAILABLE bttLine THEN
                DO:
                    ASSIGN cData    = cData + bttLine.Data
                           iMaxLine = bttLine.LineNumber.
                END.
                
            END.
            
            /* Create ttHash record */
            CREATE ttHash.
            
            ASSIGN ttHash.FileName  = ttLine.FileName
                   ttHash.StartLine = ttLine.LineNumber
                   ttHash.EndLine   = iMaxLine
                   ttHash.HashData  = Hash:Hash(cData).
             
        END.
        
        RETURN TRUE.      
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC OVERRIDE LOGICAL Report( INPUT poReporter AS OETools.cpd.Reporter.AbstractReporter ):
        
        poReporter:Initialise().
        
        FOR EACH ttBlock NO-LOCK:
                       
            poReporter:WriteBlock(ttBlock.FileNameOne, ttBlock.StartLineOne, ttBlock.EndLineOne,
                                  ttBlock.FileNameTwo, ttBlock.StartLineTwo, ttBlock.EndLineTwo,
                                  ttBlock.Data).
            
        END.
        
        poReporter:ShutDown().

    END METHOD.
	
	

END CLASS.