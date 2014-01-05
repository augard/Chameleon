#import <UIKit/UIView.h>


@interface UIView () 
@property (nonatomic, copy) NSString *toolTip;
@end


@class NSView;

@interface UIView (AppKitIntegration)
- (void) setNextKeyView:(UIView*)view;
- (UIView*) nextKeyView;
- (UIView*) previousKeyView;
- (UIView*) nextValidKeyView;
- (UIView*) previousValidKeyView;

- (UIView*) addSubNSView:(NSView *)view;

@end
