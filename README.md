# RefreshableScrollView

An `NSScrollView` subclass that supports pull-to-refresh both in the top and bottom edges. The intended usage is for hosting a timeline-like view that shows a list of messages in reverse-chronological order.

<iframe width="560" height="315" src="http://www.youtube.com/embed/pCsKe3n8sEw?list=UUjGxuNIAufU923dtBuyC82A&amp;hl=en_US" frameborder="0" allowfullscreen></iframe>

## Getting Started

Attach `RefreshableScrollView.xcodeproj` into your OS X project and add `libRefreshableScrollView.a` as a dependency in your project. Also include the public header file `BSRefreshableScrollView.h` into your project's user header search paths.

Play around with the included example application to see the class in action and how it is being used. The video demo above shows a recording of this sample application.

## How to use

Use `BSRefreshableScrollView` as a replacement of `NSScrollView`. If you use Xcode's interface builder to add instances of `NSTableView` or `NSOutlineView` (among others), by default it will enclose those objects inside an `NSScrollView`. Highlight this `NSScrollView` container, go to the object' identity inspector and type in `BSRefreshableScrollView` as the scroll view's class name.

Then you'll need to write a delegate that conforms to `BSRefreshableScrollViewDelegate` protocol. Most likely this will be the `xib`'s file owner – a view controller or a window controller. Attach this delegate class to the `refreshableDelegate` outlet of the scroll view.

In `awakeFromNib` method of the delegate, setup which sides that supports pull-to-refresh. This is important – without enabling these flags, `BSRefreshableScrollView` will behave just like a plain old `NSScrollView`. If you don't use `xib` files then you'll need to find an appropriate place to set these flags. Note that you can clear any of these flags to disable refresh for their respective sides even when the view is already visible.


    -(void)awakeFromNib
    {
        [super awakeFromNib];
        self.refreshableScrollView.refreshableSides = BSRefreshableScrollViewSideTop | BSRefreshableScrollViewSideBottom;
    }

Start the refresh process in your delegate by implementing method `scrollView: startRefreshSide:` and return `YES` if the process was successfully started. The scroll view will then display an indeterminate progress indicator at the appropriate edge. If for some reason you couldn't initiate refresh for that side, simply return `NO` and the scroll view will behave as if nothing happened.

    #pragma mark BSRefreshableScrollViewDelegate
    
    -(BOOL) scrollView:(BSRefreshableScrollView*) aScrollView startRefreshSide:(BSRefreshableScrollViewSide) refreshableSide
    {
	    if (refreshableSide == BSRefreshableScrollViewSideTop) {
		    // initiate refresh process for the top edge of the scroll view
		    // ...
		    return YES; // tell the scroll view to display the progress indicator
	    } else if (refreshableSide == BSRefreshableScrollViewSideBottom) {
		    // initiate refresh process for the bottom edge of the scroll view
		    // ...
		    return YES; 
	    }
        return NO;
    }

When the refresh process have completed (i.e. the network service have returned a result or timed out), call `stopRefreshingSide:` and give it the appropriate edge to stop. If there was no refresh currently in progress at that side this calling this method will have no effect. For example:

    - (IBAction)stopRefreshTop:(id)sender
    {
        [self.refreshableScrollView stopRefreshingSide:BSRefreshableScrollViewSideTop];
    }

## License

This project is licensed under the BSD license. Please let me know (<adib@cutecoder.org>) if you use it for something interesting.



Sasmito Adibowo
http://cutecoder.org


