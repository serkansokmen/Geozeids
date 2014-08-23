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
#include "RippleBase.h"
#include "Constants.h"

class RippleCircle : public ofxBox2dCircle {
    
    vector<ofVec2f> prevPositions;
    ofVec2f         forcePos;
    ofVec2f         field;
    ofShader        shader;
    
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
        
        shader.load("shaders/vert.glsl", "shaders/frag.glsl");
    }
    
    void update(){
        
        prevPositions.push_back(ofxBox2dCircle::getPosition());
        if (prevPositions.size() > tailLength) {
            prevPositions.erase(prevPositions.begin());
        }
        
        t = ofGetFrameNum() * timeSpeed;

        forcePos = ofxBox2dCircle::getPosition();
        field = getField(forcePos + ofxBox2dCircle::getVelocity());
        float speed = (getRadius() + ofNoise(t, field.x, field.y));
        forcePos.x += ofLerp(-speed, speed, field.x);
        forcePos.y += ofLerp(-speed, speed, field.y);
        
        addAttractionPoint(forcePos, pow(getRadius(), 2) * ofRandom(forceMultiplier));
    };
    
    void draw(){
        
        if (useShader) {
            shader.begin();
        }
		
        int count = prevPositions.size();
        
        ofNoFill();
        
        if (useShader) {
            shader.setUniform1f("timeValX", t * 0.1 );
            shader.setUniform1f("timeValY", -t * 0.18 );
            shader.setUniform2f("mouse", getPosition().x, getPosition().y);
        }
        
        for (int i = 0; i < count; i+= REPEAT_RES) {
            
            float radius = ofLerp(0, getRadius(), (float)i / count);
            float alpha = ofNormalize(radius, 0.f, getRadius()) * 255.f;
            ofVec2f pos = prevPositions[i];
            
            ofSetColor(color, alpha);
            ofCircle(pos, radius);
        }
        
        ofFill();
        
        if (useShader) {
            shader.end();
        }
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
    bool    useShader;
};