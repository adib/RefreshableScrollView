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
    NSView* const documentView = self.documentView;
    const NSRect documentFrame = documentView.frame;

    const BSRefreshableScrollViewSide refreshingSides = [self refreshingSides];
    
    if ((refreshingSides & BSRefreshableScrollViewSideTop) && proposedNewOrigin.y <= 0) {
        const NSRect headerFrame = [self headerView].frame;
        constrained.y = MAX(-headerFrame.size.height, proposedNewOrigin.y);
    }
    
    if((refreshingSides & BSRefreshableScrollViewSideBottom) ) {
        const NSRect footerFrame = [self footerView].frame;
        if (proposedNewOrigin.y >  documentFrame.size.height - clipViewBounds.size.height) {
            const CGFloat maxHeight = documentFrame.size.height - clipViewBounds.size.height + footerFrame.size.height + 1;
            constrained.y = MIN(maxHeight, proposedNewOrigin.y);
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
        documentRect.size.height += headerFrame.size.height;
        documentRect.origin.y -= headerFrame.size.height;
    }
    
    if(refreshingSides & BSRefreshableScrollViewSideBottom) {
        const NSRect footerFrame = [self footerView].frame;
        documentRect.size.height += footerFrame.size.height ;
    }
     
    return documentRect;
}


#pragma mark NSView

-(BOOL)isFlipped
{
    return YES;
}


@end
