//
//  BSAppDelegate.m
//  RefreshableScrollView
//
//  Created by Sasmito Adibowo on 19-11-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//

#import "BSAppDelegate.h"


@implementation BSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.refreshableScrollView.refreshableSides = BSRefreshableScrollViewSideTop | BSRefreshableScrollViewSideBottom;
}

#pragma mark BSRefreshableScrollViewDelegate

- (IBAction)stopRefreshTop:(id)sender
{
    [self.refreshableScrollView stopRefreshingSide:BSRefreshableScrollViewSideTop];
}

- (IBAction)stopRefreshBottom:(id)sender
{
    [self.refreshableScrollView stopRefreshingSide:BSRefreshableScrollViewSideBottom];
}

@end
