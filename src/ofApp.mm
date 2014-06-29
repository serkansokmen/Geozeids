#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    ofSetCircleResolution(100);
    ofBackground(0);
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    int delIndex = 0;
    for (auto ripple : ripples) {
        if (ripple.get()->isAlive()) {
            ripple.get()->update();
        } else {
            ripples.erase(ripples.begin() + delIndex);
        }
        delIndex ++;
    }
    
    ofLog() << ripples.size() << endl;
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    for (auto ripple : ripples) {
        ripple.get()->draw();
    }
    
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    ofPtr<Ripple> newRipple = ofPtr<Ripple>(new Ripple());
    newRipple.get()->setup(touch.id, ofColor(ofRandom(255), ofRandom(255), ofRandom(255)));
    
    bool bExists = false;
    for (auto ripple : ripples) {
        if (ripple.get()->getTouchId() == touch.id) {
            bExists = true;
        }
    }
    if (!bExists) ripples.push_back(newRipple);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    for (auto ripple : ripples) {
        if (ripple.get()->getTouchId() == touch.id) {
            ripple.get()->addPoint(touch);
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
