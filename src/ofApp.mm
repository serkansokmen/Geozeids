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
    bRecordTouch = false;
    bColorize = true;
    
    // register the listener so that we get the events
//	ofAddListener(box2d.contactStartEvents, this, &ofApp::contactStart);
//	ofAddListener(box2d.contactEndEvents, this, &ofApp::contactEnd);
    
    // Load Sounds
    rippleSound[0].loadSound("themes/pack_2/sounds/E1.wav");
    rippleSound[1].loadSound("themes/pack_2/sounds/E2.wav");
    rippleSound[2].loadSound("themes/pack_2/sounds/E3.wav");
    rippleSound[3].loadSound("themes/pack_2/sounds/E4.wav");
	for (int i=0; i<N_SOUNDS; i++) {
		rippleSound[i].setMultiPlay(true);
		rippleSound[i].setLoop(false);
	}
    
    // Add settings view
    settingsViewController = [[SettingsViewController alloc]
                              initWithNibName:@"SettingsViewController" bundle:nil];
    [ofxiOSGetGLParentView() addSubview:settingsViewController.view];
    [settingsViewController.view setHidden:YES];
}

//--------------------------------------------------------------
void ofApp::update(){
    
    coreMotion.update();
    
    ofRemove(ripples, removeShapeOffScreen);
    ofRemove(polyShapes, removeShapeOffScreen);
    
    ofVec2f gravity = ofVec2f(coreMotion.getGravity().x, -coreMotion.getGravity().y);
    gravity *= gravityMultiplier;
    box2d.setGravity(gravity);
    box2d.update();
    
    for (auto ripple : ripples) {
        ripple.get()->update();
    }
    
    if (ripples.size() > MAX_OBJECTS) {
        ripples.erase(ripples.begin());
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    for (auto ripple : ripples) {
//        SoundData * data = (SoundData*)ripple.get()->getData();
        
//        if(data && data->bHit) {
//            ripple.get()->color = ofColor::greenYellow;
//        }
//        else {
//            ripple.get()->color = OBJECT_COLOR;
//        }
        ripple.get()->draw();
    }
    
    ofSetColor(ofColor::blueViolet, 155.f);
	for (int i=0; i<polyShapes.size(); i++) {
		polyShapes[i].get()->draw();
        ofCircle(polyShapes[i].get()->getPosition(), 3);
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
            ripple.get()->setup(box2d.getWorld(), touchStart, touchDist, tailLength);
            ripple.get()->addForce(touchStart - touchEnd, touchDist * 12.8f);
            ripple.get()->forceMultiplier = forceMultiplier;
            ripple.get()->touchId = touch.id;
            
            ripple.get()->setData(new SoundData());
            SoundData * sd = (SoundData*)ripple.get()->getData();
            sd->soundID = ofRandom(0, N_SOUNDS);
            sd->bHit	= false;
            
            if (bColorize) {
                ripple.get()->color = ofColor(ofRandom(255), ofRandom(255), ofRandom(255));
            } else {
                ripple.get()->color = ofColor(OBJECT_COLOR);
            }
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
//    bRecordTouch = !bRecordTouch;
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
    bRecordTouch = false;
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

#pragma mark - Contact Listeners

//--------------------------------------------------------------
void ofApp::contactStart(ofxBox2dContactArgs &e) {
	if(e.a != NULL && e.b != NULL) {
		
		// if we collide with the ground we do not
		// want to play a sound. this is how you do that
		if(e.a->GetType() == b2Shape::e_circle && e.b->GetType() == b2Shape::e_circle) {
			
			SoundData * aData = (SoundData*)e.a->GetBody()->GetUserData();
			SoundData * bData = (SoundData*)e.b->GetBody()->GetUserData();
			
			if(aData) {
				aData->bHit = true;
				rippleSound[aData->soundID].play();
			}
			
			if(bData) {
				bData->bHit = true;
				rippleSound[bData->soundID].play();
			}
		}
	}
}

//--------------------------------------------------------------
void ofApp::contactEnd(ofxBox2dContactArgs &e) {
	if(e.a != NULL && e.b != NULL) {
		
		SoundData * aData = (SoundData*)e.a->GetBody()->GetUserData();
		SoundData * bData = (SoundData*)e.b->GetBody()->GetUserData();
		
		if(aData) {
			aData->bHit = false;
		}
		
		if(bData) {
			bData->bHit = false;
		}
	}
}