/*------------------------------------------------------------------------
    File        : ttFragment.i
    Purpose     : 

    Syntax      :

    Description : Temp-Table Definition for ttFragment table

    Author(s)   : Mark Abbott
    Created     : Fri Nov 22 17:05:29 GMT 2013
    Notes       :
  ----------------------------------------------------------------------*/

 DEFINE {1} TEMP-TABLE ttFragment NO-UNDO
        FIELD FragmentID AS INTEGER
        FIELD Data       AS CHARACTER
        
            INDEX PriKey AS PRIMARY UNIQUE FragmentID ASCENDING.