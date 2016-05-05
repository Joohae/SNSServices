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
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+Helper.h"
#import "CryptoUtil.h"

static NSString *const FLICKR_API_BASE = @"https://www.flickr.com/services";

@interface SNSDeviceFlickr ()
{
    AuthenticationWVCFlickr *_webviewController;
}

@property (nonatomic) NSString *clientKey;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *clientCallback;
@property (nonatomic) NSString *clientAuthSecret;
@property (nonatomic) NSString *clientAuthToken;    // access token
@end

@implementation SNSDeviceFlickr
- (void) setClinetKey:(NSString *)clientKey secret:(NSString *)clientSecret andCallbackBase:(NSString *)callbackBase {
    _clientKey = clientKey;
    _clientSecret = clientSecret;
    _clientCallback = [NSString stringWithFormat:@"%@://auth", callbackBase];
    _clientAuthSecret = @"";    // for later
}

- (BOOL) hasAuthentication {
    return (_clientAuthToken != nil);
}

/*!
 Request request media file list to SNSService
 */
- (void) requestFileList {
    [self requestToken:^(NSString *response) {
        
        
    } failure:^(NSError *error) {
        
        
    }];
    /*
    if (![self hasAuthentication]) {
        [self addAuthenticationViews];
        return;
    }
     //*/
}

- (void) requestToken:(void (^)(NSString *)) success
              failure:(void (^)(NSError *)) failure {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[NSString stringWithFormat:@"%d", [[CryptoUtil sharedManager] getUint32NonceFrom:10000000 to:99999999]]
               forKey:@"oauth_nonce"];
    [params setObject:[NSString stringWithFormat:@"%f", [[NSDate new] timeIntervalSince1970]]
               forKey:@"oauth_timestamp"];
    [params setObject:_clientKey forKey:@"oauth_consumer_key"];
    [params setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
    [params setObject:@"1.0" forKey:@"oauth_version"];
    [params setObject:[[CryptoUtil sharedManager] urlEncode:_clientCallback] forKey:@"oauth_callback"];
    
    NSString *baseString = [NSString stringWithFormat:@"%@/%@",FLICKR_API_BASE,@"oauth/request_token"];
    NSString *signature = [self getSignatureOf:baseString params:params];
    [params setObject:signature forKey:@"oauth_signature"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", baseString, [self convertDictionaryToUrlString:params withBaseUrl:baseString]];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *param = [NSMutableDictionary new];

    [manager GET:URL.absoluteString
      parameters:param progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceError:)]) {
                 [self.delegate SNSServiceError:error];
             }
         }];
}

- (NSString *) convertDictionaryToUrlString:(NSDictionary *)params withBaseUrl:(NSString *)baseUrl {
    NSString *response;
    NSMutableString *baseString = [NSMutableString new];
    
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        [baseString appendFormat:@"%@=%@&", key, [params objectForKey:key]];
    }
    
    if ([baseString length] > 0) {
        response = [baseString substringToIndex:[baseString length] - 1];
    }
    
    return response;
}

- (NSString *) getSignatureOf:(NSString *)baseUrl params:(NSDictionary *)params {
    NSString *response;
    
    NSString *encodedUrl = [[CryptoUtil sharedManager] urlEncode:baseUrl];
    NSString *baseData   = [[CryptoUtil sharedManager] urlEncode:[self convertDictionaryToUrlString:params withBaseUrl:baseUrl]];
    
    response = [NSString stringWithFormat:@"GET&%@&%@", encodedUrl, baseData];
    response = [[CryptoUtil sharedManager] hmacsha1:response secret:[NSString stringWithFormat:@"%@&%@", _clientSecret, _clientAuthSecret]];
    response = [[CryptoUtil sharedManager] urlEncode:response];
    
    return response;
}

- (NSString *) dictionaryToString:(NSDictionary *)params {
    NSString *response;
    
    return response;
}

#pragma mark - Authentication
// TODO: This method can be refactoring
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
