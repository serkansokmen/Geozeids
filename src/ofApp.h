#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxBox2d.h"
#include "ofxCoreMotion.h"


#define     TOUCH_POINT_COUNT   5
#define     MAX_POINT_LENGTH    100
#define     REPEAT_RES          2

#define     MASS                16.f
#define     BOUNCINESS          .6f
#define     FRICTION            .75f

#define     BACKGROUND_COLOR    ofColor::black
#define     OBJECT_COLOR        ofColor::white


class Ripple : public ofxBox2dCircle {
    
    vector<ofVec2f>     prevPositions;
    
public:
    
    void setup(b2World * b2dworld, ofVec2f &pts, float radius) {
        ofxBox2dCircle::setup(b2dworld, pts.x, pts.y, radius);
        prevPositions.assign(MAX_POINT_LENGTH, pts);
    }
    
    void update(){
        prevPositions.push_back(getPosition());
        if (prevPositions.size() > MAX_POINT_LENGTH) {
            prevPositions.erase(prevPositions.begin());
        }
    };
    
    void draw(){
        
        int count = prevPositions.size();
        float alpha;
        float originalRadius;
        
        for (int i = 0; i < count; i+= REPEAT_RES) {
            
            ofVec2f pos = prevPositions[i];
            float a = pos.x * .0025;
            float b = pos.y * .0025;
            float c = getVelocity().normalized().length() / 2050.0;
            
            float noise = ofNoise(a, b, c);
//            float color = noise > 200 ? ofMap(noise, 200, 255, 0, 255) : 0;
            alpha = ofNormalize(i, 0.f, count) * 255.f;
            float radius = ofMap(i, 0, count, 0, getRadius()) * noise;
            originalRadius = getRadius();
            ofNoFill();
            ofSetColor(color, alpha);
            ofCircle(pos, radius);
        }
        ofSetColor(color, 255);
        ofCircle(prevPositions[prevPositions.size()-1], originalRadius);
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
    
    ofxCoreMotion   coreMotion;
    
    ofVec2f         touchStart;
    ofVec2f         touchEnd;
    
    vector< ofPtr<Ripple> > ripples;
};
