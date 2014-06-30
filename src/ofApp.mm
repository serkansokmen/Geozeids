#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    ofSetCircleResolution(100);
    ofBackground(0);
    
    coreMotion.setupAttitude(CMAttitudeReferenceFrameXMagneticNorthZVertical);
    
    box2d.init();
    box2d.setGravity(0, 0);
    box2d.setFPS(60);
    box2d.createBounds();
    box2d.registerGrabbing();
    box2d.setIterations(1, 1);
}

//--------------------------------------------------------------
void ofApp::update(){
    
    coreMotion.update();
    ofVec2f gravity = ofVec2f(coreMotion.getGravity().x, -coreMotion.getGravity().y);
    gravity *= 10;
    //box2d.setGravity(gravity);
    box2d.update();
    for (auto ripple : ripples) {
        ripple.get()->update();
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground(255);
    for (auto ripple : ripples) {
        ripple.get()->draw();
    }
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    touchStart.set(touch);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

    touchEnd.set(touch);
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    touchEnd.set(touch);
    
    float radius = touchEnd.distance(touchStart) / 10.f;
    
    ofRectangle touchBounds(touch.x - radius/2,
                            touch.y - radius/2,
                            touch.x + radius/2,
                            touch.y + radius/2);
    bool bAddNew = true;
    for (auto ripple : ripples) {
        if (touchBounds.inside(ripple.get()->getPosition())) {
            bAddNew = false;
            return;
        }
    }
    
    if (bAddNew) {
        ofPtr<Ripple> ripple(new Ripple());
        ripple.get()->setPhysics(initialMass, bounciness, friction);
        ripple.get()->setup(box2d.getWorld(), touchStart, radius);
        ripple.get()->addForce(touchEnd, radius * 10.f);
        ripple.get()->touchId = touch.id;
        ripple.get()->color = ofColor(ofRandom(100, 200));
        ripples.push_back(ripple);
    }
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
