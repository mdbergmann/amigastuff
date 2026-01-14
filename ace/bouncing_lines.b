' Bouncing Color Cycling Lines for ACE BASIC
' Creates animated lines that bounce off window borders with cycling colors

' Get window width and height
GLOBAL fullWindowWidth
GLOBAL fullWindowHeight
GLOBAL windowWidth
GLOBAL windowHeight
GLOBAL fontHeight

' Number of lines
CONST numLines = 5
CONST numLinesArrEnd = numLines-1

STRUCT MyLine
  LONGINT startX
  LONGINT startY
  LONGINT endX
  LONGINT endY
  LONGINT deltaX1
  LONGINT deltaY1
  LONGINT deltaX2
  LONGINT deltaY2
  SHORTINT colori
END STRUCT

' arrax of LONGINTs to hold addresses
DIM lines&(numLines)

SUB dlog(STRING expr)
  PRINT #1, expr
END SUB

SUB InitConsole
  ' Open a console window to log stuff
  OPEN "O", #1, "CON:0/0/640/50/Debug window"
  dlog("Welcome...")
END SUB

SUB InitWindow
  ' Open window: ID=1, Title, Position (50,50)-(650,450), Type=31 (Standard)
  WINDOW 1, "Bouncing Color Lines", (50,50)-(650,450), 31
  ' Set window as current output window
  WINDOW OUTPUT 1
  ' Event handling for window
  ON WINDOW GOTO quit
  WINDOW ON

  ' Define our custom font for exact line height
  fontHeight = WINDOW(13)
  dlog("Font height: "+STR$(fontHeight))
END SUB

SUB DefineWindowSize
  fullWindowWidth = WINDOW(2)
  windowWidth = fullWindowWidth

  fullWindowHeight = WINDOW(3)
  windowHeight = fullWindowHeight-(4*fontHeight)
  ' dlog("Full winheight:"+STR$(fullWindowHeight)+", winheight:"+STR$(windowHeight))
END SUB

SUB ADDRESS NewLine
  NewLine = ALLOC(SIZEOF(MyLine))
END SUB

SUB InitLines
    SHARED lines&

    DECLARE STRUCT myLine *_line

    ' Initialize lines
    FOR i = 0 TO numLinesArrEnd
      lines&(i) = NewLine()
      dlog("Line&: "+STR$(lines&(i)))
      _line = lines&(i)
      dlog("_line&: "+STR$(_line))

      ' Random start positions
      _line->startX = INT(RND * (windowWidth - 100)) + 50
      _line->startY = INT(RND * (windowHeight - 100)) + 50
      _line->endX = INT(RND * (windowWidth - 100)) + 50
      _line->endY = INT(RND * (windowHeight - 100)) + 50

      ' Random movement directions (-3 to +3, but not 0)
      _line->deltaX1 = INT(RND * 7) - 3
      IF _line->deltaX1 = 0 THEN _line->deltaX1 = 1
      _line->deltaY1 = INT(RND * 7) - 3
      IF _line->deltaY1 = 0 THEN _line->deltaY1 = 1

      _line->deltaX2 = INT(RND * 7) - 3
      IF _line->deltaX2 = 0 THEN _line->deltaX2 = 1
      _line->deltaY2 = INT(RND * 7) - 3
      IF _line->deltaY2 = 0 THEN _line->deltaY2 = 1

      ' Random start color
      _line->colori = i+1

      dlog("sX ="+STR$(_line->startX)+",sY ="+STR$(_line->startY)+",col ="+STR$(_line->colori))
    NEXT i
END SUB

SUB ClearScreen
  LINE (0, 0)-(windowWidth, windowHeight), 0, BF
END SUB

SUB DrawLines
  SHARED lines&
  DECLARE STRUCT myLine *_line

  ' Draw and move all lines
  FOR i = 0 TO numLinesArrEnd
    _line = lines&(i)

    ' Move start point
    _line->startX = _line->startX + _line->deltaX1
    _line->startY = _line->startY + _line->deltaY1

    ' Move end point
    _line->endX = _line->endX + _line->deltaX2
    _line->endY = _line->endY + _line->deltaY2

    ' Collision detection for start point
    IF _line->startX <= 0 OR _line->startX >= windowWidth THEN _line->deltaX1 = -_line->deltaX1
    IF _line->startY <= 0 OR _line->startY >= windowHeight THEN _line->deltaY1 = -_line->deltaY1

    ' Collision detection for end point
    IF _line->endX <= 0 OR _line->endX >= windowWidth THEN _line->deltaX2 = -_line->deltaX2
    IF _line->endY <= 0 OR _line->endY >= windowHeight THEN _line->deltaY2 = -_line->deltaY2

    ' Keep within bounds
    IF _line->startX < 0 THEN _line->startX = 0
    IF _line->startX > windowWidth THEN _line->startX = windowWidth
    IF _line->startY < 0 THEN _line->startY = 0
    IF _line->startY > windowHeight THEN _line->startY = windowHeight

    IF _line->endX < 0 THEN _line->endX = 0
    IF _line->endX > windowWidth THEN _line->endX = windowWidth
    IF _line->endY < 0 THEN _line->endY = 0
    IF _line->endY > windowHeight THEN _line->endY = windowHeight

    ' Draw new line in color
    COLOR _line->colori, 0
    LINE (_line->startX, _line->startY)-(_line->endX, _line->endY)
  NEXT i
END SUB

frameCount = 0
startTime = TIMER
SUB DrawFPS
  SHARED frameCount, startTime

  ' Calculate and display FPS
  frameCount = frameCount + 1
  currentTime = TIMER
  elapsedTime = currentTime - startTime
  IF elapsedTime >= 1 THEN
    fps = frameCount / elapsedTime
    ' draw fps
    COLOR 3
    effFontHeight = fontHeight * 1.05
    yPosFloat = WINDOW(3) / effFontHeight
    yPosInt = INT(yPosFloat)
    'dlog("Effective fonthight:"+STR$(effFontHeight)+", yPosFloat:"+STR$(yPosFloat)+", yPosInt:"+STR$(yPosInt))
    LOCATE yPosInt, 1
    PRINT "FPS:"; INT(fps * 10) / 10;
    ' Reset counters
    frameCount = 0
    startTime = currentTime
  END IF
END SUB

' ------------------------
' Main area
' ------------------------

CALL InitConsole
CALL InitWindow
CALL DefineWindowSize
CALL InitLines
running = -1
WHILE running
  CALL DefineWindowSize
  CALL ClearScreen
  CALL DrawLines
  CALL DrawFPS

  ' wait
  SLEEP FOR 0.02
WEND

quit:
  running = 0
  WINDOW CLOSE 1
  CLOSE #1
END
