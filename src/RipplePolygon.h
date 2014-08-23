//
//  RipplePolygon.h
//  Geozeids
//
//  Created by Serkan Sökmen on 23/08/14.
//
//
//
//  Ripple.h
//  Geozeids
//
//  Created by Serkan Sökmen on 13/08/14.
//
//
#pragma once

#include "ofMain.h"
#include "ofxBox2dPolygon.h"
#include "Constants.h"


class RipplePolygon : public ofxBox2dPolygon {
    
    vector<ofPoint> prevPositions;
    
    ofPoint         forcePos;
    ofPoint         field;
    
    int     tailLength;
    float   complexity = 56;    // wind complexity
    float   timeSpeed = .07;    // wind variation speed
    float   phase = TWO_PI;     // separate u-noise from v-noise
    float   t = 0.f;
    
public:
    
    void setup(const ofPolyline &polygon, const int length) {
        
        tailLength = length;
        prevPositions.assign(length, ofPoint(getPosition()));
    };
    
    void update(){
        
        prevPositions.push_back(getPosition());
        if (prevPositions.size() > tailLength) {
            prevPositions.erase(prevPositions.begin());
        }
        
        t = ofGetFrameNum() * timeSpeed;
        
        forcePos = getPosition();
        field = getField(forcePos + getVelocity());
        float speed = (getArea() + ofNoise(t, field.x, field.y));
        forcePos.x += ofLerp(-speed, speed, field.x);
        forcePos.y += ofLerp(-speed, speed, field.y);
        
        //addAttractionPoint(forcePos, pow(getArea(), 2) * ofRandom(forceMultiplier));
    };
    
    void draw(){
		
        ofNoFill();
        ofSetColor(color);
        ofxBox2dPolygon::draw();
        
        ofFill();
    };
    
    ofPoint getField(ofPoint position) {
        float normx = ofNormalize(position.x, 0, ofGetWidth());
        float normy = ofNormalize(position.y, 0, ofGetHeight());
        float u = ofNoise(t + phase, normx * complexity + phase, normy * complexity + phase);
        float v = ofNoise(t - phase, normx * complexity - phase, normy * complexity + phase);
        return ofPoint(u, v);
    }
    
    ofColor         color;
    float           forceMultiplier;
    int             touchId;
};