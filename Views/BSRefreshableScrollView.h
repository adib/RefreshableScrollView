//
//  BSRefreshableScrollView.h
//  RefreshableScrollView
//
//  Created by Sasmito Adibowo on 19-11-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
    BSRefreshableScrollViewSideNone = 0,
    BSRefreshableScrollViewSideTop = 1,
    BSRefreshableScrollViewSideBottom = 1 << 1,
    // left & right edges are for future expansion but not currently implemented
    BSRefreshableScrollViewSideLeft = 1 << 2,
    BSRefreshableScrollViewSideRight = 1 << 3
};

typedef NSUInteger BSRefreshableScrollViewSide;

// ---

@protocol BSRefreshableScrollViewDelegate;
@protocol BSRefreshableScrollViewDataSource;


// ---
@interface BSRefreshableScrollView : NSScrollView

@property (nonatomic) NSUInteger refreshableSides;
@property (nonatomic,readonly) NSUInteger refreshingSides;

@property (nonatomic,weak) IBOutlet id<BSRefreshableScrollViewDataSource> refreshableDataSource;
@property (nonatomic,weak) IBOutlet id<BSRefreshableScrollViewDelegate> refreshableDelegate;

@property (nonatomic,strong) IBOutlet NSView* topRefreshView;

-(void) stopRefreshingSide:(BSRefreshableScrollViewSide) refreshableSide;


@end

// ---

@protocol BSRefreshableScrollViewDataSource <NSObject>



@end


// ---

@protocol BSRefreshableScrollViewDelegate <NSObject>

@optional


-(BOOL) scrollView:(BSRefreshableScrollView*) aScrollView shouldRefreshSide:(BSRefreshableScrollViewSide) refreshableSide;


-(void) scrollView:(BSRefreshableScrollView*) aScrollView startRefreshSide:(BSRefreshableScrollViewSide) refreshableSide;


@end
