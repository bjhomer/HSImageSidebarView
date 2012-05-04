HSImageSidebarView
==================

`HSImageSidebarView` is a subclass of `UIView` for displaying a collection of images.
The images are arranged either horizontally or vertically, depending on the
dimensions of the view. It supports selection, scrolling, drag-and-drop
rearranging, and drag-and-drop deletion. The API is patterned after `UITableView`,
so it will be familiar to Cocoa Touch programmers. HSImageSidebarView works with
both iPad and iPhone interface idioms.

![Sample screenshot](https://github.com/bjhomer/HSImageSidebarView/raw/master/sampleImage.png)

An `HSImageSidebarView` is created using the standard `initWithFrame:` method
on `UIView`.

    // Create an 80-pixel sidebar on the left side of the screen
    HSImageSidebarView *sidebar = [[HSImageSidebarView alloc] initWithFrame:CGRectMake(0, 0, 80, 1004)];
    sidebar.delegate = self;
    
    [parentView addSubview:sidebar];
    
    [sidebar release];

It can also be created in Interface Builder by adding a `UIView` and then setting
its class (in IB) to `HSImageSidebarView`.

The image sidebar receives all its information through delegate methods. The
two required methods are these:

    - (NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar;
    - (UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex;

When a user taps, moves, or deletes an image, the delegate can be notified through
one of these methods:

    - (void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex;
    - (void)sidebar:(HSImageSidebarView *)sidebar didMoveImageAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;
    - (void)sidebar:(HSImageSidebarView *)sidebar didRemoveImageAtIndex:(NSUInteger)anIndex;
    
`HSImageSidebarView` requires iOS 4.0 or later. A sample project is included to
demonstrate usage.

To Do
-----

The following are features which I would like to see added, but which haven't
been completed yet:

- Expose selection color property
- Enable/disable drag-to-move
- Enable/disable drag-to-delete
- Be smarter about calculating the image frame when the the aspect fit 
  doesn't fill the whole frame. (This mostly applies when trying to position
  a popover correctly.)
- Add support for indentation levels
- Add support for numbering images
- Add support for multiple selection