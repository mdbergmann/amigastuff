#include <exec/types.h>
#include <exec/tasks.h>

#include <graphics/gfxbase.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>
#include <math.h>

struct Library *GfxBase = NULL;
struct Library *IntuitionBase = NULL;

struct Window *win = NULL;
struct RastPort *rport = NULL;

UWORD wWidth, wHeight, wCenterX, wCenterY;

APTR tmpbuf = NULL;

void cleanup() {
	if(GfxBase)
		CloseLibrary(GfxBase);
	if(IntuitionBase)
		CloseLibrary(IntuitionBase);
	if(tmpbuf)
		FreeVec(tmpbuf);
	if(win)
		CloseWindow(win);
}

void openLibs() {
	if(!(GfxBase = OpenLibrary("graphics.library", 39L))) {
		printf("Unable to open gfx library!\n");
		cleanup();
		exit(1);
	}
	printf("Gfx lib opened.\n");

	if(!(IntuitionBase = OpenLibrary("intuition.library", 39L))) {
		printf("Unable to open intuition library!\n");
		cleanup();
		exit(1);
	}
	printf("Intuition lib opened!\n");
}

void openWindow() {
	if(!(win = OpenWindowTags(NULL,
		WA_NoCareRefresh, TRUE,
		WA_Activate, TRUE,
		WA_Borderless, FALSE,
		WA_Backdrop, FALSE,
		WA_CloseGadget, TRUE,
		WA_Title, "My Window",
		WA_IDCMP, IDCMP_CLOSEWINDOW,
		TAG_DONE
	))) {
		printf("Unable to open window!\n");
		cleanup();
		exit(1);
	}
	printf("Window opened.\n");
}

void drawEllipse(LONG x, LONG y, LONG rad_x, LONG rad_y, BOOL fill, UWORD col) {
	SetAPen(rport, col);
	if(fill) {
		AreaEllipse(rport, x, y, rad_x, rad_y);
		AreaEnd(rport);
	}
	else {
		DrawEllipse(rport, x, y, rad_x, rad_y);
	}
}

void calcEllipseRad(LONG radius, LONG angle, LONG *x_a, LONG *y_a) {
	double rad;
	rad = (angle * PI) / 180;
	*x_a = (LONG)((double)radius * cos(rad));
	*y_a = (LONG)((double)radius * sin(rad));
}

void drawTrabant(LONG x, LONG y, LONG radius, LONG radTrabant, UWORD col) {
	LONG x_a, y_a, eff_x, eff_y, angle;

	for(angle = 0;angle < 359;angle++) {
		calcEllipseRad(radius, angle, &x_a, &y_a);
		eff_x = x_a+x;
		eff_y = y_a+y;
		//printf("Drawing ellipse: %d, %d\n", eff_x, eff_y);
		drawEllipse(eff_x, eff_y, radTrabant, radTrabant, TRUE, 0);

		calcEllipseRad(radius, angle+1, &x_a, &y_a);
		eff_x = x_a+x;
		eff_y = y_a+y;
		drawEllipse(eff_x, eff_y, radTrabant, radTrabant, TRUE, col);

		Delay(1);
	}
}

#define MAXVECTORS 200
struct AreaInfo areaInfo;
struct TmpRas tmpRas;
BYTE areabuf[MAXVECTORS*5];

void setupDrawEnv() {
	ULONG tmpbufSize = 0;

	wWidth = win->Width;
	wHeight = win->Height;
	wCenterX = wWidth/2;
	wCenterY = wHeight/2;

	tmpbufSize = wWidth * wHeight;
	rport = win->RPort;

	printf("Init AreaInfo...\n");
	InitArea(&areaInfo, &areabuf[0], MAXVECTORS);
	rport->AreaInfo = &areaInfo;
	printf("Init AreaInfo...done\n");

	printf("Init TmpRas...\n");
	tmpbuf = AllocVec(tmpbufSize, MEMF_CHIP | MEMF_CLEAR);
	InitTmpRas(&tmpRas, tmpbuf, RASSIZE(wWidth, wHeight));
	rport->TmpRas = &tmpRas;
	printf("Init TmpRas...done\n");
}

void drawLoop() {
	ULONG i = 0;
	printf("Entering draw loop...\n");

	//drawEllipse(wCenterX, wCenterY, 20, 20, TRUE, 2);

	while(TRUE) {
		printf("Draw loop...\n");

		//drawTrabant(wCenterX, wCenterY, 50, 5, 1);
		for(i = 0;i < 100000;i++)
	}

	printf("Exiting draw loop.\n");
}

char *taskName = "PlanetsLoop";
struct Task *task = NULL;
ULONG STACK_SIZE = 4096L;
BOOL appLoopDone = FALSE;

void handleMessagesLoop() {
	struct IntuiMessage *imsg;

	printf("Handle messages loop...\n");

	while(!appLoopDone) {
		printf("Waiting for sigbit...\n");
		Wait(1L << win->UserPort->mp_SigBit);

		while(imsg = (struct IntuiMessage*) GetMsg(win->UserPort)) {
			printf("Received msg: %d\n", imsg->Code);
			ReplyMsg((struct Message*)imsg);

			switch (imsg->Class) {
				case IDCMP_CLOSEWINDOW:
					printf("Close gadget pressed...\n");
					appLoopDone = TRUE;
					break;
				default:
					printf("Unknown message!\n");
					break;
			}
		}
	}

	printf("Exiting handle messages loop.\n");
}

void main(int argc, char *argv[]) {
	//openLibs();
	//openWindow();
	//setupDrawEnv();

	task = CreateTask(taskName, 0, drawLoop, STACK_SIZE);
	if(!task) {
		printf("Unable to create task!\n");
		cleanup();
		exit(1);
	}

	//handleMessagesLoop();

	printf("Forbid...\n");
	Forbid();
	printf("Delete task...\n");
	DeleteTask(task);
	printf("Permit...\n");
	Permit();

	printf("Cleaning up...\n");
	cleanup();

	printf("Exiting...\n");
	exit(0);
}

