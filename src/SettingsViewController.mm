//
//  SettingsViewController.m
//  Geozeids
//
//  Created by Serkan Sökmen on 13/08/14.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    myApp = (ofApp*)ofGetAppPtr();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleShapeMode:(UISwitch *)sender
{
    myApp->bRecordTouch = [sender isOn];
}
- (IBAction)done:(id)sender
{
    self.view.hidden = YES;
}
- (IBAction)clearPolys:(id)sender
{
    myApp->polyShapes.clear();
}
- (IBAction)clearRipples:(id)sender
{
    myApp->circleRipples.clear();
}
- (IBAction)tailLengthChanged:(UISlider *)sender
{
    myApp->tailLength = (int)[sender value];
}
- (IBAction)gravityChanged:(UISlider *)sender
{
    myApp->gravityMultiplier = [sender value];
}

- (IBAction)toggleColorize:(UISwitch *)sender
{
    myApp->bColorize = [sender isOn];
}

- (IBAction)forceChanged:(UISlider *)sender
{
    myApp->forceMultiplier = [sender value];
}

- (IBAction)toggleUseShader:(UISwitch *)sender
{
    myApp->bUseShader = [sender isOn];
}

@end
