//
//  OCFAppDelegate.h
//  OCFWeb Mac Example
//
//  Created by cmk on 8/4/13.
//  Copyright (c) 2013 Objective-Cloud.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <ACEView/ACEView.h>
#import <ACEView/AceBrowserView.h>

@interface OCFAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet ACEBrowserView *bView;
@end
