// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <Foundation/Foundation.h>

#import "OCFWebApplication.h"

@class OCFRoute, OCFMethodRoutesPair;
@interface OCFRouter : NSArrayController

#pragma mark - Working with the Router
- (BOOL) addRouteWithPathPattern:(NSString*)pathPattern
									 methodPattern:(NSString *)methodPattern
											 withBlock:(OCFWebApplicationRequestHandler)requestHandler;

- (OCFRoute*) routeForRequestWithMethod:(NSString*)method
														requestPath:(NSString*)requestPath;

// This method creates a OCFMethodRoutesPair if no matching object for methodPattern is found. 
- (OCFMethodRoutesPair*)methodRoutesPairForRequestWithMethodPattern:(NSString*)methodPattern;

@end
