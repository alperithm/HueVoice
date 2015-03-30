/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHControlLightsViewController.h"
#import "PHAppDelegate.h"

#import <HueSDK_iOS/HueSDK.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEFliteController.h>
#import <Slt/Slt.h>
#define MAX_HUE 65535

@interface PHControlLightsViewController()

@property (nonatomic,weak) IBOutlet UILabel *bridgeMacLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeIpLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeLastHeartbeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (nonatomic,weak) IBOutlet UIButton *randomLightsButton;

// 音声認識データ
@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) OEFliteController *fliteController;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedDictionary;
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedDictionary;
@property (nonatomic, copy) NSArray *words;
@property (nonatomic, copy) NSArray *colors;

@end


@implementation PHControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Find bridge" style:UIBarButtonItemStylePlain target:self action:@selector(findNewBridgeButtonAction)];
    
    self.navigationItem.title = @"QuickStart";
    
    [self noLocalConnection];
    
    // 音声データ格納
    self.fliteController = [[OEFliteController alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    [self.openEarsEventsObserver setDelegate:self];
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    _words = @[
                @"OHAYOU",
                @"SUKINAKO",
                @"COOL"];
    _colors = @[
                [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],
                [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0],
                [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0]];
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    
    // languageModelGenerator.verboseLanguageModelGenerator = TRUE; // Uncomment me for verbose language model generator debug output.
    
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:_words withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    } else {
        self.pathToFirstDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
        self.pathToFirstDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
    }
    
    [[OEPocketsphinxController sharedInstance] setActive:true error:nil];
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    }
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)localConnection{
    
    [self loadConnectedBridgeValues];
    
}

- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.text = @"Not connected";
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
    self.bridgeIpLabel.text = @"Not connected";
    [self.bridgeIpLabel setEnabled:NO];
    self.bridgeMacLabel.text = @"Not connected";
    [self.bridgeMacLabel setEnabled:NO];
    self.wordLabel.text = @"No Word";
    
    [self.randomLightsButton setEnabled:NO];
}

- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        
        // Set the ip address of the bridge
        self.bridgeIpLabel.text = cache.bridgeConfiguration.ipaddress;
        
        // Set the mac adress of the bridge
        self.bridgeMacLabel.text = cache.bridgeConfiguration.mac;
        
        // Check if we are connected to the bridge right now
        if (UIAppDelegate.phHueSDK.localConnected) {
            
            // Show current time as last successful heartbeat time when we are connected to a bridge
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            self.bridgeLastHeartbeatLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
            
            [self.randomLightsButton setEnabled:YES];
        } else {
            self.bridgeLastHeartbeatLabel.text = @"Waiting...";
            [self.randomLightsButton setEnabled:NO];
        }
    }
}

- (IBAction)selectOtherBridge:(id)sender{
    [UIAppDelegate searchForBridgeLocal];
}

- (IBAction)randomizeColoursOfConnectLights:(id)sender{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:128]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }
}

- (void)findNewBridgeButtonAction{
    [UIAppDelegate searchForBridgeLocal];
}

// 音声データ認識
- (void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis
                        recognitionScore:(NSString *)recognitionScore
                             utteranceID:(NSString *)utteranceID
{
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@",
          hypothesis, recognitionScore, utteranceID);
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        NSUInteger index = [_words indexOfObject:hypothesis];
        if (index != NSNotFound) {
            [self setColorWithWord:_words[index] hypothesis:hypothesis color:_colors[index] lightState:lightState];
            // Send lightstate to light
            [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
                if (errors != nil) {
                    NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                    
                    NSLog(@"Response: %@",message);
                }
            }];
        }
    }
}

-(void)changeLightColorWithHypothesis:(NSString *)hypothesis
             lightState:(PHLightState *)lightState
{
    NSLog(@"%@", [[hypothesis componentsSeparatedByString:@" "] objectAtIndex:0]);
}

-(void)setColorWithWord:(NSString *)word
             hypothesis:(NSString *)hypothesis
                  color:(UIColor *)color
             lightState:(PHLightState *)lightState
{
    NSString* wordStr = [[hypothesis componentsSeparatedByString:@" "] objectAtIndex:0];
    self.wordLabel.text = wordStr;
    NSRange match = [word rangeOfString:wordStr options:NSRegularExpressionSearch];
    if (match.location != NSNotFound) {
        CGFloat hue = [self getHue:color];
        [lightState setHue:[NSNumber numberWithInt:hue * MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:128]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
    } else {
        NSLog(@"Not Found");
    }
}

-(CGFloat)getHue:(UIColor *)color
{
    CGFloat hue = 0.0;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    NSLog(@"hue : %f", hue);
    return hue;
}

@end
