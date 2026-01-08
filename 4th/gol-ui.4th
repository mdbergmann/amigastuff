
include? { ju:locals
include? task-amiga_graph ju:amiga_graph
include? task-gol 4thsrc:gol.4th

anew task-gol-ui

\ -----------------------------------------
\ -------- Intuition stuff ----------------
\ -----------------------------------------

variable golwin

variable cell_height
variable cell_width

: win-title  ( -- title string absolute address )
    0" Game of Life" >abs
    ;

: win_height  ( -- height )
    480 ;

: win_width  ( -- width )
    640 ;

: win_height@  ( -- height, of current window )
    golwin @ ..@ wd_height ;

: win_width@  ( -- width, of current window )
    golwin @ ..@ wd_width ;

: draw_width@  ( -- width, of draw area of window )
    win_width@ golwin @ dup ..@ wd_borderleft swap ..@ wd_borderright + - ;

: draw_height@  ( -- height, of draw area of window )
    win_height@ golwin @ dup ..@ wd_bordertop swap ..@ wd_borderbottom + - ;

: calc-cell-size!  ( -- , sets cell_height and cell_width )
    2darray_size grid-src    ( rows cols )
    draw_width@ swap /      ( rows cell-width )
    swap                    ( cell-width rows )
    draw_height@ swap /     ( cell-width cell-height )
    cell_height !
    cell_width !
    ;

NewWindow golwin-tmpl
: (window.init)  ( -- , initialize NewWindow structure )
    golwin-tmpl
    0 over ..! nw_leftedge
    10 over ..! nw_topedge
    win_width over ..! nw_width
    win_height over ..! nw_height
    0 over ..! nw_detailpen
    1 over ..! nw_blockpen
    mousebuttons closewindow | over ..! nw_idcmpflags
    windowdrag windowdepth | windowclose | gimmezerozero | reportmouse | over ..! nw_flags
    win-title over ..! nw_title
    null over ..! nw_firstgadget
    null over ..! nw_checkmark
    null over ..! nw_screen
    null over ..! nw_bitmap
    wbenchscreen swap ..! nw_type
    ;

: gol.ui.paint-cell  ( addr x y -- , paints the cell from grid-src )
    cr ." paint-cell" cr
    .s
    drop drop
    c@ alive= if
        \ paint black
        cr ." paint black" cr
    else
        \ paint white
        cr ." paint white" cr
    then
    ;

: gol.ui.paint-grid  { | rows cols -- , paints the grid }
    ( initialized grid-src must exist )
    cr ." paint-grid" cr
    2darray_size grid-src   ( rows cols )
    -> cols
    -> rows
    rows 0 do
        cols 0 do
            j i grid-src
            j cell_height @ *
            i cell_width @ *
            gol.ui.paint-cell
        loop
    loop
    ;

: gol.ui.paint-initial  ( -- , paints the initial grid, all cells dead )
    0 0 grid-src grid-reset
    drop
    gol.ui.paint-grid
    ;

: gol.ui.init  ( -- , initialize intuition, graphics, window )
    gr.init
    (window.init)
    golwin-tmpl
    gr.openwindow golwin !
    golwin @ gr.set.curwindow
    gol.ui.paint-initial
    calc-cell-size!
    ;

: gol.ui.clean  ( -- , deinitialize window )
    gr.closecurw
    ;

\ ------------------------------------
\ --------- GOL UI -------------------
\ ------------------------------------

3 3 2darray grid-src     \ source array
3 3 2darray grid-dest    \ destination array

create blinker 0 c, 1 c, 0 c,
               0 c, 1 c, 0 c,
               0 c, 1 c, 0 c,

: gol-run  ( -- , opens window and runs main loop )
    blinker 0 0 grid-src 9 move
    gol.ui.init
    10 0 do
        gol.ui.paint-grid
        grid_newgen
        0 0 grid-dest  0 0 grid-src  9 move    \ copy dest grid to src grid
    loop
    ;

