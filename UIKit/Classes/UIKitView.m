/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIKitView.h"
#import "UIApplication+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIWindow+UIPrivate.h"
#import "UIImage.h"
#import "UIImageView.h"
#import "UIColor.h"
#import "UIPopoverController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSEvent+UIKit.h"
#import "UIResponder+AppKit.h"


@implementation UIKitView {
    id ob1;
    id ob2;
}

- (void) viewWillMoveToWindow:(NSWindow*)window
{
    if (window != nil) {
        ob1 = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeKeyNotification object:window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            if (self == [window firstResponder]) {
                [[self UIWindow] makeKeyWindow];
            }
        }];
        ob2 = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [[self UIWindow] resignKeyWindow];
        }];
    } else {
        ob1 = nil;
        ob2 = nil;
    }
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    return (id)[NSNull null];
}

- (void)setScreenLayer
{
    [self setWantsLayer:YES];
    
    CALayer *myLayer = [self layer];
    myLayer.delegate = self;
    
    CALayer *screenLayer = [_screen _layer];
    screenLayer.frame = myLayer.bounds;
    screenLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;

    if (myLayer.geometryFlipped == screenLayer.geometryFlipped) {
        CALayer* geometryAdapterLayer = [CALayer layer];
        geometryAdapterLayer.frame = myLayer.bounds;
        geometryAdapterLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        geometryAdapterLayer.geometryFlipped = YES;
        [geometryAdapterLayer addSublayer:screenLayer];
        [myLayer addSublayer:geometryAdapterLayer];
        _usingGeometryAdapter = YES;
    } else {
        [myLayer addSublayer:screenLayer];
    }
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _screen = [[UIScreen alloc] init];
        [self setScreenLayer];
    }
    return self;
}


- (void)awakeFromNib
{
    [self setScreenLayer];
}

- (UIWindow *)UIWindow
{
    if (!_mainWindow) {
        _mainWindow = [[UIWindow alloc] initWithFrame:_screen.bounds];
        _mainWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mainWindow.screen = _screen;
    }
    
    return _mainWindow;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)updateUIKitView
{
    [_screen _setUIKitView:(self.superview && self.window)? self : nil];
}

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    [self updateUIKitView];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if (self.window) {
        [self setScreenLayer];
    }
    [self updateUIKitView];
}

- (BOOL) acceptsFirstMouse:(NSEvent*)event
{
    UIScreen* screen = [[self UIWindow] screen];
    UIResponder* responder = [screen _hitTest:[event locationInScreen:screen] event:nil];
    while (responder) {
        if ([responder respondsToSelector:@selector(acceptsFirstMouse)]) {
            return [responder acceptsFirstMouse];
        }
        responder = [responder nextResponder];
    }
    return [super acceptsFirstMouse:event];
}

- (BOOL) acceptsFirstResponder
{
    return [[self UIWindow] _acceptsFirstResponder];
}

- (BOOL) becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        [[self UIWindow] makeKeyWindow];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [[self UIWindow] resignKeyWindow];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)firstResponderCanPerformAction:(SEL)action withSender:(id)sender
{
    return [[UIApplication sharedApplication] _firstResponderCanPerformAction:action withSender:sender fromScreen:_screen];
}

- (void)sendActionToFirstResponder:(SEL)action from:(id)sender
{
    [[UIApplication sharedApplication] _sendActionToFirstResponder:action withSender:sender fromScreen:_screen];
}

- (BOOL)respondsToSelector:(SEL)cmd
{
    if (cmd == @selector(copy:) ||
        cmd == @selector(cut:) ||
        cmd == @selector(delete:) ||
        cmd == @selector(paste:) ||
        cmd == @selector(select:) ||
        cmd == @selector(selectAll:) ||
        cmd == @selector(commit:) ||
        cmd == @selector(cancel:)) {
        return [self firstResponderCanPerformAction:cmd withSender:nil];
    } else if (cmd == @selector(cancelOperation:)) {
        return [self firstResponderCanPerformAction:@selector(cancel:) withSender:nil];
    } else {
        return [super respondsToSelector:cmd];
    }
}

- (void)copy:(id)sender				{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)cut:(id)sender				{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)delete:(id)sender			{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)paste:(id)sender			{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)select:(id)sender			{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)selectAll:(id)sender		{ [self sendActionToFirstResponder:_cmd from:sender]; }

// these are special additions
- (void)cancel:(id)sender			{ [self sendActionToFirstResponder:_cmd from:sender]; }
- (void)commit:(id)sender			{ [self sendActionToFirstResponder:_cmd from:sender]; }

// this is a special case, UIKit doesn't normally send anything like this.
// if a UIKit first responder can't handle it, then we'll pass it through to the next responder
// because something else might want to deal with it somewhere else.
- (void)cancelOperation:(id)sender
{
    [self sendActionToFirstResponder:@selector(cancel:) from:sender];
}

// capture the key presses here and turn them into key events which are sent down the UIKit responder chain
// if they come back as unhandled, pass them along the AppKit responder chain.
- (void)keyDown:(NSEvent *)theEvent
{
    if (![[UIApplication sharedApplication] _sendKeyboardNSEvent:theEvent fromScreen:_screen]) {
        [super keyDown:theEvent];
    }
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    [self removeTrackingArea:_trackingArea];
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingCursorUpdate|NSTrackingMouseMoved|NSTrackingInVisibleRect|NSTrackingActiveInKeyWindow|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)beginGestureWithEvent:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)endGestureWithEvent:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)rotateWithEvent:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)magnifyWithEvent:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)swipeWithEvent:(NSEvent *)theEvent
{
    [[UIApplication sharedApplication] _sendMouseNSEvent:theEvent fromScreen:_screen];
}

- (void)_launchApplicationWithDefaultWindow:(UIWindow *)defaultWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    id<UIApplicationDelegate> appDelegate = app.delegate;
    
    if ([appDelegate respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
        [appDelegate application:app didFinishLaunchingWithOptions:nil];
    } else if ([appDelegate respondsToSelector:@selector(applicationDidFinishLaunching:)]) {
        [appDelegate applicationDidFinishLaunching:app];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification object:app];
    
    if ([appDelegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [appDelegate applicationDidBecomeActive:app];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:app];
    
    defaultWindow.hidden = YES;
}

- (void)launchApplicationWithDelegate:(id<UIApplicationDelegate>)appDelegate afterDelay:(NSTimeInterval)delay
{
    [[UIApplication sharedApplication] setDelegate:appDelegate];

    if (delay) {
        UIImage *defaultImage = [UIImage imageNamed:@"Default-Landscape.png"];
        UIImageView *defaultImageView = [[UIImageView alloc] initWithImage:defaultImage];
        defaultImageView.contentMode = UIViewContentModeCenter;
        
        UIWindow *defaultWindow = [(UIWindow *)[UIWindow alloc] initWithFrame:_screen.bounds];
        defaultWindow.userInteractionEnabled = NO;
        defaultWindow.screen = _screen;
        defaultWindow.backgroundColor = [UIColor blackColor];	// dunno..
        defaultWindow.opaque = YES;
        [defaultWindow addSubview:defaultImageView];
        [defaultWindow makeKeyAndVisible];
        [self performSelector:@selector(_launchApplicationWithDefaultWindow:) withObject:defaultWindow afterDelay:delay];
    } else {
        [self _launchApplicationWithDefaultWindow:nil];
    }
}

@end
