#include "ofApp.h"
#include "SettingsViewController.h"


SettingsViewController *settingsViewController;


static bool removeShapeOffScreen(ofPtr<ofxBox2dBaseShape> shape) {
    if (!ofRectangle(0, -400, ofGetWidth(), ofGetHeight()+400).inside(shape.get()->getPosition())) {
        return true;
    }
    return false;
}


#pragma mark - App Lifecycle

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    ofSetCircleResolution(160);
    ofBackground(BACKGROUND_COLOR);
    ofSetLogLevel(OF_LOG_NOTICE);
    
    coreMotion.setupAttitude(CMAttitudeReferenceFrameXMagneticNorthZVertical);
    
    box2d.init();
    box2d.enableEvents();
    box2d.setGravity(0, 0);
    box2d.setFPS(60);
    box2d.createBounds();
    box2d.registerGrabbing();
    box2d.setIterations(1, 1);
    
    gravityMultiplier = 0.f;
    forceMultiplier = 10.f;
    tailLength = 75;
    bColorize = true;
    bUseShader = false;
    
    rippleType = RIPPLE_CIRCLE;
    
    // Add settings view
    settingsViewController = [[SettingsViewController alloc]
                              initWithNibName:@"SettingsViewController" bundle:nil];
    [ofxiOSGetGLParentView() addSubview:settingsViewController.view];
    [settingsViewController.view setHidden:YES];
}

//--------------------------------------------------------------
void ofApp::update(){
    
    coreMotion.update();
    
    ofRemove(circleRipples, removeShapeOffScreen);
    ofRemove(polyRipples, removeShapeOffScreen);
    
    ofVec2f gravity = ofVec2f(coreMotion.getGravity().x, -coreMotion.getGravity().y);
    gravity *= gravityMultiplier;
    box2d.setGravity(gravity);
    box2d.update();
    
    for (auto ripple : circleRipples) {
        ripple.get()->useShader = bUseShader;
        ripple.get()->update();
    }
    for (auto ripple : polyRipples) {
        ripple.get()->update();
    }
    
    if (circleRipples.size() > MAX_OBJECTS) {
        circleRipples.erase(circleRipples.begin());
    }
    if (polyRipples.size() > MAX_OBJECTS) {
        polyRipples.erase(polyRipples.begin());
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    for (auto ripple : circleRipples) {
        ripple.get()->draw();
    }
    for (auto ripple : polyRipples) {
        ripple.get()->draw();
    }
}

#pragma mark - Touch Events

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    touchStart.set(touch);
    shape.clear();
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

    touchEnd.set(touch);
    
    if (rippleType == RIPPLE_POLYGON) {
        shape.addVertex(touch);
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    touchEnd.set(touch);
    
    float   touchDist           = touchEnd.distance(touchStart) / 5.f;
    float   mass                = touchDist * 4.f;
    float   bounciness          = .63f;
    float   friction            = .35f;
    bool    bIsRippleTouching   = false;
    
//    ofRectangle touchBounds(touch.x - touchDist/2,
//                            touch.y - touchDist/2,
//                            touch.x + touchDist/2,
//                            touch.y + touchDist/2);
    
    for (auto ripple : circleRipples) {
        
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
    
    switch (rippleType) {
            
        case RIPPLE_CIRCLE:
        {
            if (!bIsRippleTouching && touchDist > MIN_CIRCLE_RADIUS) {
                ofPtr<RippleCircle> ripple(new RippleCircle());
                ripple.get()->setPhysics(mass, bounciness, friction);
                ripple.get()->setup(box2d.getWorld(), touchStart, touchDist, tailLength);
                ripple.get()->addForce(touchStart - touchEnd, touchDist * 12.8f);
                ripple.get()->forceMultiplier = forceMultiplier;
                ripple.get()->touchId = touch.id;
                
                if (bColorize) {
                    ripple.get()->color = ofColor(ofRandom(255), ofRandom(255), ofRandom(255));
                } else {
                    ripple.get()->color = ofColor(OBJECT_COLOR);
                }
                circleRipples.push_back(ripple);
            }
            
            break;
        }
            
        case RIPPLE_POLYGON:
        {
            shape.addVertex(touch);
            if (shape.getVertices().size() >= 3) {
                
                shape = shape.getResampledByCount(b2_maxPolygonVertices);
                shape = getConvexHull(shape);
                
//                for (auto ripple : polyRipples) {
//                    if (!ripple.get()->get) {
//                        bIsRippleTouching = true;
//                        break;
//                    }
//                }
                
                if (!bIsRippleTouching) {
                    ofPtr<RipplePolygon> ripple = ofPtr<RipplePolygon>(new RipplePolygon);
                    
                    ripple.get()->addVertices(shape.getVertices());
                    ripple.get()->setPhysics(mass, bounciness, friction);
                    ripple.get()->setup(shape, tailLength);
                    ripple.get()->create(box2d.getWorld());
                    ripple.get()->addForce(touchStart - touchEnd, touchDist * 12.8f);
                    ripple.get()->forceMultiplier = forceMultiplier;
                    ripple.get()->touchId = touch.id;
                    
                    if (bColorize) {
                        ripple.get()->color = ofColor(ofRandom(255), ofRandom(255), ofRandom(255));
                    } else {
                        ripple.get()->color = ofColor(OBJECT_COLOR);
                    }
                    polyRipples.push_back(ripple);
                    shape.clear();
                }
            }
            break;
        }
            
        default: break;
    }
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

    if( settingsViewController.view.hidden ){
		settingsViewController.view.hidden = NO;
        
        NSTimeInterval animationDuration = 200;
        CGRect newFrameSize = CGRectMake(0, 0, ofGetWidth()/2, ofGetHeight()/2);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        settingsViewController.view.frame = newFrameSize;
        [UIView commitAnimations];
        
	}
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

#pragma mark - App Events

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

//--------------------------------------------------------------
void ofApp::exit(){
    
}
