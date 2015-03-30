//
//  HUVTopViewController.m
//  HueQuickStartApp-iOS
//
//  Created by Hashido Rihito on 3/30/15.
//  Copyright (c) 2015 Philips. All rights reserved.
//

#import "HUVTopViewController.h"

@interface HUVTopViewController ()

@end

@implementation HUVTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.microphone = [EZMicrophone microphoneWithDelegate:self];

    self.audioPlot.backgroundColor = [UIColor clearColor];
    self.audioPlot.color = [UIColor whiteColor];
    self.audioPlot.plotType = EZPlotTypeBuffer;
//    [self.microphone startFetchingAudio];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.microphone startFetchingAudio];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
