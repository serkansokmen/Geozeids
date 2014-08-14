//
//  SettingsViewController.h
//  Geozeids
//
//  Created by Serkan Sökmen on 13/08/14.
//
//

#import <UIKit/UIKit.h>

#include "ofApp.h"

@interface SettingsViewController : UIViewController {
    ofApp *myApp;
}

- (IBAction)toggleShapeMode:(UISwitch *)sender;
- (IBAction)done:(id)sender;
- (IBAction)clearPolys:(id)sender;
- (IBAction)clearRipples:(id)sender;

@end
