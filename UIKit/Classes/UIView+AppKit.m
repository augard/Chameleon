#import "UIView+AppKit.h"
#import "UIView+UIPrivate.h"
#import "UIViewAdapter.h"


@interface NSView : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic) UIViewAutoresizing autoresizingMask;

@end


@implementation UIView (AppKitIntegration)

- (UIView*) nextKeyView
{
    return _nextKeyView;
}

- (UIView*) previousKeyView
{
    return _previousKeyView;
}

- (void) _setPreviousKeyView:(UIView*)previousKeyView
{
    _previousKeyView = previousKeyView;
}

- (void) setNextKeyView:(UIView*)nextKeyView
{
    _nextKeyView = nextKeyView;
    [nextKeyView _setPreviousKeyView:self];
}

- (UIView*) nextValidKeyView
{
    UIView* next = [self nextKeyView];
    while (next && next != self && ![next canBecomeFirstResponder]) {
        next = [next nextKeyView];
    }
    return next;
}

- (UIView*) previousValidKeyView
{
    UIView* prev = [self previousKeyView];
    while (prev && prev != self && ![prev canBecomeFirstResponder]) {
        prev = [prev previousKeyView];
    }
    return prev;
}

- (UIView*) addSubNSView:(NSView *)view
{
    UIViewAdapter *adapterView = [[UIViewAdapter alloc] initWithFrame:[view frame]];
    [adapterView setAutoresizingMask:view.autoresizingMask];
    [adapterView setNSView:view];
    [adapterView setScrollEnabled:NO];
    [view setFrame:adapterView.bounds];
    [self addSubview:adapterView];
    return adapterView;
}

@end
