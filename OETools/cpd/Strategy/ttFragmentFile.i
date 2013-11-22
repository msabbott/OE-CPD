/*------------------------------------------------------------------------
    File        : ttFragmentFile.i
    Purpose     : 

    Syntax      :

    Description : Temp-Table Definition for ttFragmentFile table

    Author(s)   : Mark Abbott
    Created     : Fri Nov 22 17:10:29 GMT 2013
    Notes       :
  ----------------------------------------------------------------------*/

 DEFINE {1} TEMP-TABLE ttFragmentFile NO-UNDO
     
        FIELD FragmentID AS INTEGER
        FIELD FileName   AS CHARACTER
        FIELD StartLine  AS INTEGER
        FIELD EndLine    AS INTEGER
        
            INDEX PriKey IS PRIMARY UNIQUE FragmentID ASCENDING FileName ASCENDING StartLine ASCENDING EndLine ASCENDING.