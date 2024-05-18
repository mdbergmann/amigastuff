PRINT "Press CTRL-c close windows..."
ON BREAK GOTO quit
BREAK ON

CONST w_width = 320
CONST w_height = 240

SUB lines(n)
    FOR i=1 TO n
        COLOR i MOD 255
        LINE (RND*w_width, RND*w_height) - (RND*w_width, RND*w_height)
    NEXT
END SUB

SUB areas
    a = 10 : b = 10 : c = 100 : d = 100

    LINE(a,b)-(c,b)
    LINE(c,b)-(c,d)
    LINE(c,d)-(a,d)
    LINE(a,d)-(a,b)

    AREA (10,150)
    AREA STEP (0, 100)
    AREA STEP (100, 0)
    AREA STEP (0, -100)
    AREAFILL
END SUB

SUB points
    FOR x=1 TO w_width-1
        FOR y=1 TO w_height-1
            COLOR RND*256
            PSET (x,y)
        NEXT
    NEXT
END SUB

SUB draw_circle(x, y, radius, col, fill)
    CIRCLE (x,y), radius, col,,,1.0
    IF fill THEN
        PAINT (x,y), col
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

SUB draw_circle_obj(x, y, radius, angle_from, angle_to, angle_step, obj_radius, obj_fill, obj_col)
    LET x_a% = 0
    LET y_a% = 0
    FOR angle=angle_from TO angle_to STEP angle_step
        circle_coords(x, y, radius, angle, @x_a%, @y_a%)
        'PRINT "x_a, y_a: ";x_a;y_a
        IF obj_radius = 0 THEN
            PSET (x_a%, y_a%), obj_col
        ELSE
            draw_circle(x_a%, y_a%, obj_radius, obj_col, obj_fill)
        END IF
    NEXT
END SUB

SUB moving_circle
    p_x = w_width/2
    p_y = w_height/2
    draw_circle(p_x, p_y, 10, 1, 1)
    draw_step = 1
    LET angle% = 0
    PRINT "START: ";TIME$
    FOR i=0 TO 1
    angle%=0
    WHILE angle%<360  ' ctrl-c in place
        draw_circle_obj(p_x, p_y, 50, angle%, angle%, draw_step, 0, 1, 0)
        draw_circle_obj(p_x, p_y, 50, angle%+draw_step, angle%+draw_step, draw_step, 0, 1, 1)
        SLEEP FOR 0.02
        angle% = angle% + draw_step
        'IF angle% = 360 THEN angle% = 0
    WEND
    NEXT
    PRINT "END: ";TIME$
    ' 24 secs
END SUB

SCREEN 1,320,240,4,1

{
WINDOW 1,"Lines",(0,0)-(w_width,w_height),,1
PRINT "drawing lines"
lines(500)

WINDOW 2,"Areas",(0,0)-(w_width,w_height),,1
PRINT "Drawing areas"
areas()

WINDOW 3,"Points",(0,0)-(w_width,w_height),,1
PRINT "Drawing points"
'points()

WINDOW 4,"CIRCLE",(0,0)-(w_width,w_height),,1
}
PRINT "Drawing circle"
moving_circle()

'wait for ctrl-c
WHILE -1
    SLEEP
WEND

quit:
    'WINDOW CLOSE 1
    'WINDOW CLOSE 2
    'WINDOW CLOSE 3
    'WINDOW CLOSE 4
    SCREEN CLOSE 1
    PRINT "Ending..."

END

