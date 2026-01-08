' Bouncing Color Cycling Lines for ACE BASIC
' Creates animated lines that bounce off window borders with cycling colors

' Open window: ID=1, Title, Position (50,50)-(650,450), Type=31 (Standard)
WINDOW 1, "Bouncing Color Lines", (50,50)-(650,450), 31

' Set window as current output window
WINDOW OUTPUT 1

DECLARE SUB DefineWindowSize

' Define our custom font for exact line height
GLOBAL fontHeight
fontHeight = 8
FONT "topaz", fontHeight
LOCATE 1, 1     ' reset cursor

' Get window width and height
GLOBAL fullWindowWidth
GLOBAL fullWindowHeight
GLOBAL windowWidth
GLOBAL windowHeight

CALL DefineWindowSize

' Number of lines
CONST numLines = 5
CONST numLinesArrEnd = numLines-1

' Arrays for line properties
DIM startX(numLinesArrEnd), startY(numLinesArrEnd), endX(numLinesArrEnd), endY(numLinesArrEnd)
DIM deltaX1(numLinesArrEnd), deltaY1(numLinesArrEnd), deltaX2(numLinesArrEnd), deltaY2(numLinesArrEnd)
DIM colorIndex(numLinesArrEnd)

' Color array (ACE BASIC standard colors)
DIM colors(7)
colors(0) = 1  ' Red
colors(1) = 2  ' Green
colors(2) = 3  ' Blue
colors(3) = 4  ' Cyan
colors(4) = 5  ' Magenta
colors(5) = 6  ' Yellow
colors(6) = 7  ' White
colors(7) = 8  ' Orange/Brown

' Initialize lines
FOR i = 0 TO numLinesArrEnd
  ' Random start positions
  startX(i) = INT(RND * (windowWidth - 100)) + 50
  startY(i) = INT(RND * (windowHeight - 100)) + 50
  endX(i) = INT(RND * (windowWidth - 100)) + 50
  endY(i) = INT(RND * (windowHeight - 100)) + 50
  
  ' Random movement directions (-3 to +3, but not 0)
  deltaX1(i) = INT(RND * 7) - 3
  IF deltaX1(i) = 0 THEN deltaX1(i) = 1
  deltaY1(i) = INT(RND * 7) - 3
  IF deltaY1(i) = 0 THEN deltaY1(i) = 1
  
  deltaX2(i) = INT(RND * 7) - 3
  IF deltaX2(i) = 0 THEN deltaX2(i) = 1
  deltaY2(i) = INT(RND * 7) - 3
  IF deltaY2(i) = 0 THEN deltaY2(i) = 1
  
  ' Random start color
  colorIndex(i) = INT(RND * 8)
NEXT i

' Event handling for window
ON WINDOW GOTO quit
WINDOW ON

' Main loop - Animation
running = -1
frameCount = 0
startTime = TIMER

SUB ClearScreen
  LINE (0, 0)-(windowWidth, windowHeight), 0, BF
END SUB

SUB DefineWindowSize
    fullWindowWidth = WINDOW(2)
    windowWidth = fullWindowWidth

    fullWindowHeight = WINDOW(3)
    windowHeight = fullWindowHeight-(4*fontHeight)
END SUB

WHILE running
  CALL DefineWindowSize
  CALL ClearScreen

  ' Draw and move all lines
  FOR i = 0 TO numLinesArrEnd
    ' Erase old line by drawing in background color
    ' COLOR 0, 0
    ' LINE (oldStartX(i), oldStartY(i))-(oldEndX(i), oldEndY(i))
    
    ' Move start point
    startX(i) = startX(i) + deltaX1(i)
    startY(i) = startY(i) + deltaY1(i)
    
    ' Move end point
    endX(i) = endX(i) + deltaX2(i)
    endY(i) = endY(i) + deltaY2(i)
    
    ' Collision detection for start point
    IF startX(i) <= 0 OR startX(i) >= windowWidth THEN deltaX1(i) = -deltaX1(i)
    IF startY(i) <= 0 OR startY(i) >= windowHeight THEN deltaY1(i) = -deltaY1(i)
    
    ' Collision detection for end point
    IF endX(i) <= 0 OR endX(i) >= windowWidth THEN deltaX2(i) = -deltaX2(i)
    IF endY(i) <= 0 OR endY(i) >= windowHeight THEN deltaY2(i) = -deltaY2(i)
    
    ' Keep within bounds
    IF startX(i) < 0 THEN startX(i) = 0
    IF startX(i) > windowWidth THEN startX(i) = windowWidth
    IF startY(i) < 0 THEN startY(i) = 0
    IF startY(i) > windowHeight THEN startY(i) = windowHeight
    
    IF endX(i) < 0 THEN endX(i) = 0
    IF endX(i) > windowWidth THEN endX(i) = windowWidth
    IF endY(i) < 0 THEN endY(i) = 0
    IF endY(i) > windowHeight THEN endY(i) = windowHeight
    
    ' Draw new line in color
    COLOR colors(colorIndex(i)), 0
    LINE (startX(i), startY(i))-(endX(i), endY(i))
  NEXT i
  
  ' Calculate and display FPS
  frameCount = frameCount + 1
  currentTime = TIMER
  elapsedTime = currentTime - startTime
  IF elapsedTime >= 1 THEN
    fps = frameCount / elapsedTime
    ' draw fps
    COLOR 3
    LOCATE INT(WINDOW(3)/fontHeight)-2, 1
    PRINT "FPS:"; INT(fps * 10) / 10;
    ' Reset counters
    frameCount = 0
    startTime = currentTime
  END IF

  ' wait
  SLEEP FOR 0.02
WEND

quit:
  running = 0
  WINDOW CLOSE 1
END
