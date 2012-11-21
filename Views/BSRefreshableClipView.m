//
//  BSRefreshableClipView.m
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
    } else if(refreshingSides & BSRefreshableScrollViewSideBottom) {
        const NSRect footerFrame = [self footerView].frame;
        documentRect.origin.y -= footerFrame.size.height;
    }
    return documentRect;
}



@end
