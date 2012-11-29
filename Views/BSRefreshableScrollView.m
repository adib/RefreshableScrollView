//
//  BSRefreshableScrollView.m
//  RefreshableScrollView
//
//  Created by Sasmito Adibowo on 19-11-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//  http://basilsalad.com
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#if !__has_feature(objc_arc)
#error Need automatic reference counting to compile this.
#endif

#import "BSRefreshableClipView.h"
#import "BSRefreshableScrollView_Private.h"


@implementation BSRefreshableScrollView

@synthesize refreshingSides = _refreshingSides;

-(void) stopRefreshingSide:(BSRefreshableScrollViewSide) refreshableSides
{
    NSClipView* const clipView = self.contentView;
    const NSRect clipViewBounds = clipView.bounds;
    
    void (^stopRefresh)(BSRefreshableScrollViewSide side, NSProgressIndicator* progressIndicator, BOOL (^shouldScroll)()) = ^(BSRefreshableScrollViewSide side, NSProgressIndicator* progressIndicator, BOOL (^shouldScroll)()) {
        
        if ( !(self.refreshingSides & side) ) {
            return;
        }
        
        self.refreshingSides &= ~side;
        [progressIndicator stopAnimation:self];
        [progressIndicator setDisplayedWhenStopped:NO];
        if (shouldScroll()) {
            // fake scrolling
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                int scrollAmount = 0;
                if (side  & BSRefreshableScrollViewSideTop) {
                    scrollAmount = 1;
                } else if(side  & BSRefreshableScrollViewSideBottom) {
                    scrollAmount = -1;
                }
                CGEventRef cgEvent   = CGEventCreateScrollWheelEvent(NULL,
                                                                     kCGScrollEventUnitLine,
                                                                     1,
                                                                     scrollAmount,
                                                                     0);
                
                NSEvent *scrollEvent = [NSEvent eventWithCGEvent:cgEvent];
                [self scrollWheel:scrollEvent];
                CFRelease(cgEvent);
            }];
        }
    };
        
    if (refreshableSides & BSRefreshableScrollViewSideTop) {
        stopRefresh(BSRefreshableScrollViewSideTop,self.topProgressIndicator,^{
            return (BOOL) (clipViewBounds.origin.y < 0);
        });
    }

    if (refreshableSides & BSRefreshableScrollViewSideBottom) {
        stopRefresh(BSRefreshableScrollViewSideBottom,self.bottomProgressIndicator,^{
            return (BOOL) (clipViewBounds.origin.y > 0);
        });
    }
    
}


-(NSView*) newEdgeViewForSide:(BSRefreshableScrollViewSide) edgeSide progressIndicator:(NSProgressIndicator*) indicatorView
{
    NSView* const contentView = self.contentView;
    NSView* const documentView = self.documentView;
    const NSRect indicatorViewBounds = indicatorView.bounds;
    
    
    NSView* edgeView = [[NSView alloc] initWithFrame:NSZeroRect];
    [edgeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [edgeView setWantsLayer:YES];
    
    [edgeView addSubview:indicatorView];
    
    // vertically centered
    [edgeView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:edgeView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    // horizontally centered
    [edgeView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:edgeView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [contentView addSubview:edgeView];
    
    
    if (edgeSide  &  (BSRefreshableScrollViewSideTop | BSRefreshableScrollViewSideBottom) ) {
        // span horizontally
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:edgeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:edgeView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];


        // set height
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:edgeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:indicatorViewBounds.size.height]];

        if (edgeSide & BSRefreshableScrollViewSideTop) {
            // above the content view top
            [contentView addConstraint:[NSLayoutConstraint constraintWithItem:edgeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:documentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        } else if(edgeSide & BSRefreshableScrollViewSideBottom) {
            [contentView addConstraint:[NSLayoutConstraint constraintWithItem:edgeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:documentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        }
    }

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
    
    if (eventPhase & NSEventPhaseChanged) {
        NSClipView* const clipView = self.contentView;
        const NSRect clipViewBounds = clipView.bounds;
        NSView* const documentView = self.documentView;
        const NSRect headerFrame = self.headerView.frame;
        const NSRect footerFrame = self.footerView.frame;
        const NSRect documentFrame = documentView.frame;
        
        void (^startScrollPhase)(BSRefreshableScrollViewSide refreshSide,NSProgressIndicator* progressIndicator,float progressMaxValue,float progressCurrentValue, BOOL (^shouldTriggerRefresh)(void)) = ^(BSRefreshableScrollViewSide refreshSide,NSProgressIndicator* progressIndicator,float progressMaxValue,float progressCurrentValue, BOOL (^shouldTriggerRefresh)(void)) {
            
            if(!(self.refreshingSides & refreshSide)  && (self.refreshableSides & refreshSide) ) {
                // not refreshing top
                
                if (progressIndicator.isIndeterminate) {
                    [progressIndicator setIndeterminate:NO];
                    [progressIndicator setDisplayedWhenStopped:YES];
                }
                [progressIndicator setAlphaValue:1];
                
                progressIndicator.minValue = 0;
                progressIndicator.maxValue = progressMaxValue;
                progressIndicator.doubleValue = progressCurrentValue;
                
                self.activatedRefreshingSides |= refreshSide;

                if (shouldTriggerRefresh()) {
                    self.triggeredRefreshingSides |= refreshSide;
                }
            }
        };


        if (clipViewBounds.origin.y < 0  ) {
            // showing top area
            
            startScrollPhase(BSRefreshableScrollViewSideTop,self.topProgressIndicator,headerFrame.size.height,-clipViewBounds.origin.y, ^{
                return  (BOOL) (clipViewBounds.origin.y < -headerFrame.size.height);
            });
            
        } else if (clipViewBounds.origin.y > documentFrame.size.height - clipViewBounds.size.height) {
            // scrolling to bottom
            CGFloat gapHeight = clipViewBounds.origin.y + clipViewBounds.size.height - documentFrame.size.height;
            startScrollPhase(BSRefreshableScrollViewSideBottom,self.bottomProgressIndicator,footerFrame.size.height,gapHeight, ^{
                return  (BOOL) (gapHeight > footerFrame.size.height);
            });
        }
    } else if(eventPhase & NSEventPhaseEnded) {
        NSClipView* const clipView = self.contentView;
        const NSRect clipViewBounds = clipView.bounds;

        
        void (^completeScrollPhase)(BSRefreshableScrollViewSide refreshSide,NSProgressIndicator* progressIndicator) = ^(BSRefreshableScrollViewSide refreshSide,NSProgressIndicator* progressIndicator) {
            if(!(self.refreshingSides & refreshSide) && (self.activatedRefreshingSides & refreshSide)) {
                // not refreshing and OK to refresh
                
                self.activatedRefreshingSides &= ~refreshSide;
                
                if (self.triggeredRefreshingSides & refreshSide) {
                    self.triggeredRefreshingSides &= ~refreshSide;

                    [[NSOperationQueue mainQueue ] addOperationWithBlock:^{
                        BOOL refreshStarted = NO;
                        id<BSRefreshableScrollViewDelegate> delegate = self.refreshableDelegate;
                        if ([delegate respondsToSelector:@selector(scrollView:startRefreshSide:)]) {
                            refreshStarted = [delegate scrollView:self startRefreshSide:refreshSide];
                        }
                        
                        if (refreshStarted) {
                            [progressIndicator setIndeterminate:YES];
                            [progressIndicator startAnimation:self];
                            self.refreshingSides |= refreshSide;
                        }
                    }];
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
        };

        if (clipViewBounds.origin.y < 0) {
            // showing top area
            completeScrollPhase(BSRefreshableScrollViewSideTop,self.topProgressIndicator);
        } else if(clipViewBounds.origin.y > 0) {
            // showing bottom area
            completeScrollPhase(BSRefreshableScrollViewSideBottom,self.bottomProgressIndicator);
        }
    }
    [super scrollWheel:theEvent];
}


#pragma mark NSView

// Place NSView overrides here – currently empty 😊


#pragma mark NSScrollView

-(NSClipView *)contentView
{
    NSClipView* superClipView = [super contentView];
    if (![superClipView isKindOfClass:[BSRefreshableClipView class]]) {
        NSView* documentView = superClipView.documentView;
        BSRefreshableClipView* clipView = [[BSRefreshableClipView alloc] initWithFrame:superClipView.frame];
        clipView.documentView = documentView;
        [self setContentView:clipView];
        superClipView = clipView;
    }
    return superClipView;
}


#pragma mark Property Access

@synthesize topProgressIndicator = _topProgressIndicator;

-(NSProgressIndicator *)topProgressIndicator
{
    if (!_topProgressIndicator && (self.refreshableSides & BSRefreshableScrollViewSideTop)) {
        _topProgressIndicator = [NSProgressIndicator new];
        [_topProgressIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_topProgressIndicator setIndeterminate:YES];
        [_topProgressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        [_topProgressIndicator setControlSize: NSRegularControlSize];
        [_topProgressIndicator setDisplayedWhenStopped:YES];
        [_topProgressIndicator setAlphaValue:0];
        [_topProgressIndicator sizeToFit];
    }
    return _topProgressIndicator;
}


@synthesize bottomProgressIndicator = _bottomProgressIndicator;

-(NSProgressIndicator *)bottomProgressIndicator
{
    if (!_bottomProgressIndicator && (self.refreshableSides & BSRefreshableScrollViewSideBottom)) {
        _bottomProgressIndicator = [NSProgressIndicator new];
        [_bottomProgressIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_bottomProgressIndicator setIndeterminate:YES];
        [_bottomProgressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        [_bottomProgressIndicator setControlSize: NSRegularControlSize];
        [_bottomProgressIndicator setDisplayedWhenStopped:YES];
        [_bottomProgressIndicator setAlphaValue:0];
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
    if (!_footerView && (self.refreshableSides & BSRefreshableScrollViewSideBottom)) {
        _footerView = [self newEdgeViewForSide:BSRefreshableScrollViewSideBottom progressIndicator:self.bottomProgressIndicator];
    }
    return _footerView;
}


@end
