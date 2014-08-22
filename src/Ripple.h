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
    ofVec2f forcePos;
    ofVec2f field;
    int     tailLength;
    
    float   complexity = 56;    // wind complexity
    float   timeSpeed = .07;    // wind variation speed
    float   phase = TWO_PI;     // separate u-noise from v-noise
    float   t = 0.f;
    
public:
    
    void setup(b2World * b2dworld, ofVec2f &pts, float radius, int length = 10) {
        ofxBox2dCircle::setup(b2dworld, pts.x, pts.y, radius);
        tailLength = length;
        prevPositions.assign(length, pts);
    }
    
    void update(){
        
        prevPositions.push_back(getPosition());
        if (prevPositions.size() > tailLength) {
            prevPositions.erase(prevPositions.begin());
        }
        
        t = ofGetFrameNum() * timeSpeed;

        forcePos = getPosition();
        field = getField(forcePos + getVelocity());
        float speed = (getRadius() + ofNoise(t, field.x, field.y));
        forcePos.x += ofLerp(-speed, speed, field.x);
        forcePos.y += ofLerp(-speed, speed, field.y);
        
        
        ofLog() << "Position: " << getPosition() << ", Force: " << forcePos << ", Time: " << t << endl;
        addAttractionPoint(forcePos, pow(getRadius(), 2) * ofRandom(forceMultiplier));
    };
    
    void draw(){
        
        int count = prevPositions.size();
        
        ofNoFill();
        
        for (int i = 0; i < count; i+= REPEAT_RES) {
            
            float radius = ofLerp(0, getRadius(), (float)i / count);
            float alpha = ofNormalize(radius, 0.f, getRadius()) * 255.f;
            ofVec2f pos = prevPositions[i];
            
            ofSetColor(color, alpha);
            ofCircle(pos, radius);
        }
        
        ofFill();
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