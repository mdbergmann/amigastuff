OPT PREPROCESS

MODULE 'intuition/screens', 'graphics/gfx', 'dos/dos', 'dos/datetime'
MODULE 'Picasso96', 'Picasso96api'

DEF dt: datetime, ds: PTR TO datestamp
DEF day[50]: ARRAY, date[50]: ARRAY,time[50]: ARRAY

PROC main()
    DEF screen=NIL: PTR TO screen
    DEF ri=NIL: PTR TO renderinfo
    DEF height, width, depth, buf_size, bpp, bpr
    DEF bitmap_buf=NIL
    DEF outfile=NIL, outfile_name[64]: STRING
    DEF loop_count=0

    ->OpenDevice('timer.device', 0, timerreq, 0)
    ->timerbase:= timerreq.io

    IF (p96base:= OpenLibrary('Picasso96API.library', 2)) = NIL
        logDebug('Unable to open Picasso96 library\n', [])
        Exit(1)
    ENDIF

    IF (screen:= Pi96OpenScreenTagList([
        P96SA_WIDTH, 640,
        P96SA_HEIGHT, 480,
        P96SA_DEPTH, 8,
        P96SA_AUTOSCROLL, TRUE,
        P96SA_TITLE, 'MyScreen', NIL])) = NIL
        logDebug('Unable to open screen!\n', [])
    ELSE
        logDebug('Opened screen!\n', [])

        width:= screen.width
        height:= screen.height
        depth:= screen.bitmap.depth
        bpp:= depth/8
        bpr:= width*bpp
        buf_size:= Mul(width*height, bpp)
        bitmap_buf:= New(buf_size)

        logDebug('Screen width: \d, height: \d, bpp: \d, depth: \d\n', [width, height, bpp, depth])
        logDebug('Screen buffer size: \d, bytes per row: \d\n', [buf_size, bpr])

        NEW ri
        ri.memory:= bitmap_buf
        ri.bytesperrow:= width*bpp
        ri.rgbformat:= RGBFB_R8G8B8

        FOR loop_count:= 0 TO 10
            logDebug('Processing image: \d...\n', [loop_count])

            logDebug('Reading pixel array from screen...\n', [])
            Pi96ReadPixelArray(ri, 0, 0, screen.rastport, 0, 0, width, height)
            logDebug('Reading pixel array from screen...done\n', [])

            logDebug('Opening file for writing...\n', [])
            StringF(outfile_name, 'Work:image_\d.rgb', loop_count)
            IF (outfile:= Open(outfile_name, MODE_NEWFILE)) <> NIL
                logDebug('Opening file: \s for writing...done\n', [outfile_name])
                logDebug('Writing image data...\n', [])
                Write(outfile, bitmap_buf, buf_size)
                Flush(outfile)
                logDebug('Writing image data...done\n', [])


                ->Delay(1000)
                logDebug('Closing file...\n', [])
                Close(outfile)
                logDebug('Closing file...done\n', [])
            ELSE
                logDebug('ERROR: cannot open file!\n', [])
            ENDIF

            logDebug('Processing image: \d...done\n', [loop_count])
        ENDFOR

        END ri
        Dispose(bitmap_buf)

        logDebug('Closing screen!\n', [])
        Pi96CloseScreen(screen)

    ENDIF

    ->CloseDevice(timerreq)
    CloseLibrary(p96base)
ENDPROC

PROC logDebug(fmtstring, args)
    DEF outfmt[256]: STRING
    DEF arg_list[10]: LIST

    ds:= DateStamp(dt.stamp)
    dt.format:= FORMAT_DOS
    dt.flags:= DTF_SUBST
    dt.strday:= day
    dt.strdate:= date
    dt.strtime:= time

    IF DateToStr(dt)
        ListAdd(arg_list, [date, time, ds.tick])
        ListAdd(arg_list, args)
        StrCopy(outfmt, '\s:\s:\d - ',)
        StrAdd(outfmt, fmtstring)
        VfPrintf(stdout, outfmt, arg_list)
    ENDIF

ENDPROC

