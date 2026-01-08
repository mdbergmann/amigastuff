\ ------------------------------------
\ --------- Asserts ------------------
\ ------------------------------------

anew task-jfunit

variable failstr 128 allot      ( allocate space for fail message )

: true? ( flag -- flag )   true = ;
: false? ( flag -- flag )   false = ;

: assert ( inputs predicate-word fail-str-addr|FALSE, producing true/false -- abort|true )
    failstr 128 erase
    dup if
        " Fail: " failstr $move
        count failstr $append then
    execute if cr ." Success " cr else cr failstr $type cr abort then ;

