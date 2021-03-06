#include "ofMain.h"
#include "ofAppiOSWindow.h"
#include "ofApp.h"

int main(){
    
    ofAppiOSWindow *iOSWindow = new ofAppiOSWindow();
    iOSWindow->enableDepthBuffer();
    iOSWindow->enableAntiAliasing(4);
    iOSWindow->enableRendererES2();
    if(iOSWindow->isRetinaSupportedOnDevice()) iOSWindow->enableRetina();
    iOSWindow->enableHardwareOrientation();
    iOSWindow->enableOrientationAnimation();
    
    ofSetupOpenGL(iOSWindow, 1024,768, OF_FULLSCREEN);
    ofRunApp(new ofApp());
}
