//+ (void)initialize {    if(self == [SinApplication class]) {
//#if !defined(NS_BLOCK_ASSERTIONS)
//        [GRMustache preventNSUndefinedKeyExceptionAttack];  // Debug configuration: keep GRMustache quiet
//#endif
//}	}


// The MIT License (MIT) Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFWebApplication.h"
#import "OCFWebApplicationDelegate.h"
#import "OCFRouter.h"
#import "OCFRoute.h"
#import "OCFResponse.h"
#import "OCFMustache.h"
#import "OCFRequest+Private.h"
#import "OCFRequest_Extension.h"

#import "NSDictionary+OCFConfigurationAdditions.h"
#import "OCFWebServerRequest+OCFWebAdditions.h"

#import <GRMustache/GRMustache.h>						//	<= 3rd. Party 
#import <OCFWebServer/OCFWebServer.h>
#import <OCFWebServer/OCFWebServerResponse.h>
#import <OCFWebServer/OCFWebServerRequest.h>

@implementation OCFWebApplication

#pragma mark - Creating an Application

// This initializer is meant to be for testing purposes only.
// The reason is that OCFWebApplication needs to know the bundle of the enclosing
// application to that it can find the templates for the Mustache template engine.
// You should have no need to use this initializer at all. Using -init is good enough.

- (instancetype)initWithBundle:(NSBundle *)bundle { return self = super.init ? _router = OCFRouter.new,
	_templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:(bundle != nil ? bundle : NSBundle.mainBundle)],
	[self _setupDefaultConfiguration], self : nil;
}
- (instancetype)init { return [self initWithBundle:nil]; }

- (void)_setupDefaultConfiguration {	NSDictionary *staticHeaders = 

	@{ @"X-XSS-Protection" : @"1; mode=block", @"X-Content-Type-Options" : @"nosniff", @"X-Frame-Options" : @"SAMEORIGIN"};
	self.configuration = @{ @"status" : @200, @"headers" : staticHeaders, @"contentType" : @"text/html;charset=utf-8" };
}

#pragma mark - Adding Handlers

- (void)handle:(NSString *)mthdPtrn requestsMatching:(NSString*)pthPtrn withBlock:(OCFWebApplicationRequestHandler)reqHndlr {

	NSParameterAssert(mthdPtrn); NSParameterAssert(pthPtrn); NSParameterAssert(reqHndlr); self[mthdPtrn][pthPtrn] = reqHndlr;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key {	NSParameterAssert(key);
	NSParameterAssert([object_getClass(key) isSubclassOfClass:NSString.class]); // make sure key is a string
	// key is a HTTP method regular expression
	// -methodRoutesPairForRequestWithMethodPattern: creates the pair object if it does not already exist.
	return [self.router methodRoutesPairForRequestWithMethodPattern:(NSString*)key];
}
#pragma mark - Controlling the Application


- (void)_handleResponse:(id)response withOriginalRequest:(OCFWebServerRequest *)originalRequest { __typeof__(self) __weak wSelf = self;

	if([response isKindOfClass:OCFResponse.class])
	return [originalRequest respondWith:[wSelf makeValidWebServerResponseWithResponse:response]];

	if([response isKindOfClass:[NSString class]]) {
		OCFResponse *webRequest = [[OCFResponse alloc] initWithStatus:0 headers:nil body:[response dataUsingEncoding:NSUTF8StringEncoding]];
		[originalRequest respondWith:[wSelf makeValidWebServerResponseWithResponse:webRequest]];
		return;
	}
	if([response isKindOfClass:NSDictionary.class]) 
		return [originalRequest respondWith: [wSelf makeValidWebServerResponseWithResponse:
																	[OCFResponse.alloc initWithProperties:(NSDictionary*)response]]];
		
	
	if([response isKindOfClass:OCFMustache.class]) { OCFMustache *mustache = response; NSError *renderE = nil, *reposE = nil;  
	
		// FIXME: nil is not a good response  Evaluate 
		__block GRMustacheTemplate *temp 	= [wSelf.templateRepository templateNamed:mustache.name error:&reposE];
		if(!temp) return NSLog(@"Failed to load template: %@", reposE), [originalRequest respondWith:nil]; 
		else if (self.newTemplateBlock) _newTemplateBlock(self,temp);
		
		__block NSString *rendered 	= [temp renderObject:mustache.object error:&renderE];
		if(!rendered) return NSLog(@"Failed to render object (%@): %@", mustache.object, renderE), [originalRequest respondWith:nil]; 
		else if (self.newRenderedBlock) _newRenderedBlock(self,rendered);
		
		OCFResponse *webResponse = [OCFResponse.alloc initWithStatus:200 headers:nil 
																				  body:[rendered dataUsingEncoding:NSUTF8StringEncoding]];
		
		[originalRequest respondWith:[wSelf makeValidWebServerResponseWithResponse:webResponse]]; return;
	}
	[originalRequest respondWith:nil]; // FIXME: nil is not a good response
}

- (NSString*) address {  return  [NSString stringWithFormat:@"http://127.0.0.1:%lu", self.port]; }

- (void)run { self.running = YES; }

- (void)runOnPort:(NSUInteger)port { self.port = port;  self.running = YES; }

- (void) setRunning:(BOOL)running { if (_server.isRunning ==  running) return;

	_running = running ? [self.server startWithPort:self.port bonjourName:nil] : ^{ [_server stop];  return NO; }();

}
- (void)stop { NSAssert(_server != nil, @"Called -stop with no running server."); self.running = NO; }

- (OCFWebServer*) server { if (_server) return _server;

	_server = [OCFWebServer new]; 	__typeof__(self) __weak wSelf = self;

	[_server addHandlerWithMatchBlock:^OCFWebServerRequest*(NSString*reqMthd,NSURL*reqURL,NSDictionary*reqHdrs,NSString*urlPath, NSDictionary *urlQuery) {

		Class requestClass = Nil; 	NSString *contentType = reqHdrs[@"Content-Type"];  NSString *contentLengthAsString = reqHdrs[@"Content-Length"];

		if(contentType != nil)
			requestClass = [contentType isEqualToString:OCFWebServerURLEncodedFormRequest.mimeType] ? OCFWebServerURLEncodedFormRequest.class
									 : [contentType hasPrefix:OCFWebServerMultiPartFormRequest.mimeType]        ? OCFWebServerMultiPartFormRequest.class
									 : contentLengthAsString && contentLengthAsString.integerValue							? OCFWebServerDataRequest.class
									 : OCFWebServerRequest.class;

		return (OCFWebServerRequest*) [requestClass.alloc initWithMethod:reqMthd   URL:reqURL headers:reqHdrs path:urlPath query:urlQuery]; // request

	} processBlock:^void(OCFWebServerRequest *request) {		NSString *requestMethod = request.method;

		// Method Overriding
		NSDictionary *requestParameters = [request additionalParameters_ocf];
		if(requestParameters[@"_method"] != nil) requestMethod = requestParameters[@"_method"];

		// Dispatch the request
		OCFRoute *route = [wSelf.router routeForRequestWithMethod:requestMethod requestPath:request.path];

		if(route == nil) {
			NSLog(@"[WebApplication] No route found for %@ %@.", request.method, request.path);
			OCFResponse *response = nil;
			if(wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(application:asynchronousResponseForRequestWithNoAssociatedHandler:)]) {
				OCFRequest *webRequest = [[OCFRequest alloc] initWithWebServerRequest:request parameters:nil];
				webRequest.method = requestMethod;
				[webRequest setRespondWith:^(id response) {
					response = response ?: [OCFResponse.alloc initWithStatus:404 headers:nil body:nil];
					[wSelf _handleResponse:response withOriginalRequest:request];
				}];
				[wSelf.delegate application:wSelf asynchronousResponseForRequestWithNoAssociatedHandler:webRequest];
			} else {
				// The delegate did not return anything useful so we have to generate a 404 response
				response = [[OCFResponse alloc] initWithStatus:404 headers:nil body:nil];
				[wSelf _handleResponse:response withOriginalRequest:request];
				return;
			}
			return;
		}

		NSDictionary *parameters 	= [wSelf parametersFromRequest:request withRoute:route];
		OCFRequest *webRequest 		= [OCFRequest.alloc initWithWebServerRequest:request parameters:parameters];
		[webRequest setRespondWith:^(id response) { [wSelf _handleResponse:response withOriginalRequest:request]; }];
		route.requestHandler(webRequest);
	}];
	return  _server;

}
#pragma mark - Properties

- (NSUInteger)port {  return _server ? _server.port : 0; }

#pragma mark - Aspects
// Imporant: The response passed to this method is valid according to the configuration.
//           This method SHOULD return a respons which is valid according to the configuration.
- (OCFResponse *)willDeliverResponse:(OCFResponse *)response { 	//OCFResponse *result = response;
	
	// Ask the Delegate first
	
	return [self.delegate respondsToSelector:@selector(application:willDeliverResponse:)] //responseFromDelegate
	? (OCFResponse*)[self.delegate application:self willDeliverResponse:response] ?: response : response;
	
	// Last chance for SinApplication to modify the response
//	return result;
}

#pragma mark - Private Helper Methods
- (NSDictionary *)parametersFromRequest:(OCFWebServerRequest *)request withRoute:(OCFRoute *)route {

	NSDictionary *patternParameters = [route parametersWithRequestPath:request.URL.path];	NSMutableDictionary *result; //, *requestParameters;
	[result = NSMutableDictionary.new addEntriesFromDictionary:patternParameters];
	[result addEntriesFromDictionary: request.additionalParameters_ocf]; // requestParameters
	
	if(request.query != nil) 	[result addEntriesFromDictionary:request.query];
	return result;
}

// Pass a potential invalid response to this method.
- (OCFResponse *)makeResponseValidAccordingToConfiguration:(OCFResponse *)response { NSParameterAssert(response);

	NSInteger status = response.status ?: self.configuration.defaultStatus_ocf; 	// Check the status
	NSMutableDictionary *mutableHeaders = response.headers.mutableCopy;	// Headers and Content-Type
	if(response.contentType == nil)  mutableHeaders[@"Content-Type"] = self.configuration.defaultContentType_ocf;
	[mutableHeaders addEntriesFromDictionary:self.configuration.defaultHeaders_ocf];
	return [OCFResponse.alloc initWithStatus:status headers:mutableHeaders body:response.body]; // validResponse
}

- (OCFWebServerResponse *)makeValidWebServerResponseWithResponse:(OCFResponse *)response { NSParameterAssert(response);
	OCFResponse *validResponse 	= [self makeResponseValidAccordingToConfiguration:response], 
					*modifiedResponse = [self willDeliverResponse:validResponse];
					validResponse 		= [self makeResponseValidAccordingToConfiguration:modifiedResponse];
									 return [self _makeWebServerResponseWithResponse:validResponse];
}

- (OCFWebServerResponse *)_makeWebServerResponseWithResponse:(OCFResponse *)response {	NSParameterAssert(response);
	
	OCFWebServerResponse *result = [OCFWebServerDataResponse responseWithData:response.body contentType:response.contentType];
	[response.headers enumerateKeysAndObjectsUsingBlock:^(NSString *headerName, NSString *headerValue, BOOL *stop) {
		[result setValue:headerValue forAdditionalHeader:headerName];
	}];
	result.statusCode = response.status;		return result;
}

@end
