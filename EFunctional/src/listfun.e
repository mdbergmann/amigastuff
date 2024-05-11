OPT MODULE

-> Generates and returns a new list by applying 'fun' on every element of 'lst'.
-> The list element used in 'fun' must be called 'it'.
EXPORT PROC map(lst, itref, fun)
    DEF newList, i, len, it, newIt
    it := itref
    len := ListLen(lst)
    newList := List(len)
    FOR i := 0 TO len-1
        it := ListItem(lst, i)
        newIt := Eval(fun)
        newList := ListAddItem(newList, newIt)
    ENDFOR
ENDPROC newList

-> Loop on 'lst' and calls 'fun' on every element
-> Element is 'it'
EXPORT PROC forEach(lst, itref, fun)
    DEF len, i, it
    it := itref
    len := ListLen(lst)
    FOR i := 0 TO len-1
        it := ListItem(lst, i)
        Eval(fun)
    ENDFOR
ENDPROC

EXPORT PROC reduce(lst, initialValue, fun)
    DEF accu, it, len, i
    len := ListLen(lst)
    accu := initialValue
    FOR i := 0 TO len-1
        it := ListItem(lst, i)
        accu := fun(accu, it)
    ENDFOR
ENDPROC accu

