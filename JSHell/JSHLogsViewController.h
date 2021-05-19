//
//  NLConsoleViewController.h
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSHHomeViewController.h"

@interface JSHLogsViewController : UIViewController

@property JSHHomeViewController *masterViewController;

@property IBOutlet UITextView *logs;

@property (nonatomic, readwrite) NSString *logsText;

- (void)log:(NSString *)string;
- (void)clear;

@end
