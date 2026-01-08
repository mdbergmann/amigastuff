
include? { ju:locals
include? task-jfunit 4thsrc:jfunit.4th

anew task-gol

\ ------------------------------------
\ ------------ RULES -----------------
\ ------------------------------------

\ 1. Eine lebende Zelle lebt auch in der Folgegeneration,
\ wenn sie entweder zwei oder drei lebende Nachbarn hat.
\ 2. Eine tote Zelle "wird geboren" (lebt in der Folgegeneration),
\ wenn sie genau drei lebende Nachbarn hat.
\ 3. Eine lebende Zelle "stirbt" (ist in der Folgegeneration tot),
\ wenn sie weniger als zwei (Vereinsamung) oder mehr als drei (Übervölkerung) lebende Nachbarn hat.
\ 4. Eine tote Zelle bleibt tot, wenn sie nicht genau drei lebende Nachbarn hat.

1 constant alive
0 constant dead

: alive= ( n -- flag )
    1 = ;

: dead= ( n -- flag )
    0= ;

\ state: alive = 1, dead = 0
: alive? ( state neighbours -- newstate )
    swap alive=
    if ( ." alive" ) dup 2 = swap 3 = or
    else ( ." dead" ) 3 =
    then
    if alive else dead then
    ;

: jfu.alive?.stays-2-n
    alive 2 alive? alive= ' true? " Should stay alive" assert ;
: jfu.alive?.stays-3-n
    alive 3 alive? alive= ' true? " Should stay alive" assert ;
: jfu.alive?.born-3-n
    dead 3 alive? alive= ' true? " Should be alive" assert ;
: jfu.alive?.dies-<2-n
    alive 1 alive? alive= ' false? " Should be dead!" assert ;
: jfu.alive?.dies->3-n
    alive 4 alive? alive= ' false? " Should be dead!" assert ;
: jfu.alive?.stays-<>3-n
    dead 2 alive? alive= ' false? " Should be dead!" assert ;

: test.once  ( word-addr [via tick] -- )   execute 0sp cr ;

: jfu.rules ( -- )
    0sp
    cr ." test.rules..." cr
    ' jfu.alive?.stays-2-n test.once
    ' jfu.alive?.stays-3-n test.once
    ' jfu.alive?.born-3-n test.once
    ' jfu.alive?.dies-<2-n test.once
    ' jfu.alive?.dies->3-n test.once
    ' jfu.alive?.stays-<>3-n test.once
    ;

\ --------------------------------------
\ -------- GRID ------------------------
\ --------------------------------------

-99 constant 2darray_size

: (2darray-0-addr) ( row col addr -- body-addr )
    rot over @ * + + 2 cells + ;

: (2darray_size) ( 0-addr -- #rows #cols )
    dup 2 cells - @
    swap
    cell- @
    ;

: 2darray ( #rows #cols -- addr ) ( 2d array stores the # rows and cols in the first two cells )
    2dup swap create , , * allot
    does>
    over ( -99 addr -99 )
    2darray_size = if
        swap drop
        0 0 rot (2darray-0-addr) (2darray_size)
    else ( member: row col -- addr )
        (2darray-0-addr)
    then ;

: 2darray-all { arr-addr wrd -- , loops over array and executes 'word' for each entry }
    arr-addr (2darray_size)
    swap
    0 do
        dup 0 do
            arr-addr wrd execute
            arr-addr 1+ -> arr-addr
        loop
    loop
    drop
    ;

3 3 2darray grid-src
3 3 2darray grid-dest

: cell-set-dead ( addr -- , sets cell 'dead' at given position )
    dead swap c!
    ;

: grid-reset ( -- , resets the grid to all dead )
    0 0 grid-src ' cell-set-dead 2darray-all
    ;

: grid_elem { row col -- elem_value } ( checks for grid boundaries )
    \ if beyond boundaries returns DEAD
    \ ." row:" row . ." /col:" col . cr
    row 0< if dead ( ." row < 0" ) return then
    col 0< if dead ( ." col < 0" ) return then
    2darray_size grid-src ( retrieve size )
    col <= if drop dead ( ." col > cols" ) return then
    row <= if dead ( ." row > rows" ) return then
    row col grid-src c@
    ;

: grid_cnt_ngbs { row col -- n } ( counts the living neighbours of this cell )
    \ cr row . col . ." => "
    0
    row 1- col 1- grid_elem +
    row 1- col grid_elem +
    row 1- col 1+ grid_elem +
    row col 1- grid_elem +
    row col 1+ grid_elem +
    row 1+ col 1- grid_elem +
    row 1+ col grid_elem +
    row 1+ col 1+ grid_elem +
    ;

: grid_newgen { | row col max_row max_col -- } ( operates on grid-src and grid-dest )
    \ grid size
    2darray_size grid-src
    -> max_col
    -> max_row
    max_row 0 do
        max_col 0 do
            j -> row
            i -> col
            \ row . ." / " col . ." = " row col grid_elem . cr
            row col grid_elem
            \ dup ." old-state=" .
            row col grid_cnt_ngbs
            \ dup ." , ngbs=" .
            alive?
            \ dup ." => new-state=" . cr
            row col grid-dest c!
        loop
    loop
    ;

\ ----------- TESTS ------------

true
.if  \ conditionally compile tests

create testgridalive 1 c, 1 c, 1 c,
                     1 c, 1 c, 1 c,
                     1 c, 1 c, 1 c,

create testgrid1 0 c, 1 c, 0 c,
                 0 c, 1 c, 0 c,
                 0 c, 1 c, 0 c,

: test.init ( -- , test setup )
    0sp ;

: jfu.grid-reset ( -- , tests resetting the grd to all dead )
    test.init
    testgridalive 0 0 grid-src 9 move
    grid-reset
    0 0 grid_elem dead= ' true? " Should be dead!" assert
    0 1 grid_elem dead= ' true? " Should be dead!" assert
    0 2 grid_elem dead= ' true? " Should be dead!" assert
    1 0 grid_elem dead= ' true? " Should be dead!" assert
    1 1 grid_elem dead= ' true? " Should be dead!" assert
    1 2 grid_elem dead= ' true? " Should be dead!" assert
    2 0 grid_elem dead= ' true? " Should be dead!" assert
    2 1 grid_elem dead= ' true? " Should be dead!" assert
    2 2 grid_elem dead= ' true? " Should be dead!" assert
    ;

: jfu.grid-elem ( -- , tests retriueving the right element in the grid )
    ." test.grid-elem..." cr
    test.init
    testgrid1 0 0 grid-src 9 move
    \ range checks
    -1 0 grid_elem dead= ' true? " Should be dead!" assert
    0 -1 grid_elem dead= ' true? " Should be dead!" assert
    0 3 grid_elem dead= ' true? " Should be dead!" assert
    3 0 grid_elem dead= ' true? " Should be dead!" assert
    3 4 grid_elem dead= ' true? " Should be dead!" assert
    4 3 grid_elem dead= ' true? " Should be dead!" assert
    \ in range
    0 0 grid_elem dead= ' true? " Should be dead!" assert
    0 1 grid_elem alive= ' true? " Should be alive!" assert
    0 2 grid_elem dead= ' true? " Should be dead!" assert
    1 0 grid_elem dead= ' true? " Should be dead!" assert
    1 1 grid_elem alive= ' true? " Should be alive!" assert
    1 2 grid_elem dead= ' true? " Should be dead!" assert
    2 0 grid_elem dead= ' true? " Should be dead!" assert
    2 1 grid_elem alive= ' true? " Should be alive!" assert
    2 2 grid_elem dead= ' true? " Should be dead!" assert
    ;

: jfu.grid_cnt_ngbs ( -- , tests counting the neighbours of a cell in the grid )
    ." test.grid_cnt_ngbs..." cr
    test.init
    testgrid1 0 0 grid-src 9 move
    0 0 grid_cnt_ngbs 2 = ' true? " Should be 2!" assert
    0 1 grid_cnt_ngbs 1 = ' true? " Should be 1!" assert
    0 2 grid_cnt_ngbs 2 = ' true? " Should be 2!" assert
    1 0 grid_cnt_ngbs 3 = ' true? " Should be 3!" assert
    1 1 grid_cnt_ngbs 2 = ' true? " Should be 2!" assert
    1 2 grid_cnt_ngbs 3 = ' true? " Should be 3!" assert
    2 0 grid_cnt_ngbs 2 = ' true? " Should be 2!" assert
    2 1 grid_cnt_ngbs 1 = ' true? " Should be 1!" assert
    2 2 grid_cnt_ngbs 2 = ' true? " Should be 2!" assert
    ;

: jfu.grid_newgen.tg1 ( -- ,test result of NEW-GEN )
    ." test.grid_newgen.tg1..." cr
    test.init
    \ cr ." testgrid1 addr:" testgrid1 . cr
    \ ." testgrid1-res addr:" testgrid1-res . cr
    testgrid1 0 0 grid-src 9 move
    grid_newgen
    0 0 grid-dest 0 0 grid-src 9 move ( copy dest grid to src grid )
    0 0 grid_elem dead= ' true? " Should be dead!" assert
    0 1 grid_elem dead= ' true? " Should be dead!" assert
    0 2 grid_elem dead= ' true? " Should be dead!" assert
    1 0 grid_elem alive= ' true? " Should be alive!" assert
    1 1 grid_elem alive= ' true? " Should be alive!" assert
    1 2 grid_elem alive= ' true? " Should be alive!" assert
    2 0 grid_elem dead= ' true? " Should be dead!" assert
    2 1 grid_elem dead= ' true? " Should be dead!" assert
    2 2 grid_elem dead= ' true? " Should be dead!" assert
    ;

create testgrid2 0 c, 1 c, 0 c,
                 1 c, 0 c, 1 c,
                 0 c, 1 c, 0 c,

: jfu.grid_newgen.tg2 ( -- ,test result of NEW-GEN )
    ." test.grid_newgen.tg2..." cr
    test.init
    testgrid2 0 0 grid-src 9 move
    grid_newgen
    0 0 grid-dest 0 0 grid-src 9 move ( copy dest grid to src grid )
    0 0 grid_elem dead= ' true? " Should be dead!" assert
    0 1 grid_elem alive= ' true? " Should be alive!" assert
    0 2 grid_elem dead= ' true? " Should be dead!" assert
    1 0 grid_elem alive= ' true? " Should be alive!" assert
    1 1 grid_elem dead= ' true? " Should be dead!" assert
    1 2 grid_elem alive= ' true? " Should be alive!" assert
    2 0 grid_elem dead= ' true? " Should be dead!" assert
    2 1 grid_elem alive= ' true? " Should be alive!" assert
    2 2 grid_elem dead= ' true? " Should be dead!" assert
    ;


: jfu.test.all
    ." test.all..." cr
    jfu.rules
    jfu.grid-elem
    jfu.grid_cnt_ngbs
    jfu.grid_newgen.tg1
    jfu.grid_newgen.tg2
    ;

.then

