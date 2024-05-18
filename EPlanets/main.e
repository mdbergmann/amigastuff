-> draw ellipse on screen

OPT PREPROCESS

MODULE 'intuition/screens',
        'intuition/intuition',
        'graphics/gfxbase',
        'graphics/rastport',
        'graphics/gfxmacros',
        'dos/dos'

CONST SCRW=320,SCRH=240

DEF center_x, center_y
DEF screen, win:PTR TO window

PROC calcEllipseRad(radius, angle)
    DEF rad,x_a,y_a,str[20]:STRING
    rad := (angle! * 3.14) / 180.0
    ->PrintF('rad: \s\n', RealF(str, rad, 8))
    x_a := (radius! * Fcos(rad))
    y_a := (radius! * Fsin(rad))
    ->PrintF('x_a,y_a: \s,\s\n', RealF(str, x_a, 8), RealF(str, y_a, 8))
ENDPROC !x_a!,!y_a!

PROC drawCircle(x, y, radius, col, fill)
    DEF stat
    SetAPen(stdrast, col)
    IF fill
        DrawEllipse(win.rport, x, y, radius, radius)
        SetOPen(stdrast, col)
        stat:=Flood(stdrast, 0, x, y)
        PrintF('Flood stat: \d\n', stat)
    ELSE
        DrawEllipse(win.rport, x, y, radius, radius)
    ENDIF
ENDPROC

PROC drawEllipseObj(x, y, radius, angleFrom, angleTo, angleStep, objRadius, objCol, objFill)
    DEF x_a, y_a, eff_x, eff_y, angle
    FOR angle:=angleFrom TO angleTo
        x_a, y_a := calcEllipseRad(radius, angle)
        eff_x := x_a+x
        eff_y := y_a+y
        IF objRadius = 0
            Plot(eff_x, eff_y, objCol)
        ELSE
            drawCircle(eff_x, eff_y, objRadius, objCol, objFill)
        ENDIF
    ENDFOR
ENDPROC

PROC logTime(label)
    DEF ds:datestamp
    DateStamp(ds)
    PrintF('\s - Min:\d Ticks:\d\n', label, ds.minute, ds.tick)
ENDPROC

CONST AREASIZE=200

PROC main()
    DEF i, angle, angleStep, drawCol, voidCol, baseRadius
    DEF area:PTR TO areainfo
    DEF tras:PTR TO tmpras
    DEF areabuf[AREASIZE]:ARRAY
    DEF planePtr

    center_x := SCRW/2
    center_y := SCRH/2

    IF screen:=OpenS(SCRW,SCRH,4,0,'My Screen')
        IF win:=OpenW(0,0,SCRW-1,SCRH-1,$200,$F,'My Window',screen,15,NIL)
            PrintF('Allocating raster...\n')
            planePtr := AllocRaster(SCRW, SCRH)
            PrintF('Init Area...\n')
            InitArea(area, areabuf, (AREASIZE*2)/5)
            win.rport.areainfo := area
            PrintF('Init TmpRas...\n')
            InitTmpRas(tras, planePtr, SCRW*SCRH)
            win.rport.tmpras := tras
            SetDrMd(stdrast, 0)

            PrintF('Bitmap PTR: \d\n', win.rport.bitmap)

            PrintF('Drawing Elippse...\n')
            drawCircle(center_x, center_y, 10, 1, TRUE)
            PrintF('Drawing Ellipse...done\n')

            angleStep := 1
            drawCol := 1
            voidCol := 0
            baseRadius := 50

            logTime('START')

            FOR i:=0 TO 0
                FOR angle:=0 TO 359
                    drawEllipseObj(center_x, center_y, baseRadius, angle,   angle,   angleStep, 0, voidCol, TRUE)
                    drawEllipseObj(center_x, center_y, baseRadius, angle+1, angle+1, angleStep, 0, drawCol, TRUE)
                    Delay(1) -> ticks
                ENDFOR
            ENDFOR

            logTime('END')

            WHILE Mouse()<>1 DO NOP
            FreeRaster(planePtr, SCRW, SCRH)
            PrintF('Closing...\n')
            CloseW(win)
        ENDIF
    CloseS(screen)
    ENDIF
    CleanUp(0)
ENDPROC
