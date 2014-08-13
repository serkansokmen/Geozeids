#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    ofSetCircleResolution(160);
    ofBackground(BACKGROUND_COLOR);
    ofSetLogLevel(OF_LOG_ERROR);
    
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
    gravity *= 1.f;
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
    
//    ofSetColor(ofColor::greenYellow);
//	shape.draw();
    
    ofSetColor(ofColor::blueViolet, 155.f);
	for (int i=0; i<polyShapes.size(); i++) {
		polyShapes[i].get()->draw();
        ofCircle(polyShapes[i].get()->getPosition(), 3);
	}
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    touchStart.set(touch);
    shape.clear();
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

    touchEnd.set(touch);
    
    if (bRecordTouch) {
        shape.addVertex(touch);
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    touchEnd.set(touch);
    
    bool bIsRippleTouching = false;
    
    for (auto ripple : ripples) {
        
        float dist = ofDist(ripple.get()->getPosition().x,
                            ripple.get()->getPosition().y,
                            touchEnd.x,
                            touchEnd.y);
        float radius = ripple.get()->getRadius();
        
        if (dist < radius) {
            bIsRippleTouching = true;
            break;
        }
    }
    
    if (!bIsRippleTouching && !bRecordTouch) {
        
        float touchDist = touchEnd.distance(touchStart) / 5.f;
        
        if (touchDist > 10.f) {
            
            float mass = touchDist * 4.f;
            float bounciness = .63f;
            float friction = .35f;
            
            ofRectangle touchBounds(touch.x - touchDist/2,
                                    touch.y - touchDist/2,
                                    touch.x + touchDist/2,
                                    touch.y + touchDist/2);
            
            ofPtr<Ripple> ripple(new Ripple());
            ripple.get()->setPhysics(mass, bounciness, friction);
            ripple.get()->setup(box2d.getWorld(), touchStart, touchDist);
            ripple.get()->addForce(touchStart - touchEnd, touchDist * 200.8f);
            ripple.get()->touchId = touch.id;
            ripple.get()->color = ofColor(OBJECT_COLOR);
            ripples.push_back(ripple);
        }
    }
    
    if (bRecordTouch) {
        
        shape.addVertex(touch);
        
        if (shape.getVertices().size() >= 3) {
            
            bool bTouches = false;
            for (auto ps : polyShapes) {
                if (ps.get()->getBoundingBox().inside(touchEnd)) {
                    bTouches = true;
                    break;
                }
            }
            
            if (!bTouches) {
                // create a poly shape with the max verts allowed
                // and the get just the convex hull from the shape
                shape = shape.getResampledByCount(b2_maxPolygonVertices);
                shape = getConvexHull(shape);
                
                ofPtr<ofxBox2dPolygon> poly = ofPtr<ofxBox2dPolygon>(new ofxBox2dPolygon);
                poly.get()->addVertices(shape.getVertices());
                poly.get()->setPhysics(70.f, 0.3f, 0.75f);
                poly.get()->create(box2d.getWorld());
                polyShapes.push_back(poly);
                shape.clear();
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    bRecordTouch = !bRecordTouch;
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    bRecordTouch = false;
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
