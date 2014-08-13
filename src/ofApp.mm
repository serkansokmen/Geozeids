#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    ofSetCircleResolution(160);
    ofBackground(BACKGROUND_COLOR);
    ofSetLogLevel(OF_LOG_VERBOSE);
    
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
    gravity *= 5.f;
    box2d.setGravity(gravity);
    box2d.update();
    
    for (auto ripple : ripples) {
        ripple.get()->update();
    }
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
    
    touchStart.set(touch);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

    touchEnd.set(touch);
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    touchEnd.set(touch);
    
    bool bTouchesAnother = false;
    
    ofLog(OF_LOG_VERBOSE, ofToString(touchStart));
    ofLog(OF_LOG_VERBOSE, ofToString(touchEnd));
    
    for (auto ripple : ripples) {
        
        ofLog(OF_LOG_VERBOSE, ofToString(ripple.get()->getPosition()));
        
        if (ripple.get()->getPosition().distance(touchStart) > ripple.get()->getRadius()) {
            bTouchesAnother = true;
            break;
        }
    }
    
//    if (!bTouchesAnother) {
        float radius = touchEnd.distance(touchStart) / 5.f;
        
        ofRectangle touchBounds(touch.x - radius/2,
                                touch.y - radius/2,
                                touch.x + radius/2,
                                touch.y + radius/2);
        
        ofPtr<Ripple> ripple(new Ripple());
        ripple.get()->setPhysics(MASS, BOUNCINESS, FRICTION);
        ripple.get()->setup(box2d.getWorld(), touchEnd, radius);
        ripple.get()->addForce(touchEnd - touchStart, radius * 2.f);
        ripple.get()->touchId = touch.id;
        ripple.get()->color = ofColor(OBJECT_COLOR);
        ripples.push_back(ripple);
//    }
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
    ripples.clear();
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
