//
//  NLMasterViewController.h
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "FHSegmentedViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

//#import "NLContext.h"

@interface JSHHomeViewController : FHSegmentedViewController

@property UIViewController *editorViewController;
@property UIViewController *logsViewController;
@property UIViewController *documentationViewController;

@property JSContext *context;

@property UIBackgroundTaskIdentifier backgroundTask;

- (void)executeJS:(NSString *)code;

@end
