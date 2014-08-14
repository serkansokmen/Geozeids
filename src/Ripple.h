//
//  Ripple.h
//  Geozeids
//
//  Created by Serkan Sökmen on 13/08/14.
//
//
#pragma once

#include "ofMain.h"
#include "ofxBox2dCircle.h"
#include "Constants.h"


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
        
        ofNoFill();
        
        for (int i = 0; i < count; i+= REPEAT_RES) {
            
            float radius = ofLerp(0, getRadius(), (float)i / count);
            float alpha = ofNormalize(radius, 0.f, getRadius()) * 255.f;
            
            ofSetColor(color, alpha);
            ofCircle(prevPositions[i], radius);
        }
        
        ofFill();
    };
    
    ofColor color;
    int     touchId;
};