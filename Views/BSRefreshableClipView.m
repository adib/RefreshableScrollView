//
//  BSRefreshableClipView.m
//  RefreshableScrollView
//
//  Created by Sasmito Adibowo on 19-11-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//


#if !__has_feature(objc_arc)
#error Need automatic reference counting to compile this.
#endif

#import "BSRefreshableScrollView_Private.h"
#import "BSRefreshableClipView.h"

@implementation BSRefreshableClipView

-(NSView*) headerView
{
    return [(BSRefreshableScrollView*) self.superview headerView];
}

-(NSView*) footerView
{
    return [(BSRefreshableScrollView*) self.superview footerView];
}


-(BSRefreshableScrollViewSide) refreshingSides
{
    return [(BSRefreshableScrollView*) self.superview refreshingSides];
}


#pragma mark NSClipView

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin
{
    NSPoint constrained = [super constrainScrollPoint:proposedNewOrigin];
    const NSRect clipViewBounds = self.bounds;

    //const BSRefreshableScrollViewSide refreshableSides = [self refreshableSides];
    const BSRefreshableScrollViewSide refreshingSides = [self refreshingSides];
    if ((refreshingSides & BSRefreshableScrollViewSideTop) && clipViewBounds.origin.y > 0) {
        const NSRect headerFrame = [self headerView].frame;
        if (clipViewBounds.origin.y > headerFrame.size.height) {
            // have scrolled above the refresh view
            constrained.y = headerFrame.size.height;
        }
    } else if((refreshingSides & BSRefreshableScrollViewSideBottom) && clipViewBounds.origin.y < 0) {
        const NSRect footerFrame = [self footerView].frame;
        if (clipViewBounds.origin.y < -footerFrame.size.height) {
            constrained.y = -footerFrame.size.height;
        }
    }

    return constrained;
}


-(NSRect)documentRect
{
    NSRect documentRect = [super documentRect];
    const BSRefreshableScrollViewSide refreshingSides = [self refreshingSides];
    
    if (refreshingSides & BSRefreshableScrollViewSideTop) {
        const NSRect headerFrame = [self headerView].frame;
        documentRect.origin.y += headerFrame.size.height;
        //documentRect.size.height -= headerFrame.size.height;
    } else if(refreshingSides & BSRefreshableScrollViewSideBottom) {
        const NSRect footerFrame = [self footerView].frame;
        documentRect.origin.y -= footerFrame.size.height;
    }
    return documentRect;
}



@end
