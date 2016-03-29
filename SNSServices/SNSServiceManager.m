//
//  SNSServiceManager.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "SNSServiceManager.h"

@interface SNSServiceManager()
{
    NSDictionary *_services;
    NSArray      *_serviceKeys;
}
@end

@implementation SNSServiceManager
+(NSInteger)numberOfServices {
    return SNSServiceManager.sharedManager.numberOfServices;
}

+(NSDictionary *)getServiceAt:(NSInteger)index {
    return [SNSServiceManager.sharedManager getServiceAt:index];
}

#pragma mark - Sub-methods

-(NSInteger)numberOfServices {
    return _services.count;
}

-(NSDictionary *)getServiceAt:(NSInteger)index {
    return [_services objectForKey:[_serviceKeys objectAtIndex:index]];
}

#pragma mark - Singleton
-(id)init {
    if (self = [super init]) {
        _services = @{
                      @(SNSServiceInstagram): @{ SNSServiceTitle: @"Instagram",
                                                 SNSServiceIcon: @"icon-sns-instagram.png",
                                                 SNSServiceDescription: @"Instagram description" },
                      @(SNSServiceFlickr)   : @{ SNSServiceTitle: @"Flickr",
                                                 SNSServiceIcon: @"icon-sns-flickr.png",
                                                 SNSServiceDescription: @"Flickr description" },
                      @(SNSServicePicasa)   : @{ SNSServiceTitle: @"Picasa",
                                                 SNSServiceIcon: @"icon-sns-picasa.png",
                                                 SNSServiceDescription: @"Picasa description" },
                      /*@(SNSServiceFacebook) : @{ SNSServiceTitle: @"Facebook",
                       SNSServiceIcon: @"icon-sns-facebook.png",
                       SNSServiceDescription: @"Facebook description" }*/
                      };
        _serviceKeys = [_services allKeys];
    };
    
    return self;
}

+(SNSServiceManager *)sharedManager {
    static SNSServiceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}
@end
