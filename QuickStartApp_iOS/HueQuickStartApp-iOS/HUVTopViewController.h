//
//  HUVTopViewController.h
//  HueQuickStartApp-iOS
//
//  Created by Hashido Rihito on 3/30/15.
//  Copyright (c) 2015 Philips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"

@interface HUVTopViewController : UIViewController<EZMicrophoneDelegate>

@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;
@property (nonatomic, strong) EZMicrophone *microphone;

- (IBAction)addButtonPressed:(id)sender;

@end
