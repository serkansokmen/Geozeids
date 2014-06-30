#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxBox2d.h"


#define     TOUCH_POINT_COUNT   5
#define     MAX_POINT_LENGTH    100




class Ripple : public ofxBox2dCircle {
    
    vector<ofVec2f> prevPositions;
    
public:
    
    void update(){
        prevPositions.push_back(getPosition());
        if (prevPositions.size() > MAX_POINT_LENGTH) {
            prevPositions.erase(prevPositions.begin());
        }
    };
    
    void draw(){
        
        int count = prevPositions.size();
        for (int i = 0; i < count; i++) {
            float alpha = ofNormalize(i, 0.f, count) * 255.f;
            float radius = ofMap(i, 0, count, 0, getRadius());
            ofNoFill();
            ofSetColor(color, alpha);
            ofCircle(prevPositions[i], radius);
        }
    };
    
    ofColor color;
    int     touchId;
};




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
    
    
    // Box2d
    ofxBox2d        box2d;
    float           initialMass = 20.0f;
    float           friction = .8f;
    float           bounciness = 0.5f;
    
    vector< ofPtr<Ripple> > ripples;
};
