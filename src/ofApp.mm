#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    ofSetCircleResolution(100);
    ofBackground(0);
    
    box2d.init();
    box2d.setGravity(0, 0);
    box2d.setFPS(60);
    box2d.createBounds();
    box2d.registerGrabbing();
    box2d.setIterations(1, 1);
}

//--------------------------------------------------------------
void ofApp::update(){
    
    box2d.update();
    for (auto ripple : ripples) {
        ripple.get()->update();
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground(0);
    for (auto ripple : ripples) {
        ripple.get()->draw();
    }
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    bool bMayAdd = true;
    for (auto ripple : ripples) {
        ofRectangle bounding(ripple.get()->getPosition(),
                             ripple.get()->getRadius(),
                             ripple.get()->getRadius());
        bMayAdd = !bounding.inside(touch);
    }
    if (bMayAdd) {
        ofPtr<Ripple> ripple(new Ripple());
        ripple.get()->setPhysics(initialMass, bounciness, friction);
        ripple.get()->setup(box2d.getWorld(), touch, 100);
        ripple.get()->touchId = touch.id;
        ripple.get()->color = ofColor(ofRandom(255),
                                      ofRandom(255),
                                      ofRandom(255));
        ripples.push_back(ripple);
    }
    
    ofLog() << touch.pressure << endl;
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    ofLog() << touch.pressure << endl;
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    ofLog() << touch.pressure << endl;
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
