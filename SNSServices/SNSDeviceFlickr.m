//
//  SNSDeviceFlickr.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

/*!
 You may need to register
    1. an account of Flickr Developer Account: https://www.flickr.com/services/developer
    2. an application: https://www.flickr.com/services/apps/create/apply/
 */

#import "SNSDeviceFlickr.h"

@interface SNSDeviceFlickr ()
{
    AuthenticationWVCFlickr *_webviewController;
}

@property (nonatomic) NSString *clientKey;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *clinetCallback;
@end

@implementation SNSDeviceFlickr
- (void) setClinetKey:(NSString *)clientKey secret:(NSString *)clientSecret andCallbackBase:(NSString *)callbackBase {
    _clientKey = clientKey;
    _clientSecret = clientSecret;
    _clinetCallback = [NSString stringWithFormat:@"%@://auth", callbackBase];
}

- (BOOL) hasAuthentication {
    return NO;
}

/*!
 Request request media file list to SNSService
 */
- (void) requestFileList {
    if (![self hasAuthentication]) {
        [self addAuthenticationViews];
        return;
    }
}

#pragma mark - Authentication
- (void) addAuthenticationViews {
    UIViewController *parentVC = [self.delegate SNSWebAuthenticationRequired];
    
    NSString *frameworkBundleID = @"kr.carrotbooks.SNSServices";
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
    
    _webviewController = [[AuthenticationWVCFlickr alloc]
                          initWithNibName:@"AuthenticationWebViewController"
                          bundle:frameworkBundle];
    [_webviewController setDelegate:self];
//    [_webviewController setClinetID:_clientId secret:_clientSecret andCallbackBase:_callbackBase];
    
    [parentVC addChildViewController:_webviewController];
    _webviewController.view.frame = parentVC.view.frame;
    
    [parentVC.view addSubview:_webviewController.view];
    [_webviewController didMoveToParentViewController:parentVC];
}

- (void) removeAuthenticationViews {
    [_webviewController.view removeFromSuperview];
    [_webviewController removeFromParentViewController];
    _webviewController = nil;
}

#pragma mark Authentication Delegate Methods
- (void) authenticationSuccess:(NSDictionary *)response {
    NSLog(@"Authentication succeeded: %@", response);
    /*
    _accessToken = response[@"ACCESS_TOKEN"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_accessToken) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setObject:_accessToken forKey:KEY_INSTAGRAM_ACCESS_TOKEN];
            // TODO: store access token
            
            [self removeAuthenticationViews];
            [self.delegate SNSWebAuthenticationSuccess];
        }
    });
     */
}

- (void) authenticationFailure:(NSError *)error {
    NSLog(@"Authentication failed: %@", error);
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeAuthenticationViews];
        [self.delegate SNSWebAuthenticationFailed:error];
    });
     */
}
@end
