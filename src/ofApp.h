#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxBox2d.h"
#include "ofxCoreMotion.h"
#include "Ripple.h"
#include "Constants.h"
#include "SoundData.h"


class ofApp : public ofxiOSApp {
	
public:
    void setup();
    void update();
    void draw();
    void exit();
	
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    // Contact listeners
	void contactStart(ofxBox2dContactArgs &e);
	void contactEnd(ofxBox2dContactArgs &e);
    
    
    // Box2d
    ofxBox2d        box2d;
    float           initialMass = 20.0f;
    float           friction = .8f;
    float           bounciness = 0.5f;
    
    ofxCoreMotion   coreMotion;
    
    ofVec2f         touchStart;
    ofVec2f         touchEnd;
    
    vector< ofPtr<Ripple> >             ripples;
    vector< ofPtr<ofxBox2dPolygon> >    polyShapes;
    
    ofSoundPlayer   rippleSound[4];
    
    ofPolyline      shape;
    float           gravityMultiplier;
    float           forceMultiplier;
    int             tailLength;
    
    bool            bColorize;
    bool            bRecordTouch;
    bool            breakupIntoTriangles;
};
