 
 /*------------------------------------------------------------------------
    File        : AbstractHash
    Purpose     : 
    Syntax      : 
    Description : Defines Abstract class for Hashes
    Author(s)   : mabbott
    Created     : Thu Oct 31 15:49:16 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Hash.AbstractHash ABSTRACT: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    CONSTRUCTOR PUBLIC AbstractHash (  ):
        SUPER ().
        
    END CONSTRUCTOR.

    DESTRUCTOR PUBLIC AbstractHash ( ):

    END DESTRUCTOR.

	/*------------------------------------------------------------------------------
	 Purpose: Hashes data
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC ABSTRACT CHARACTER Hash( INPUT cData AS CHARACTER ).

END CLASS.