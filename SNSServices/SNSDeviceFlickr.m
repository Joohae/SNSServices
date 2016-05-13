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
#import "FlickrUtil.h"

static NSString *const FLICKR_API_BASE          = @"https://www.flickr.com/services";
static NSString *const ERROR_DOMAIN             = @"kr.carrotbooks.SNSService.SNSDeviceFlickr";

static NSString *const KEY_OAUTH_NONCE          = @"oauth_nonce";
static NSString *const KEY_OAUTH_TIMESTAMP      = @"oauth_timestamp";
static NSString *const KEY_OAUTH_CONSUMER_KEY   = @"oauth_consumer_key";
static NSString *const KEY_OAUTH_SIGNATURE_METHOD = @"oauth_signature_method";
static NSString *const KEY_OAUTH_VERSION        = @"oauth_version";
static NSString *const KEY_OAUTH_CALLBACK       = @"oauth_callback";
static NSString *const KEY_OAUTH_SIGNATURE      = @"oauth_signature";

@interface SNSDeviceFlickr ()
{
    AuthenticationWVCFlickr *_webviewController;
}

@property (nonatomic) NSString *clientKey;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *clientCallback;
@property (nonatomic) NSString *clientAuthSecret;
@property (nonatomic) NSString *clientAuthToken;
@property (nonatomic) NSString *accessToken;
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
    if (![self hasAuthentication]) {
        [self requestToken:^(NSString *response) {
            [self addAuthenticationViews];
        } failure:^(NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceError:)]) {
                [self.delegate SNSServiceError:error];
            }
        }];
        return;
    }
}

- (void) requestToken:(void (^)(NSString *)) success
              failure:(void (^)(NSError *)) failure
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[FlickrUtil createNonce] forKey:KEY_OAUTH_NONCE];
    [params setObject:[[CryptoUtil sharedManager] getTimeStampString] forKey:KEY_OAUTH_TIMESTAMP];
    [params setObject:_clientKey forKey:KEY_OAUTH_CONSUMER_KEY];
    [params setObject:@"HMAC-SHA1" forKey:KEY_OAUTH_SIGNATURE_METHOD];
    [params setObject:@"1.0" forKey:KEY_OAUTH_VERSION];
    [params setObject:[[CryptoUtil sharedManager] urlEncode:_clientCallback] forKey:KEY_OAUTH_CALLBACK];
    
    NSString *baseString = [NSString stringWithFormat:@"%@/%@",FLICKR_API_BASE,@"oauth/request_token"];
    NSString *signature = [self getSignatureOf:baseString params:params];
    [params setObject:signature forKey:KEY_OAUTH_SIGNATURE];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", baseString, [self convertDictionaryToUrlString:params withBaseUrl:baseString]];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *param = [NSMutableDictionary new];

    [manager GET:URL.absoluteString
      parameters:param progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             NSError *error = nil;
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             NSDictionary *params = [FlickrUtil parseResponseOfRequestToken:responseString];
             if ([params count] < 1) {
                 error = [NSError errorWithDomain:ERROR_DOMAIN
                                             code:kCFErrorHTTPParseFailure
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Unable to parse response",
                                                    @"response": responseString
                                                    }];
                 failure(error);
                 return;
             }
             
             if (params[@"oauth_callback_confirmed"]
                 && [params[@"oauth_callback_confirmed"] isEqualToString:@"true"]
                 && params[@"oauth_token"]) {
                 _clientAuthToken = params[@"oauth_token"];
                 _clientAuthSecret = params[@"oauth_token_secret"];
                 success(params[@"oauth_token"]);
             } else {
                 error = [NSError errorWithDomain:ERROR_DOMAIN
                                             code:kCFErrorHTTPParseFailure
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Unable to fetch oauth_token",
                                                    @"response": responseString
                                                    }];
                 failure(error);
             }
             
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             failure(error);
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
    [_webviewController setAuthToken:_clientAuthToken permission:FLICKR_PERMISSION_WRITE andCallbackBase:_clientCallback];
    
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
