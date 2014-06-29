#pragma once

#include "ofMain.h"
#include "ofxiOS.h"


#define     TOUCH_POINT_COUNT   5
#define     MAX_POINT_LENGTH    100




class Ripple {
    
    ofVec2f                     center;
    ofColor                     color;
    
    int                         touchId;
    bool                        bIsAlive;
    vector< ofPtr<ofVec2f> >    points;
    
public:
    
    void setup(const int & touchId, const ofColor &color){
        
        this->touchId = touchId;
        this->color = ofColor(color);
        this->bIsAlive = true;
    };
    
    void update(){
        
        if (points.size() > MAX_POINT_LENGTH) {
            points.erase(points.begin());
        } else {
            if (points.size() > 0) {
                center = *points.back().get();
                addPoint(center);
            }
        }
    };
    
    void draw(){
        
        if (bIsAlive) {
            ofNoFill();
            ofSetColor(color);
            for (int j=0; j<points.size(); j++) {
                
                float norm = ofNormalize(j, 0.f, (float)points.size());
                float alpha = norm * 255.f;
                float radius = points.size() / norm;
                
                ofSetColor(color, alpha);
                ofCircle(points[j].get()->x, points[j].get()->y, radius);
            }
        }
    };
    
    const int & getTouchId(){
        return this->touchId;
    };
    
    const bool & isAlive() {
        return this->bIsAlive;
    };
    
    void addPoint(const ofVec2f &pos) {
        this->points.push_back(ofPtr<ofVec2f>(new ofVec2f(pos)));
    };
    
    void kill(){
        this->bIsAlive = false;
    };
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
    
    vector< ofPtr<Ripple> > ripples;
};
