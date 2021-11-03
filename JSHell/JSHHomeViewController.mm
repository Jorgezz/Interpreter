//
//  NLMasterViewController.m
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "JSHHomeViewController.h"

#import "JSHEditorViewController.h"
#import "JSHLogsViewController.h"

#import "CSNotificationView.h"
#import "PBWebViewController.h"

#import "NLColor.h"

#import <hermes/hermes.h>
#include "JSBigString.h"
#import "NodeRunner.h"

std::unique_ptr<facebook::jsi::Runtime> runtime;
NSThread *nodejsThread;

@interface JSHHomeViewController ()
@end

@implementation JSHHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    self.editorViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"editorViewController"];
    self.logsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"logsViewController"];
    self.documentationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"documentationViewController"];
    
	[self setViewControllers:@[self.editorViewController, self.logsViewController]];
    [self pushViewController:self.documentationViewController];
    
    [self setupStyle];
    _context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];

//    __weak NLMasterViewController *weakSelf = self;
//    _context = [[NLContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    
//    [NLContext attachToContext:_context];
    
//    _context.exceptionHandler = ^(JSContext *c, JSValue *e) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf error:[e toString]];
//            NSLog(@"%@ stack: %@", e, [e valueForProperty:@"stack"]);
//        });
//    };
//    id logger = ^(JSValue *thing) {
//        [JSContext.currentArguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSLog(@"log: %@", [obj toString]);
//            [((NLConsoleViewController *)self.consoleViewController) log:[obj toString]];
//        }];
//    };
//    _context[@"console"] = @{@"log": logger, @"error": logger};
    
    //[_context evaluateScript:@"process.env['NODE_DEBUG']='module'"];

}

- (void)setupStyle {
    self.navigationController.navigationBar.tintColor    = [UIColor colorWithRed:49/255 green:50/255 blue:54/255 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.1 alpha:1];;
    self.navigationController.toolbar.tintColor          = [NLColor blackColor];
    self.navigationController.toolbar.barTintColor       = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
}

- (void)startNode:(NSString *)nodeCode {
    nodejsThread = [[NSThread alloc] initWithTarget:self selector:@selector(excuteNode:) object:nodeCode];
    // Set 2MB of stack space for the Node.js thread.
    [nodejsThread setStackSize:2*1024*1024];
    [nodejsThread start];
}

- (void)cancelNode {
    [nodejsThread cancel];
}

- (void)excuteNode:(NSString *)nodeCode {
    NSArray* nodeArguments = [NSArray arrayWithObjects:
                              @"node",
                              @"-e",
                              nodeCode,
                              nil
                              ];
    [NodeRunner startEngineWithArguments:nodeArguments];
}


- (void)executeJS:(NSString *)code {
    if ([code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return;
    }
    NSString *localNodeServerURL = [NSString stringWithFormat:@"http:/127.0.0.1:3000/excuteJSCode?code=%@", code];
    NSURL  *url = [NSURL URLWithString:localNodeServerURL];
    NSString *versionsData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    if (versionsData) {
        [self output:versionsData];
    }

//    [self cancelNode];
//    [self startNode:code];
    
    JSValue *ret = [_context evaluateScript:code];
    if (![ret isUndefined]) {
        [self output:[ret toString]];
    }
//    else {
//        [self error:[code stringByAppendingString:@"undefined"]];
//        return;
//    }
    
//    try {
//        NSLog(@"runtime->evaluateJavaScript start!");
//
//        hermes::vm::GCConfig::Builder gcConfigBuilder{};
//        gcConfigBuilder
//            .withAllocInYoung(false)
//            .withRevertToYGAtTTI(true);
//        ::hermes::vm::RuntimeConfig runtimeConfig = ::hermes::vm::RuntimeConfig();
//        runtime = facebook::hermes::makeHermesRuntime(runtimeConfig);
//        NSString *srcCode = code;
//        srcCode = [srcCode stringByReplacingOccurrencesOfString:@"console.log" withString:@"print"];
//        srcCode = [srcCode stringByReplacingOccurrencesOfString:@"console.info" withString:@"print"];
//        srcCode = [srcCode stringByReplacingOccurrencesOfString:@"console.warn" withString:@"print"];
//        srcCode = [srcCode stringByReplacingOccurrencesOfString:@"console.error" withString:@"print"];
//
//        std::string src = [srcCode UTF8String]; //"function __tickleJs() { return Math.random(); }";
//        src = "'use strict';" + src;
//        facebook::jsi::Value value = runtime->evaluateJavaScript(std::make_shared<facebook::jsi::StringBuffer>(src), "__runScript");
//        facebook::jsi::String retHermes = value.toString(*runtime);
//        NSLog(@"runtime->evaluateJavaScript ret: %s end!", retHermes.utf8(*runtime).c_str());
//    } catch (const std::exception & e) {
//        NSString *exception = [[NSString alloc] initWithUTF8String:e.what()];
//        [self error:exception];
//        [((JSHLogsViewController *)self.logsViewController) log:[NSString stringWithFormat:@"result: %@\n", exception]];
//    }
//    [((JSHLogsViewController *)self.logsViewController) log:code];
//    [((JSHLogsViewController *)self.logsViewController) log:[NSString stringWithFormat:@"result: %@\n", [ret toString]]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.backgroundTask = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"beginBG called");
            [UIApplication.sharedApplication endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
        
//        [NLContext runEventLoopSyncInContext:_context];
        
        [UIApplication.sharedApplication endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;

    });

}

- (void)output:(NSString *)message {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleSuccess
                                     message:message];
}

- (void)error:(NSString *)message {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleError
                                     message:message];
}

- (IBAction)clear:(id)sender {
    [[(JSHEditorViewController *)self.editorViewController input] setText:@""];
    [(JSHLogsViewController *)self.logsViewController clear];
}

- (IBAction)execute:(id)sender {
    [self executeJS:((JSHEditorViewController *)self.editorViewController).input.text];
}

- (IBAction)showInfo:(id)sender {
    PBWebViewController *docuViewController = [[PBWebViewController alloc] init];
//    docuViewController.URL = [NSURL URLWithString:@"http://nodeapp.org/?utm_source=interpreter&utm_medium=App&utm_campaign=info"];
    docuViewController.URL = [NSURL URLWithString:@"https://www.oschina.net/project/tag/364/ios-code"];
    [self.navigationController pushViewController:docuViewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
