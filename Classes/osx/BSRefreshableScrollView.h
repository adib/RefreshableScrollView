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

/**
 Indicates which sides that are refreshable. 
*/
enum {
    BSRefreshableScrollViewSideNone = 0,
    /**
    Pulling downwards will reveal a refresh indicator and when sufficiently pulled should trigger a data load for newer items.
    */
    BSRefreshableScrollViewSideTop = 1,
    /**
    Pulling upwards will reveal a refresh indicator and when sufficiently pulled should trigger a data load for older items.
    */
    BSRefreshableScrollViewSideBottom = 1 << 1,
    // left & right edges are for future expansion but not currently implemented
    /**
    Currently unimplemented.
    */
    BSRefreshableScrollViewSideLeft = 1 << 2,
    /**
    Currently unimplemented.
    */
    BSRefreshableScrollViewSideRight = 1 << 3
};

typedef NSUInteger BSRefreshableScrollViewSide;

// ---

@protocol BSRefreshableScrollViewDelegate;
@protocol BSRefreshableScrollViewDataSource;

// ---

/**
 A scroll view that can be pulled downwards or upwards for the user to trigger refreshing of newer data or loading historical data.

*/
@interface BSRefreshableScrollView : NSScrollView

/**
Which sides are refreshable, of type BSRefreshableScrollViewSide
*/
@property (nonatomic) NSUInteger refreshableSides;

/**
Which sides are currently refreshing, of type BSRefreshableScrollViewSide
*/
@property (nonatomic,readonly) NSUInteger refreshingSides;

/**
 The object that will provide the refreshable data.
*/
@property (nonatomic,weak) IBOutlet id<BSRefreshableScrollViewDataSource> refreshableDataSource;
@property (nonatomic,weak) IBOutlet id<BSRefreshableScrollViewDelegate> refreshableDelegate;

/**
 Call this when you have loaded the data to dismiss the refresh progress indicator.
*/
-(void) stopRefreshingSide:(BSRefreshableScrollViewSide) refreshableSide;


@end

// ---

/**
 The object that will provide the refreshable data.
 This protocol is present for future implementation and currently empty 😏
*/
@protocol BSRefreshableScrollViewDataSource <NSObject>


@end


// ---
/**
 The object that will provide the refreshable data.
 This protocol is present for future implementation and currently empty 😏
*/
@protocol BSRefreshableScrollViewDelegate <NSObject>

@optional

/**
 Called by the  scroll view to indicate that refresh should start.
*/
-(BOOL) scrollView:(BSRefreshableScrollView*) aScrollView startRefreshSide:(BSRefreshableScrollViewSide) refreshableSide;


@end
