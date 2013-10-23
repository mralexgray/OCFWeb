#import "OCFAppDelegate.h"
#import <OCFWeb/OCFWeb.h>
#import <AtoZ/AtoZ.h>


@interface OCFAppDelegate ()
@property  (strong) OCFWebApplication *app;
@property  (strong, nonatomic)NSMutableArray *persons; // contains NSDictionary instances

@end

@implementation OCFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {	_app = OCFWebApplication.new;

   self.persons = [NSS.properNames nmap:^id(id obj, NSUI idx) { 	return @{ @"id" : @(idx).stringValue, 
																						@"firstName" : obj, @"lastName" : NSS.randomBadWord }.mutableCopy; }].mutableCopy;
//	ACEBrowserView *__weak bb = _bView;
//	_app.newRenderedBlock = ^(OCFWebApplication*app, NSString*str){
//		bb.aceView.string = str.copy;
//	};

	_app[@"GET"][@"/persons"]  = ^(OCFRequest *request) {
		request.respondWith([OCFMustache newMustacheWithName:  @"Persons" 
																	 object:@{@"persons" : _persons}]); };

	_app[@"GET"][@"/persons/:id"]  = ^(OCFRequest *request) {
		NSString *personID = request.parameters[@"id"];
		for(NSDictionary *person in self.persons) { // Find the person
			if([person[@"id"] isEqualToString:personID]) // person found
				return request.respondWith([OCFMustache newMustacheWithName:@"PersonDetail" object:person]);
		}
		request.respondWith(@"Error: No Person found");
	};
	_app[@"POST"][@"/persons"]  = ^(OCFRequest *request) {
        NSMutableDictionary *person = [NSMutableDictionary dictionaryWithDictionary:request.parameters];
        person[@"id"] = [@(self.persons.count + 1) stringValue];
        [self.persons addObject:person];
	};
	_app[@"PUT"][@"/persons/:id"]  = ^(OCFRequest *request) {
		NSString *personID = request.parameters[@"id"];
		for(NSMutableDictionary *person in self.persons) {
			if([person[@"id"] isEqualToString:personID]){ // person updated
					[person setValuesForKeysWithDictionary:request.parameters];
					request.respondWith([request redirectedTo:@"/persons"]); return;
			}
		}
		request.respondWith(@"Error: No Person found");
	};

	[_app run];
	
	[_bView.webView setMainFrameURL:[NSString stringWithFormat:@"http://127.0.0.1:%lu/persons", self.app.port]];
}


@end
