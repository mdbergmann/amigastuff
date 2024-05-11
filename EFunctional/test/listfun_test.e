MODULE '*/modules/asserts', '*/src/listfun'

PROC testMap()
    DEF result, it
    result := map([1,2,3,4,5], {it}, `it+1)
    forEach(result, {it}, `PrintF('it = \d\n', it))
    assertTrue(ListCmp(result, [2,3,4,5,6]), 'Lists should be equal')

    result := map([1,2,3,4,5], {it}, `it*it)
    forEach(result, {it}, `PrintF('it = \d\n', it))
    assertTrue(ListCmp(result, [1,4,9,16,25]), 'Lists * should be equal')
ENDPROC

PROC multReduceFun(accu, it)
ENDPROC accu*it
PROC addReduceFun(accu, it)
ENDPROC accu+it

PROC testReduce()
    DEF result, accu, it
    result := reduce([1,2,3,4,5], 0, {addReduceFun})
    PrintF('reduce result: \d\n', result)
    assertTrue(result = 15, 'Is not 15')

    result := reduce([1,2,3], 1, {multReduceFun})
    PrintF('reduce result: \d\n', result)
    assertTrue(result = 6, 'Is not 6')
ENDPROC

PROC main()
    testMap()
    testReduce()
ENDPROC

