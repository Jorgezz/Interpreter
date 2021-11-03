//
//  JSHAppDelegate.m
//  JSHell
//
//  Created by jiaozhiyu on 21/05/17.
//  Copyright (c) 2021 jiaozhiyu. All rights reserved.
//

#import "JSHAppDelegate.h"
#import "NodeRunner.h"

//#import "NLContext.h"

@implementation JSHAppDelegate {
    NSString *scriptToLoad;
}

- (void)startNode {
    NSString* srcPath = [[NSBundle mainBundle] pathForResource:@"nodejs-project/main.js" ofType:@""];
    NSArray* nodeArguments = [NSArray arrayWithObjects:
                              @"node",
                              srcPath,
                              nil
                              ];
    [NodeRunner startEngineWithArguments:nodeArguments];
    

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSThread *nodejsThread = nil;
    nodejsThread = [[NSThread alloc] initWithTarget:self selector:@selector(startNode) object:nil];
    // Set 2MB of stack space for the Node.js thread.
    [nodejsThread setStackSize:2*1024*1024];
    [nodejsThread start];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    NSString *script = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    if (script) {
        
        scriptToLoad = script;

        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Open File"
                              message:@"You are about to load a file into the editor. This will clear your current script."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK",
                              nil];
        [alert show];

    }

    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"NLFileOpen" object:nil userInfo:@{@"script": scriptToLoad}];
    }
}

@end
