
// The MIT License (MIT) Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <Foundation/Foundation.h>

@class OCFRequest, GRMustacheTemplate; @protocol OCFWebApplicationDelegate; typedef void(^OCFWebApplicationRequestHandler)(OCFRequest *request); 

@interface OCFWebApplication : NSObject

#pragma mark - Properties

@property (nonatomic,weak) id<OCFWebApplicationDelegate> delegate; 		@property (readonly) NSUInteger port;
@property (copy) void(^newTemplateBlock)(OCFWebApplication*,GRMustacheTemplate*);
@property (copy) void(^newRenderedBlock)(OCFWebApplication*,NSString*);
#pragma mark - Adding Handlers

- (void) handle:(NSString*)mthdPtrn requestsMatching:(NSString*)pthPtrn withBlock:(OCFWebApplicationRequestHandler)reqHndlr;

#pragma mark - Controlling the Application

- (void) run; 		- (void) runOnPort:(NSUInteger)port; 	- (void) stop;

#pragma mark - Creating an Application

// This initializer is meant to be for testing purposes only.The reason is that OCFWebApplication needs to know the bundle of the enclosing application to that it can find the templates for the Mustache template engine. You should have no need to use this initializer at all. Using -init is good enough.

- (instancetype)initWithBundle:(NSBundle *)bundle;

#pragma mark - Subscripting

- (id)objectForKeyedSubscript:(id <NSCopying>)key;

@end