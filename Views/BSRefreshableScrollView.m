//
//  BSRefreshableScrollView.m
//  RefreshableScrollView
//
//  Created by Sasmito Adibowo on 19-11-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Need automatic reference counting to compile this.
#endif

#import "BSRefreshableClipView.h"

#import "BSRefreshableScrollView_Private.h"


@implementation BSRefreshableScrollView

@synthesize refreshingSides = _refreshingSides;

-(void) stopRefreshingSide:(BSRefreshableScrollViewSide) refreshableSide 
{
    if (!(self.refreshingSides & refreshableSide)) {
        return;
    }
    NSClipView* const clipView = self.contentView;
    const NSRect clipViewBounds = clipView.bounds;

    switch (refreshableSide) {
        case BSRefreshableScrollViewSideTop:
            self.refreshingSides &= ~BSRefreshableScrollViewSideTop;
            [self.topProgressIndicator setDisplayedWhenStopped:NO];
            [self.topProgressIndicator stopAnimation:self];
            if(clipViewBounds.origin.y >= 0) {
                // fake scrolling
                CGEventRef cgEvent   = CGEventCreateScrollWheelEvent(NULL,
                                                                     kCGScrollEventUnitLine,
                                                                     2,
                                                                     1,
                                                                     0);
                
                NSEvent *scrollEvent = [NSEvent eventWithCGEvent:cgEvent];
                [self scrollWheel:scrollEvent];
                CFRelease(cgEvent);
            }
            break;
            
        default:
            break;
    }
}


-(NSView*) newEdgeViewForSide:(BSRefreshableScrollViewSide) edgeSide progressIndicator:(NSProgressIndicator*) indicatorView
{
    NSView* const contentView = self.contentView;
    const NSRect contentViewBounds = contentView.bounds;
    const NSRect indicatorViewBounds = indicatorView.bounds;
    
    
    NSView* edgeView = [[NSView alloc] initWithFrame:NSZeroRect];
    [edgeView setWantsLayer:YES];
    NSRect edgeViewFrame = NSZeroRect;
    
    switch (edgeSide) {
        case BSRefreshableScrollViewSideTop:
        case BSRefreshableScrollViewSideBottom:
            edgeView.autoresizingMask = NSViewWidthSizable;
            edgeViewFrame.size.width = contentViewBounds.size.width;
            edgeViewFrame.size.height = indicatorViewBounds.size.height;
            break;
        default:
            // can only specify one edge
            return nil;
    }
    
    
    if (edgeSide & BSRefreshableScrollViewSideTop) {
        edgeViewFrame.origin.y = contentViewBounds.size.height;
    } else if (edgeSide & BSRefreshableScrollViewSideBottom) {
        edgeViewFrame.origin.y = -edgeViewFrame.size.height;
    }
    // future expansion: check for left and right edges here.
    
    edgeView.frame = edgeViewFrame;
    
    
    [edgeView addSubview:indicatorView];
    
    // vertically centered
    [edgeView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:edgeView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    // horizontally centered
    [edgeView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:edgeView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    
    
    [contentView addSubview:edgeView];

    return edgeView;
    
}


#pragma mark NSObject

-(void)dealloc
{
    
}

#pragma mark NSResponder

-(void)scrollWheel:(NSEvent *)theEvent
{
    const NSEventPhase eventPhase = theEvent.phase;
    NSClipView* const clipView = self.contentView;
    const NSRect clipViewBounds = clipView.bounds;
    const NSRect headerFrame = self.headerView.frame;
    const NSRect footerFrame = self.footerView.frame;
    
    
    if (eventPhase & NSEventPhaseChanged) {
        
        void (^setupProgressIndicator)(NSProgressIndicator* progressIndicator,float maxValue,float currentValue) = ^(NSProgressIndicator* progressIndicator,float maxValue,float currentValue) {
            if (progressIndicator.isIndeterminate) {
                [progressIndicator setIndeterminate:NO];
                [progressIndicator setDisplayedWhenStopped:YES];
                progressIndicator.minValue = 0;
                progressIndicator.maxValue = maxValue;
            }
            [progressIndicator setAlphaValue:1];
            
            progressIndicator.doubleValue = currentValue;
        };
        
        if (clipViewBounds.origin.y > 0  ) {
            // showing top area
            const BSRefreshableScrollViewSide refreshSide = BSRefreshableScrollViewSideTop;
            if(!(self.refreshingSides & refreshSide)  && (self.refreshableSides & refreshSide) ) {
                // not refreshing top
                setupProgressIndicator(self.topProgressIndicator,headerFrame.size.height,clipViewBounds.origin.y);
                
                if (clipViewBounds.origin.y > headerFrame.size.height) {
                    self.triggeredRefreshingSides |= refreshSide;
                }
            }
        } else if (clipViewBounds.origin.y < 0) {
            // scrolling to bottom
            const BSRefreshableScrollViewSide refreshSide = BSRefreshableScrollViewSideBottom;
            if( !(self.refreshingSides & refreshSide) && (self.refreshableSides & refreshSide) ) {
                // not refreshing top
                setupProgressIndicator(self.bottomProgressIndicator,footerFrame.size.height,-clipViewBounds.origin.y);
                
                if (clipViewBounds.origin.y < -footerFrame.size.height) {
                    self.triggeredRefreshingSides |= refreshSide;
                }
            }
        }
    } else if(eventPhase & NSEventPhaseEnded) {
        BSRefreshableScrollViewSide refreshingSides = self.refreshingSides;
        
        void (^completeScrollPhase)(BSRefreshableScrollViewSide refreshSide,SEL progressIndicatorAccessor) = ^(BSRefreshableScrollViewSide refreshSide,SEL progressIndicatorAccessor) {
            
        };

        if (clipViewBounds.origin.y > 0) {
            // showing top area
            const BSRefreshableScrollViewSide refreshSide = BSRefreshableScrollViewSideTop;

            if(!(refreshingSides & refreshSide) && (self.refreshableSides & refreshSide)) {
                // not refreshing top and OK to refresh
                
                NSProgressIndicator const* progressIndicator = self.topProgressIndicator;
                // if triggered
                
                BSRefreshableScrollViewSide triggeredRefreshingSides = self.triggeredRefreshingSides;
                if (triggeredRefreshingSides & refreshSide) {
                    
                    refreshingSides |= refreshSide;
                    triggeredRefreshingSides &= ~refreshSide;
                    
                    self.refreshingSides = refreshingSides;
                    self.triggeredRefreshingSides = triggeredRefreshingSides;
                    
                    [progressIndicator setIndeterminate:YES];
                    [progressIndicator startAnimation:self];
                    
                    
                    id<BSRefreshableScrollViewDelegate> delegate = self.refreshableDelegate;
                    if ([delegate respondsToSelector:@selector(scrollView:startRefreshSide:)]) {
                        [delegate scrollView:self startRefreshSide:BSRefreshableScrollViewSideTop];
                    }
                } else  {
                    // un-triggered
                    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                        [progressIndicator.animator setAlphaValue:0];
                    } completionHandler:^{
                        [progressIndicator stopAnimation:self];
                        [progressIndicator setIndeterminate:NO];
                        
                    }];
                    
                }
            }
        }
    }
    [super scrollWheel:theEvent];
}

#pragma mark NSView

-(void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    [self headerView];
}

#pragma mark NSScrollView

-(NSClipView *)contentView
{
    NSClipView* superClipView = [super contentView];
    if (![superClipView isKindOfClass:[BSRefreshableClipView class]]) {
        NSView* documentView = superClipView.documentView;
        BSRefreshableClipView* clipView = [[BSRefreshableClipView alloc] initWithFrame:superClipView.frame];
        clipView.documentView = documentView;
        clipView.copiesOnScroll = NO;
        clipView.drawsBackground = NO;
        [self setContentView:clipView];
        superClipView = clipView;
    }
    return superClipView;
}

#pragma mark Property Access

@synthesize topProgressIndicator = _topProgressIndicator;

-(NSProgressIndicator *)topProgressIndicator
{
    if (!_topProgressIndicator) {
        _topProgressIndicator = [NSProgressIndicator new];
        [_topProgressIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_topProgressIndicator setIndeterminate:YES];
        [_topProgressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        [_topProgressIndicator setControlSize: NSRegularControlSize];
        [_topProgressIndicator setDisplayedWhenStopped:YES];
        [_topProgressIndicator setUsesThreadedAnimation:YES];
        [_topProgressIndicator setAlphaValue:0];
        [_topProgressIndicator sizeToFit];
    }
    return _topProgressIndicator;
}


@synthesize bottomProgressIndicator = _bottomProgressIndicator;

-(NSProgressIndicator *)bottomProgressIndicator
{
    if (!_bottomProgressIndicator && (self.refreshableSides & BSRefreshableScrollViewSideTop)) {
        _bottomProgressIndicator = [NSProgressIndicator new];
        [_bottomProgressIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_bottomProgressIndicator setIndeterminate:YES];
        [_bottomProgressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        [_bottomProgressIndicator setControlSize: NSRegularControlSize];
        [_bottomProgressIndicator setDisplayedWhenStopped:YES];
        [_bottomProgressIndicator setUsesThreadedAnimation:YES];
        [_bottomProgressIndicator sizeToFit];
    }
    return _bottomProgressIndicator;
}

@synthesize headerView = _headerView;

-(NSView *)headerView
{
    if (!_headerView && (self.refreshableSides & BSRefreshableScrollViewSideTop)) {
        _headerView = [self newEdgeViewForSide:BSRefreshableScrollViewSideTop progressIndicator:self.topProgressIndicator];
    }
    return _headerView;
}

@synthesize footerView = _footerView;

-(NSView *)footerView
{
    if (!_footerView && (self.refreshingSides & BSRefreshableScrollViewSideBottom)) {
        _footerView = [self newEdgeViewForSide:BSRefreshableScrollViewSideBottom progressIndicator:self.bottomProgressIndicator];
    }
    return _footerView;
}


@end
