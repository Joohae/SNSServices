//
//  AuthenticationWVCFlickr.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "AuthenticationWVCFlickr.h"

@interface AuthenticationWVCFlickr()

@property (nonatomic) NSString *clientKey;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *callbackBase;

@end

@implementation AuthenticationWVCFlickr

- (void)viewDidLoad {
    //self.targetURL = [NSString stringWithFormat:@"https://www.flickr.com/services/oauth/authorize"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods
- (void) setClinetKey:(NSString *)clientKey secret:(NSString *)clientSecret andCallbackBase:(NSString *)callbackBase {
    _clientKey = clientKey;
    _clientSecret = clientSecret;
    _callbackBase = callbackBase;
}

#define mark - WebView Delegate Override
-(void) authenticationSuccess:(NSDictionary *)response {
    NSLog(@"Authentication Success");
}

-(void) authenticationFailure:(NSError *)error {
    NSLog(@"AUthentication Failure");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Did Fail Load With Error");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shoudStartLoadWithRequest: %@", request);
    return YES;
}
@end
