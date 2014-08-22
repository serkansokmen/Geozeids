//
//  RippleBase.h
//  Geozeids
//
//  Created by Serkan Sökmen on 22/08/14.
//
//
#pragma once

#include "ofMain.h"
#include "ofxBox2dBaseShape.h"
#include "Constants.h"

class RippleBase : public ofxBox2dBaseShape {
    
    vector<ofVec2f>     prevPositions;
    ofVec2f forcePos;
    ofVec2f field;
    
    float   complexity = 56;    // wind complexity
    float   timeSpeed = .07;    // wind variation speed
    float   phase = TWO_PI;     // separate u-noise from v-noise
    float   t = 0.f;
    
    float   size;
    
    int     tailLength;
    
public:
    
    virtual void draw() = 0;
    
    void update(){
        
        prevPositions.push_back(getPosition());
        if (prevPositions.size() > tailLength) {
            prevPositions.erase(prevPositions.begin());
        }
        
        t = ofGetFrameNum() * timeSpeed;
        
        forcePos = getPosition();
        field = getField(forcePos + getVelocity());
        float speed = (size + ofNoise(t, field.x, field.y));
        forcePos.x += ofLerp(-speed, speed, field.x);
        forcePos.y += ofLerp(-speed, speed, field.y);
        
        
        ofLog() << "Position: " << getPosition() << ", Force: " << forcePos << ", Time: " << t << endl;
        addRepulsionForce(forcePos, size/2, pow(size, 2) * ofRandom(forceMultiplier));
    };
    
    ofVec2f getField(ofVec2f position) {
        float normx = ofNormalize(position.x, 0, ofGetWidth());
        float normy = ofNormalize(position.y, 0, ofGetHeight());
        float u = ofNoise(t + phase, normx * complexity + phase, normy * complexity + phase);
        float v = ofNoise(t - phase, normx * complexity - phase, normy * complexity + phase);
        return ofVec2f(u, v);
    }
    
    ofColor color;
    float   forceMultiplier;
    int     touchId;
};