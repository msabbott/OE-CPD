 
 /*------------------------------------------------------------------------
    File        : DefaultHash
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mabbott
    Created     : Thu Oct 31 15:50:59 GMT 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OETools.cpd.Hash.AbstractHash.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OETools.cpd.Hash.DefaultHash INHERITS AbstractHash: 
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	CONSTRUCTOR PUBLIC DefaultHash (  ):
		SUPER ().
		
	END CONSTRUCTOR.	
	

	/*------------------------------------------------------------------------------
	 Purpose: Hashes data
	 Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC OVERRIDE CHARACTER Hash( INPUT pcData AS CHARACTER ):

        RETURN ENCODE(pcData).

    END METHOD.

END CLASS.