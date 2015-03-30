//
//  Tweet.m
//  HueQuickStartApp-iOS
//
//  Created by sho on 2015/03/30.
//  Copyright (c) 2015年 Philips. All rights reserved.
//

#import "TweetManager.h"
#import "Notifications.h"

@interface TweetManager ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;

@end


@implementation TweetManager

- (instancetype)init {
    if (self = [super init]) {
        self.accountStore = [[ACAccountStore alloc] init];
        [self setAccount];
        [self generateSearchRequest];
    }
}

- (void)setAccount {
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:self.accountType
                                               options:NULL
                                            completion:^(BOOL granted, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (granted) {
                                                        if ([[self.accountStore accountsWithAccountType:self.accountType] count] == 0) {
                                                            //Twitterアカウント設定が１つもない場合の処理
                                                        } else if([[self.accountStore accountsWithAccountType:self.accountType] count] > 1) {
                                                            //複数アカウント設定がある場合
                                                            NSMutableArray *twitterAccounts = [[NSMutableArray alloc] init];
                                                            twitterAccounts = [[self.accountStore accountsWithAccountType:self.accountType] mutableCopy];
                                                            
                                                            for (int i = 0; i < [twitterAccounts count]; i++) {
                                                                //ここで取得
                                                                ACAccount *twAccount = [twitterAccounts objectAtIndex:i];
                                                                NSString *userName = [twAccount valueForKey:@"username"];
                                                            }
                                                        }else{
                                                            //Twitterアカウントが１つだけの場合
                                                            ACAccount *account = [[self.accountStore accountsWithAccountType:self.accountType] lastObject];
                                                        }
                                                    } else {
                                                        //データが取得できない場合
                                                    }
                                                });
                                            }];
}

- (void)generateSearchRequest {
    [self.accountStore requestAccessToAccountsWithType:self.accountType
                                               options:NULL
                                            completion:^(BOOL granted, NSError *error) {
                                                if (granted) {
                                                    //  Step 2:  Create a request
                                                    NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:self.accountType];
                                                    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                                                    
                                                    NSDictionary *params = @{@"q" : @"%24adf2015",
                                                                             @"count" : @"10"};
                                                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                            requestMethod:SLRequestMethodGET
                                                                                                      URL:url
                                                                                               parameters:params];
                                                    
                                                    //  Attach an account to the request
                                                    [request setAccount:[twitterAccounts lastObject]];
                                                    [self requestSearchAPI:request];
                                                }
                                                else {
                                                    // Access was not granted, or an error occurred
                                                    NSLog(@"%@", [error localizedDescription]);
                                                }
                                            }
     ];
}

- (void)requestSearchAPI:(SLRequest *)request {
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            if (urlResponse.statusCode >= 200 &&
                urlResponse.statusCode < 300) {
                
                NSError *jsonError;
                NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&jsonError];
                if (timelineData) {
                    
                    NSMutableArray *textLists = @[].mutableCopy;
                    for (NSDictionary *meta in timelineData[@"statuses"]) {
                        NSString *text = [NSString stringWithFormat:@"%@",  meta[@"text"]];
                        [textLists addObject:text];
                    }
                    NSDictionary *userInfo = @{@"tweets" : textLists};
                    [[NSNotificationCenter defaultCenter] postNotificationName:SuccessGetTweesList
                                                                        object:self
                                                                      userInfo:userInfo];

                }
                else {
                    // Our JSON deserialization went awry
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                }
            } else {
                // The server did not respond ... were we rate-limited?
                NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
            }
        }
    }];
}

@end
