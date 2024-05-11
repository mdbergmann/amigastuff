OPT MODULE

EXPORT PROC assertTrue(expr, comment=NIL)
    IF expr = FALSE -> TRUE may be any number except 0
		IF comment <> NIL THEN PrintF('AssertError: \s\n', comment)
		Raise(StringF('ERROR: \d is not TRUE!\n', expr))
	ENDIF
ENDPROC

EXPORT PROC assertFalse(expr, comment=NIL)
	IF expr <> FALSE
		IF comment <> NIL THEN PrintF('AssertError: \s\n', comment)
		Raise(StringF('ERROR: \d is not FALSE!\n', expr))
    ENDIF
ENDPROC

EXPORT PROC assertEqual(expr1, expr2, comment=NIL)
    IF expr1 <> expr2
	    IF comment <> NIL THEN PrintF('AssertError: \s\n', comment)
		Raise(StringF('ERROR: \d is not \d!\n', expr1, expr2))
	ENDIF
ENDPROC

