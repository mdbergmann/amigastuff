/* -----------------------------------------------------------------------------

  <insert project description here>

*/

/* includes */

#include <iostream>
#include "swlog.h"
#include "filemgr.h"
#include "swconfig.h"
#include "swmgr.h"

using namespace std;
using namespace sword;

/* prototypes */

extern int main(int argc, char **argv);

int main(int argc, char **argv) {
    cout << "Hello World!" << endl;

    SWLog log = SWLog();
    log.setLogLevel(SWLog::LOG_DEBUG);
    SWLog::setSystemLog(&log);
    log.logDebug("%s", "Hello World!");

    FileMgr *fileMgr = FileMgr::getSystemFileMgr();
    SWBuf home = fileMgr->getHomeDir();
    cout << "Homedir: " << home.c_str() << endl;

    SWConfig config("mysettings");
    config["Colors"]["Background"] = "red";
    cout << "Background: " << config["Colors"]["Background"] << endl;
    config.save();

    log.logDebug("Creating SWMgr...");
    SWMgr swMgr = SWMgr("S:sword");

    return 0;
}

