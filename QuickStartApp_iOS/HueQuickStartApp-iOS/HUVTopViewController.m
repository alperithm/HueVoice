//
//  HUVTopViewController.m
//  HueQuickStartApp-iOS
//
//  Created by Hashido Rihito on 3/30/15.
//  Copyright (c) 2015 Philips. All rights reserved.
//

#import <sys/ucred.h>
#import "HUVTopViewController.h"
#import "CSAnimationView.h"
#import "TweetManager.h"
#import "Notifications.h"

@interface HUVTopViewController ()

@property (nonatomic) NSInteger popUpIndex;
@property (nonatomic, strong) TweetManager *tweetManager;

@end

@implementation HUVTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.microphone = [EZMicrophone microphoneWithDelegate:self];

    self.audioPlot.backgroundColor = [UIColor clearColor];
    self.audioPlot.color = [UIColor whiteColor];
    self.audioPlot.plotType = EZPlotTypeBuffer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.popUpIndex = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.microphone startFetchingAudio];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSuccessGetTweetList:) name:SuccessGetTweesList object:nil];
    self.tweetManager = [[TweetManager alloc] init];
    [self.tweetManager requestTweetSearchAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSuccessGetTweetList:(NSNotification *)notificationCenter {
    NSArray *tweets = [[notificationCenter userInfo] objectForKey:@"tweets"];
    for (NSString *tweet in tweets) {
        NSString *keyword = @"iOS";
        NSRange range = [tweet rangeOfString:keyword];
        if (range.location != NSNotFound) {
            NSLog(@"is Found");
        } else {
            NSLog(@"Not Found");
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - EZMicrophoneDelegate

- (void)microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    [EZAudio printASBD:audioStreamBasicDescription];
}

- (IBAction)addButtonPressed:(id)sender {
    [self revealPopUp:self.popUpIndex++ withWord:@"hello"];
}

- (void)revealPopUp:(int)popUpIndex withWord:(NSString *)word {
    int x, y;
    switch (popUpIndex % 4) {
        case 0:
            x = 20;
            y = 20;
            break;
        case 1:
            x = 100;
            y = 200;
            break;
        case 2:
            x = 200;
            y = 200;
            break;
        case 3:
            x = 20;
            y = 300;
            break;
        default:
            x = 20;
            y = 20;
    }
    CSAnimationView *animationView = [[CSAnimationView alloc] initWithFrame:CGRectMake(x, y, 100, 50)];
    animationView.backgroundColor = [UIColor whiteColor];
    animationView.duration = 1.0;
    animationView.delay = 0;
    animationView.type = CSAnimationTypePop;
    animationView.layer.cornerRadius = 10.0f;

    [self.view addSubview:animationView];

// Add your subviews into animationView

    //insert said word to label.
// [animationView addSubview:<#(UIView *)#>]
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    label.text = word;
    label.textAlignment = NSTextAlignmentCenter;
    [label adjustsFontSizeToFitWidth];
    [animationView addSubview:label];

// Kick start the animation immediately
    [animationView startCanvasAnimation];
    [animationView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3.0f];
}

@end
