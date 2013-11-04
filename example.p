
/*------------------------------------------------------------------------
    File        : example.p
    Purpose     : 

    Syntax      :

    Description : Example OO-ABL file showing how to interact with OE-CPD	

    Author(s)   : Mark Abbott
    Created     : Mon Nov 04 17:49:18 GMT 2013
    Notes       :
  ----------------------------------------------------------------------*/

USING OETools.cpd.Strategy.*.  /* Defines search strategies       */
USING OETools.cpd.Hash.*.      /* Defines data hash functionality */
USING OETools.cpd.Reporter.*.  /* Defines reporting functionality */
USING OETools.cpd.File.*.      /* Defines file identification functionality */

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE objStrategy     AS OETools.cpd.Strategy.AbstractStrategy NO-UNDO. /* Define variable to hold Strategy */
DEFINE VARIABLE objFileList     AS OETools.cpd.File.FileList             NO-UNDO. /* Define variable to hold list of files */
DEFINE VARIABLE objTextReporter AS OETools.cpd.Reporter.AbstractReporter NO-UNDO. /* Define variable to hold Reporter */
DEFINE VARIABLE objPMDReporter  AS OETools.cpd.Reporter.AbstractReporter NO-UNDO. /* As above */

/* ***************************  Main Block  *************************** */

/* **** Step 1: Create objects **** */
ASSIGN

/* Create object to perform search using the "Default" strategy, using Default Hash, with
 * default number of "Lines-Per-Code-Block"
 */
objStrategy = NEW OETools.cpd.Strategy.DefaultStrategy()

/* Create object to hold list of files to be scanned */
objFileList = NEW OETools.cpd.File.FileList().


/* **** Step 2: Identify files **** */

/* Add in a single file */
objFileList:AddFile("./src/example.p").

/* Add in a whole directory, and any subdirectories */
objFileList:Scanner:ScanDirectory("./src/OETools", "*~~.cls"). /* Second parameter must be a valid for use with "MATCH" keyword. */

/* Set Maximum Directory Recursion Level. */
/* E.G.
 * When ? or Not Specified: Infinite
 * When 0, starting directory only
 * When 1, Starting Directory, and one level down
 * When 2, Starting Directory, and two levels down,
 * etc.
 */
objFileList:Scanner:MaxRecurseLevel = 0.

/* Scan again for .p files */
objFileList:Scanner:ScanDirectory("./src", "*~~.p").



/* **** Step 3: Read list of files **** */

/* Process everything in the file list */
objStrategy:ProcessFileList(INPUT objFileList).

/* Process an individual file */
objStrategy:ProcessFile(INPUT "./src/example.p").



/* **** Step 4: Compare Code Blocks and Identify Similar Code **** */
objStrategy:Compare().



/* **** Step 4: Output analysis report **** */
ASSIGN 

/* Create reporter for outputting to human-readable text format */
objTextReporter = NEW OETools.cpd.Reporter.TextFileReporter(INPUT "report.txt")   

/* Create reporter for outputting to PMD format (XML based) */       
objPMDReporter  = NEW OETools.cpd.Reporter.PMDReporter(INPUT "report-pmd.xml").

/* Output data via reporters */
objStrategy:Report(INPUT objTextReporter).
objStrategy:Report(INPUT objPMDReporter).

