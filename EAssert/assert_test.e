MODULE '*asserts'

PROC main() HANDLE
    PrintF('Testing AssertTrue...\n')
	testAssertTrue()
    PrintF('\n')
    PrintF('Testing AssertFalse...\n')
	testAssertFalse()

EXCEPT
	PrintF(exception)
ENDPROC

PROC testAssertTrue()
	PrintF('Testing TRUE = TRUE...')
	assertTrue(FALSE, 'TRUE should be TRUE')
	PrintF('OK\n')

	PrintF('Testing 1 = 1...')
    assertTrue(1=1, '1=1 should be TRUE')
	PrintF('OK\n')

	PrintF('Testing 1+1=2...')
	assertTrue(1+1=2, '1+1=2 should be TRUE')
	PrintF('OK\n')

	PrintF('Testing -1 = TRUE...')
	assertTrue(-1, '-1 should be TRUE!')
	PrintF('OK\n')

    PrintF('Testing fail...')
 ->   assertTrue(1=2, '1=2 should be TRUE')
    PrintF('OK\n')
ENDPROC

PROC testAssertFalse()
	PrintF('Testing FALSE...')
	assertFalse(FALSE, 'FALSE should be FALSE')
	PrintF('OK\n')

	PrintF('Testing 1 = 1...')
    assertFalse(2=1, '2=1 should be FALSE')
	PrintF('OK\n')

	PrintF('Testing 1+1=3...')
	assertFalse(1+1=3, '1+1=3 should be FALSE')
	PrintF('OK\n')

	PrintF('Testing 0 = FALSE...')
	assertFalse(0, '0 should be FALSE')
	PrintF('OK\n')	
ENDPROC

