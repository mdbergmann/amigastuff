PRINT "Press CTRL-c close windows..."
ON BREAK GOTO quit
BREAK ON

#include <graphics/clip.h>
#include <graphics/rastport.h>
#include <graphics/gfx.h>

LIBRARY "graphics.library"

DECLARE FUNCTION InitArea( STRUCTPTR areaInfo, APTR vectorBuffer, LONGINT maxVectors ) LIBRARY graphics
DECLARE FUNCTION InitTmpRas( STRUCTPTR tmpRas, ADDRESS buffer, LONGINT _SIZE ) LIBRARY graphics
DECLARE FUNCTION DrawEllipse( STRUCTPTR rp, LONGINT xCenter, LONGINT yCenter, LONGINT a, \
                                      LONGINT b ) LIBRARY graphics
DECLARE FUNCTION LONGINT AreaEllipse( STRUCTPTR rp, LONGINT xCenter, LONGINT yCenter, LONGINT a, \
                                      LONGINT b ) LIBRARY graphics
DECLARE FUNCTION LONGINT AreaEnd( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION SetAPen( STRUCTPTR rp, LONGINT pen ) LIBRARY graphics

CONST w_width = 640
CONST w_height = 480

SUB draw_circle(rp, x, y, radius, col, fill)
    IF fill THEN
        SetAPen(rp, col)
        AreaEllipse(rp, x, y, radius, radius)
        AreaEnd(rp)
    ELSE
        CIRCLE (x,y), radius, col,,,1.0
    END IF
END SUB

SUB circle_coords(center_x, center_y, radius, angle, ADDRESS ret_x, ADDRESS ret_y)
    rad = (angle * 3.14) / 180
    cos_a = COS(rad)
    'PRINT "cos_a: ";cos_a
    sin_a = SIN(rad)
    'PRINT "sin_a: ";sin_a
    *%ret_x := center_x + CINT(cos_a * radius)
    *%ret_y := center_y + CINT(sin_a * radius)
END SUB

SUB draw_circle_obj(rp, x, y, radius, angle_from, angle_to, angle_step, obj_radius, obj_fill, obj_col)
    LET x_a% = 0
    LET y_a% = 0
    FOR angle=angle_from TO angle_to STEP angle_step
        circle_coords(x, y, radius, angle, @x_a%, @y_a%)
        'PRINT "x_a, y_a: ";x_a;y_a
        IF obj_radius = 0 THEN
            PSET (x_a%, y_a%), obj_col
        ELSE
            draw_circle(rp, x_a%, y_a%, obj_radius, obj_col, obj_fill)
        END IF
    NEXT
END SUB

SUB moving_circle(ADDRESS rp)
    p_x = w_width/2
    p_y = w_height/2
    draw_circle(rp, p_x, p_y, 10, 1, 1)
    draw_step = 1
    LET angle% = 0
    PRINT "START: ";TIME$
    FOR i=0 TO 0
    angle%=0
    WHILE angle%<360  ' ctrl-c in place
        draw_circle_obj(rp, p_x, p_y, 50, angle%, angle%, draw_step, 5, 1, 0)
        draw_circle_obj(rp, p_x, p_y, 50, angle%+draw_step, angle%+draw_step, draw_step, 5, 1, 1)
        SLEEP FOR 0.02
        angle% = angle% + draw_step
        'IF angle% = 360 THEN angle% = 0
    WEND
    NEXT
    PRINT "END: ";TIME$
    ' 24 secs
END SUB

'SCREEN 1,320,240,4,1

CONST maxvectors = 200
CONST areaBufSize = maxvectors * 5
DIM areabuffer(areaBufSize)

DECLARE STRUCT AreaInfo areainfo
DECLARE STRUCT TmpRas tmpras
DECLARE STRUCT RastPort *scrRp

WINDOW 1,"Planets",(0,0)-(w_width,w_height)
scrRp = WINDOW(8)

InitArea(@areainfo, @areabuffer(0), maxvectors)
scrRp->AreaInfo = @areainfo

tmprasBufSize% = w_width * w_height
tmprasBuffer& = ALLOC(tmprasBufSize, 3)
IF tmprasBuffer = 0 THEN
    PRINT "Unable to allocate memory for TmpRas!"
    STOP
END IF
rassize = 38400 ' w_height& * (SHR(w_width&+15, 3) AND &HFFFE)
PRINT "RASSIZE: ";rassize
InitTmpRas(@tmpras, tmprasBuffer, rassize)
scrRp->TmpRas = @tmpras

SetAPen(scrRp, 1)
stat = AreaEllipse(scrRp, 120, 120, 10, 10)
PRINT "AreaEllipse result: ";stat
stat = AreaEnd(scrRp)
PRINT "AreaEnd result: ";stat
DrawEllipse(scrRp, 120, 120, 30, 30)  'OK

'moving_circle(srcRp)

'wait for ctrl-c
WHILE -1
    SLEEP
WEND

quit:
    WINDOW CLOSE 1
    'SCREEN CLOSE 1

    LIBRARY CLOSE "graphics.library"

    PRINT "Ending..."
END

