//
//  BSAppDelegate.h
//  RefreshableScrollView
//
//  Created by Sasmito Adibowo on 19-11-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BSRefreshableScrollView.h"

@interface BSAppDelegate : NSObject <NSApplicationDelegate,BSRefreshableScrollViewDataSource,BSRefreshableScrollViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic,weak) IBOutlet BSRefreshableScrollView* refreshableScrollView;

- (IBAction)stopRefreshTop:(id)sender;
- (IBAction)stopRefreshBottom:(id)sender;

@end
