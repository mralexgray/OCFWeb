// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <Foundation/Foundation.h>

@class OCFWebApplication, OCFResponse, OCFRequest, GRMustacheTemplate;

@protocol OCFWebApplicationDelegate <NSObject>

@optional
- (NSString*) applicationRenderedStringDidChange:(OCFWebApplication*)app;
- (GRMustacheTemplate*) applicationTemplateDidChange:(OCFWebApplication *)application;
- (OCFResponse *)application:(OCFWebApplication *)application willDeliverResponse:(OCFResponse *)response;
- (void)application:(OCFWebApplication *)application asynchronousResponseForRequestWithNoAssociatedHandler:(OCFRequest *)request;

@end
