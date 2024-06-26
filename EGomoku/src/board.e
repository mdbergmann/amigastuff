
OPT MODULE

EXPORT OBJECT t_size
    width: INT, height: INT
ENDOBJECT

EXPORT OBJECT board
    size: t_size
ENDOBJECT

PROC create() OF board
    PrintF('Create...\n')
    // default size
    self.setSize(19, 19)
ENDPROC

PROC end() OF board
    PrintF('End...\n')
ENDPROC

PROC setSize(width, height) OF board
    self.size.width := width
    self.size.height := height
ENDPROC

