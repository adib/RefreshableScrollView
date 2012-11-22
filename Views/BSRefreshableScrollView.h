//
//  BSRefreshableScrollView.h
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

// for future expansion -- currently empty 😏

@end


// ---

@protocol BSRefreshableScrollViewDelegate <NSObject>

@optional

-(BOOL) scrollView:(BSRefreshableScrollView*) aScrollView startRefreshSide:(BSRefreshableScrollViewSide) refreshableSide;


@end
