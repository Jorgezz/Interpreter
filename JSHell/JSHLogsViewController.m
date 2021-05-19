//
//  NLConsoleViewController.m
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "JSHLogsViewController.h"

@implementation JSHLogsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.logsText = @"";
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    self.logs.text = self.logsText;
}

- (void)log:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logsText = [self.logsText stringByAppendingFormat:@"%@\n", string];
        self.logs.text = self.logsText;
    });
}

- (void)clear {
    self.logsText = @"";
    self.logs.text = @"";
}

@end
