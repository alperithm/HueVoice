//
//  HUVTopViewController.m
//  HueQuickStartApp-iOS
//
//  Created by Hashido Rihito on 3/30/15.
//  Copyright (c) 2015 Philips. All rights reserved.
//

#import "HUVTopViewController.h"
#import "TweetManager.h"
#import "Notifications.h"

NSString *const kUpdateTweetsInfo  = @"kUpdateTweetsInfo";

@interface HUVTopViewController ()

@property (nonatomic, strong) TweetManager *tweetManager;

@end

@implementation HUVTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSuccessGetTweetList:) name:SuccessGetTweesList object:nil];
    self.tweetManager = [[TweetManager alloc] init];
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

@end
