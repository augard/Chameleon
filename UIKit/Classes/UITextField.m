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

#import "UITextField.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIBezierPath.h"
#import "UIGraphics.h"
#import "UILabel.h"
#import "UITapGestureRecognizer.h"
#import "UITextStorage.h"
#import "_UITextInteractionAssistant.h"
#import "_UITextFieldEditor.h"
#import "NSParagraphStyle.h"
/**/
#import "UIImage.h"
#import "UIImage+UIPrivate.h"
#import <AppKit/NSCursor.h>


NSString* const UITextFieldTextDidBeginEditingNotification = @"UITextFieldTextDidBeginEditingNotification";
NSString* const UITextFieldTextDidChangeNotification = @"UITextFieldTextDidChangeNotification";
NSString* const UITextFieldTextDidEndEditingNotification = @"UITextFieldTextDidEndEditingNotification";


static NSString* const kUIPlaceholderKey = @"UIPlaceholder";
static NSString* const kUITextAlignmentKey = @"UITextAlignment";
static NSString* const kUITextKey = @"UIText";
static NSString* const kUITextFieldBackgroundKey = @"UITextFieldBackground";
static NSString* const kUITextFieldDisabledBackgroundKey = @"UITextFieldDisabledBackground";
static NSString* const kUIBorderStyleKey = @"UIBorderStyle";
static NSString* const kUIClearsOnBeginEditingKey = @"UIClearsOnBeginEditing";
static NSString* const kUIMinimumFontSizeKey = @"UIMinimumFontSize";
static NSString* const kUIFontKey = @"UIFont";
static NSString* const kUIClearButtonModeKey = @"UIClearButtonMode";
static NSString* const kUIClearButtonOffsetKey = @"UIClearButtonOffset";
static NSString* const kUIAutocorrectionTypeKey = @"UIAutocorrectionType";
static NSString* const kUISpellCheckingTypeKey = @"UISpellCheckingType";
static NSString* const kUIKeyboardAppearanceKey = @"UIKeyboardAppearance";
static NSString* const kUIKeyboardTypeKey = @"UIKeyboardType";
static NSString* const kUIReturnKeyTypeKey = @"UIReturnKeyType";
static NSString* const kUIEnablesReturnKeyAutomaticallyKey = @"UIEnablesReturnKeyAutomatically";
static NSString* const kUISecureTextEntryKey = @"UISecureTextEntry";
static NSString* const kUIAttributedPlaceholderKey = @"UIAttributedPlaceholder";
static NSString* const kUIAttributedTextKey = @"UIAttributedText";


@interface NSObject (UITextFieldDelegate)
- (BOOL) textField:(UITextField*)textField doCommandBySelector:(SEL)selector;
@end


@implementation UITextField {
    NSTextStorage* _textStorage;
    NSMutableDictionary* _defaultTextAttributes;
    
    UILabel* _placeholderTextLabel;
    UILabel* _textLabel;
    _UITextFieldEditor* _textFieldEditor;
    
    _UITextInteractionAssistant* _interactionAssistant;
    
    struct {
        bool shouldBeginEditing : 1;
        bool didBeginEditing : 1;
        bool shouldEndEditing : 1;
        bool didEndEditing : 1;
        bool shouldChangeCharacters : 1;
        bool shouldClear : 1;
        bool shouldReturn : 1;
        bool doCommandBySelector : 1;
    } _delegateHas;
    
    struct {
        bool didBeginEditing : 1;
        bool hasText : 1;
    } _flags;
}

static void _commonInitForUITextField(UITextField* self)
{
    self.textAlignment = UITextAlignmentLeft;
    self.font = [UIFont systemFontOfSize:17];
    self.borderStyle = UITextBorderStyleNone;
    self.textColor = [UIColor blackColor];
    self.clearButtonMode = UITextFieldViewModeNever;
    self.leftViewMode = UITextFieldViewModeNever;
    self.rightViewMode = UITextFieldViewModeNever;
    self.opaque = NO;
    
    self->_textStorage = [[UITextStorage alloc] init];
}

- (id) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        _commonInitForUITextField(self);
    }
    return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        _commonInitForUITextField(self);
        if ([coder containsValueForKey:kUIAttributedPlaceholderKey]) {
            self.attributedPlaceholder = [coder decodeObjectForKey:kUIAttributedPlaceholderKey];
        } else if ([coder containsValueForKey:kUIPlaceholderKey]) {
            self.placeholder = [coder decodeObjectForKey:kUIPlaceholderKey];
        }
        
        if ([coder containsValueForKey:kUIAttributedTextKey]) {
            self.attributedText = [coder decodeObjectForKey:kUIAttributedTextKey];
        } else if ([coder containsValueForKey:kUITextKey]) {
            self.text = [coder decodeObjectForKey:kUITextKey];
        }

        if ([coder containsValueForKey:kUITextAlignmentKey]) {
            self.textAlignment = [coder decodeIntegerForKey:kUITextAlignmentKey];
        }
        if ([coder containsValueForKey:kUITextFieldBackgroundKey]) {
            self.background = [coder decodeObjectForKey:kUITextFieldBackgroundKey];
        }
        if ([coder containsValueForKey:kUITextFieldDisabledBackgroundKey]) {
            self.disabledBackground = [coder decodeObjectForKey:kUITextFieldDisabledBackgroundKey];
        }
        if ([coder containsValueForKey:kUIBorderStyleKey]) {
            self.borderStyle = [coder decodeIntegerForKey:kUIBorderStyleKey];
        }
        if ([coder containsValueForKey:kUIClearsOnBeginEditingKey]) {
            self.clearsOnBeginEditing = [coder decodeBoolForKey:kUIClearsOnBeginEditingKey];
        }
        if ([coder containsValueForKey:kUIMinimumFontSizeKey]) {
            self.minimumFontSize = [coder decodeFloatForKey:kUIMinimumFontSizeKey];
        }
        if ([coder containsValueForKey:kUIFontKey]) {
            self.font = [coder decodeObjectForKey:kUIFontKey];
        }
        if ([coder containsValueForKey:kUIClearButtonModeKey]) {
            self.clearButtonMode = [coder decodeIntegerForKey:kUIClearButtonModeKey];
        }
        if ([coder containsValueForKey:kUIAutocorrectionTypeKey]) {
            self.autocorrectionType = [coder decodeIntegerForKey:kUIAutocorrectionTypeKey];
        }
        if ([coder containsValueForKey:kUIClearButtonOffsetKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUISpellCheckingTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIKeyboardAppearanceKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIKeyboardTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIReturnKeyTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIEnablesReturnKeyAutomaticallyKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUISecureTextEntryKey]) {
            /* XXX: Implement Me */
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Layout

- (BOOL) _isLeftViewVisible
{
    return _leftView && (_leftViewMode == UITextFieldViewModeAlways
                         || (_editing && _leftViewMode == UITextFieldViewModeWhileEditing)
                         || (!_editing && _leftViewMode == UITextFieldViewModeUnlessEditing));
}

- (BOOL) _isRightViewVisible
{
    return _rightView && (_rightViewMode == UITextFieldViewModeAlways
                         || (_editing && _rightViewMode == UITextFieldViewModeWhileEditing)
                         || (!_editing && _rightViewMode == UITextFieldViewModeUnlessEditing));
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    const CGRect bounds = self.bounds;

    if ([self _isLeftViewVisible]) {
        _leftView.hidden = NO;
        _leftView.frame = [self leftViewRectForBounds:bounds];
    } else {
        _leftView.hidden = YES;
    }

    if ([self _isRightViewVisible]) {
        _rightView.hidden = NO;
        _rightView.frame = [self rightViewRectForBounds:bounds];
    } else {
        _rightView.hidden = YES;
    }
    
    if (_textLabel || _placeholderTextLabel) {
        CGRect textRect = [self textRectForBounds:bounds];
        [_textLabel setFrame:textRect];
        [_placeholderTextLabel setFrame:textRect];
    }
}


#pragma mark Properties

- (void) setAttributedPlaceholder:(NSAttributedString*)attributedPlaceholder
{
    if (attributedPlaceholder) {
        _attributedPlaceholder = [self _adjustAttributesForPlaceholder:attributedPlaceholder];
        if (!_placeholderTextLabel) {
            _placeholderTextLabel = [[UILabel alloc] initWithFrame:[self textRectForBounds:[self bounds]]];
            [_placeholderTextLabel setBackgroundColor:[self backgroundColor]];
        }
        [_placeholderTextLabel setAttributedText:_attributedPlaceholder];
        if (![_placeholderTextLabel superview]) {
            if (![self isEditing] && ![[self text] length]) {
                [self addSubview:_placeholderTextLabel];
            }
        }
    } else {
        _attributedPlaceholder = nil;
        [_placeholderTextLabel removeFromSuperview], _placeholderTextLabel = nil;
    }
}

- (NSAttributedString*) attributedText
{
    return [[NSAttributedString alloc] initWithAttributedString:_textStorage];
}

- (void) setAttributedText:(NSAttributedString*)attributedText
{
    if (attributedText) {
        [_textStorage replaceCharactersInRange:(NSRange){ 0, [_textStorage length] } withAttributedString:attributedText];
        _flags.hasText = [_textStorage length] > 0;
        if ([self hasText]) {
            [_placeholderTextLabel removeFromSuperview];
        }
        if (!_textLabel) {
            _textLabel = [[UILabel alloc] initWithFrame:[self textRectForBounds:[self bounds]]];
            [_textLabel setBackgroundColor:[self backgroundColor]];
        }
        [_textLabel setAttributedText:attributedText];
        if (![_textLabel superview]) {
            if (![self isEditing] && [self hasText]) {
                [self addSubview:_textLabel];
            }
        }
    } else {
        [_textStorage deleteCharactersInRange:(NSRange){ 0, [_textStorage length]}];
        [_textLabel removeFromSuperview], _textLabel = nil;
    }
}

- (UITextAutocapitalizationType) autocapitalizationType
{
    return UITextAutocapitalizationTypeNone;
}

- (void) setAutocapitalizationType:(UITextAutocapitalizationType)type
{
}

- (UITextAutocorrectionType) autocorrectionType
{
    return UITextAutocorrectionTypeDefault;
}

- (void) setAutocorrectionType:(UITextAutocorrectionType)type
{
}

- (void) setBackground:(UIImage*)background
{
    if (background != _background) {
        _background = background;
        [self setNeedsDisplay];
    }
}

- (void) setBackgroundColor:(UIColor*)backgroundColor
{
    if (backgroundColor != [self backgroundColor]) {
        [super setBackgroundColor:backgroundColor];
        [_textLabel setBackgroundColor:backgroundColor];
        [_placeholderTextLabel setBackgroundColor:backgroundColor];
    }
}

- (void) setBorderStyle:(UITextBorderStyle)borderStyle
{
    if (borderStyle != _borderStyle) {
        _borderStyle = borderStyle;
        [self setNeedsDisplay];
    }
}

- (NSDictionary*) defaultTextAttributes
{
    static NSDictionary* sharedDefaultTextAttributes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setTighteningFactorForTruncation:0.0f];
        [paragraphStyle setAlignment:(NSTextAlignment)_textAlignment];

        sharedDefaultTextAttributes = @{
            UITextAttributeFont: [UIFont systemFontOfSize:17.0f],
            UITextAttributeTextColor: [UIColor colorWithWhite:0.0f alpha:1.0f],
            NSKernAttributeName: @(0.0f),
            NSLigatureAttributeName: @(0.0f),
            NSParagraphStyleAttributeName: paragraphStyle,
        };
    });
    if (_defaultTextAttributes) {
        return [_defaultTextAttributes copy];
    } else {
        return sharedDefaultTextAttributes;
    }
}

- (void) setDefaultTextAttributes:(NSDictionary*)defaultTextAttributes
{
    _defaultTextAttributes = [NSMutableDictionary dictionaryWithDictionary:defaultTextAttributes];
    [_textStorage setAttributes:defaultTextAttributes range:(NSRange){ 0, [_textStorage length] }];
}

- (void) setDelegate:(id<UITextFieldDelegate>)delegate
{
    if (delegate != _delegate) {
        _delegate = delegate;
        _delegateHas.shouldBeginEditing = [delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)];
        _delegateHas.didBeginEditing = [delegate respondsToSelector:@selector(textFieldDidBeginEditing:)];
        _delegateHas.shouldEndEditing = [delegate respondsToSelector:@selector(textFieldShouldEndEditing:)];
        _delegateHas.didEndEditing = [delegate respondsToSelector:@selector(textFieldDidEndEditing:)];
        _delegateHas.shouldChangeCharacters = [delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)];
        _delegateHas.shouldClear = [delegate respondsToSelector:@selector(textFieldShouldClear:)];
        _delegateHas.shouldReturn = [delegate respondsToSelector:@selector(textFieldShouldReturn:)];
		_delegateHas.doCommandBySelector = [delegate respondsToSelector:@selector(textField:doCommandBySelector:)];
    }
}

- (void) setDisabledBackground:(UIImage*)disabledBackground
{
    if (disabledBackground != _disabledBackground) {
        _disabledBackground = disabledBackground;
        [self setNeedsDisplay];
    }
}

- (BOOL) enablesReturnKeyAutomatically
{
    return YES;
}

- (void) setEnablesReturnKeyAutomatically:(BOOL)enabled
{
}

- (void) setFont:(UIFont*)font
{
    NSAssert(nil != font, @"???");
    _font = font;
    [_placeholderTextLabel setFont:font];
    [_textLabel setFont:font];
    
    [_textStorage addAttribute:UITextAttributeFont value:font range:(NSRange){ 0, [_textStorage length] }];
    if (!_defaultTextAttributes) {
        _defaultTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[self defaultTextAttributes]];
        [_defaultTextAttributes setObject:font forKey:UITextAttributeFont];
    }
}

- (void) setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame,self.frame)) {
        [super setFrame:frame];
        [self setNeedsDisplay];
    }
}

- (UIKeyboardAppearance) keyboardAppearance
{
    return UIKeyboardAppearanceDefault;
}

- (void) setKeyboardAppearance:(UIKeyboardAppearance)type
{
}

- (UIKeyboardType) keyboardType
{
    return UIKeyboardTypeDefault;
}

- (void) setKeyboardType:(UIKeyboardType)type
{
}

- (void) setLeftView:(UIView*)leftView
{
    if (leftView != _leftView) {
        if (_leftView) {
            [_leftView removeFromSuperview];
        }
        _leftView = leftView;
        if (leftView) {
            [self addSubview:leftView];
        }
    }
}

- (NSString*) placeholder
{
    return [_attributedPlaceholder string];
}

- (void) setPlaceholder:(NSString*)placeholder
{
    if (placeholder) {
        [self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:[self defaultTextAttributes]]];
    } else {
        [self setAttributedPlaceholder:nil];
    }
}

- (void) setRightView:(UIView*)rightView
{
    if (rightView != _rightView) {
        if (_rightView) {
            [_rightView removeFromSuperview];
        }
        _rightView = rightView;
        if (rightView) {
            [self addSubview:rightView];
        }
    }
}

- (UIReturnKeyType) returnKeyType
{
    return UIReturnKeyDefault;
}

- (void) setReturnKeyType:(UIReturnKeyType)type
{
}

- (NSString*) text
{
    return [_textStorage string];
}

- (void) setText:(NSString*)text
{
    if (text) {
        [self setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:[self defaultTextAttributes]]];
    } else {
        [self setAttributedText:nil];
    }
}

- (void) setTextAlignment:(UITextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [_placeholderTextLabel setTextAlignment:textAlignment];
    [_textLabel setTextAlignment:textAlignment];
}

- (void) setTextColor:(UIColor*)textColor
{
    NSAssert(nil != textColor, @"???");
    _textColor = textColor;
    [_textStorage addAttribute:UITextAttributeTextColor value:textColor range:(NSRange){ 0, [_textStorage length] }];
    if (!_defaultTextAttributes) {
        _defaultTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[self defaultTextAttributes]];
        [_defaultTextAttributes setObject:textColor forKey:UITextAttributeTextColor];
    }
}


#pragma mark Geometry

- (CGRect) borderRectForBounds:(CGRect)bounds
{
    return bounds;
}

- (CGRect) clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect) editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect) leftViewRectForBounds:(CGRect)bounds
{
    if (_leftView) {
        const CGRect frame = _leftView.frame;
        bounds.origin.x = 0;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect) placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect) rightViewRectForBounds:(CGRect)bounds
{
    if (_rightView) {
        const CGRect frame = _rightView.frame;
        bounds.origin.x = bounds.size.width - frame.size.width;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect) textRectForBounds:(CGRect)bounds
{
    CGRect textRect;
    switch ([self borderStyle]) {
        case UITextBorderStyleRoundedRect: {
            textRect = CGRectOffset(CGRectInset(bounds, 7.0f, 2.0f), -1.0f, 0.0f);
            break;
        }
        case UITextBorderStyleBezel: {
            textRect = CGRectOffset(CGRectInset(bounds, 7.0f, 2.5f), 0.0f, 1.5f);
            break;
        }
        case UITextBorderStyleLine: {
            textRect = CGRectInset(bounds, 2.0f, 2.0f);
            break;
        }
        case UITextBorderStyleNone: {
            textRect = bounds;
            break;
        }
	}
    
    if ([self _isLeftViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect, [self leftViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }
    
    if ([self _isRightViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect, [self rightViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, -overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }

    return textRect;
}


#pragma mark Drawing

- (void) drawPlaceholderInRect:(CGRect)rect
{
}

- (void) drawTextInRect:(CGRect)rect
{
}

- (void) drawRect:(CGRect)rect
{
    UIImage* currentBackgroundImage = nil;
	if ([self borderStyle] == UITextBorderStyleRoundedRect) {
		currentBackgroundImage = [UIImage _textFieldRoundedRectBackground];
	} else {
		currentBackgroundImage = [self isEnabled]? _background : _disabledBackground;
	}
	
	CGRect borderFrame = [self borderRectForBounds:[self bounds]];
	if (currentBackgroundImage) {
		[currentBackgroundImage drawInRect:borderFrame];
	} else {
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		// TODO: draw the appropriate background for the borderStyle
		
		if(self.borderStyle == UITextBorderStyleBezel) {
			// bottom white highlight
			CGRect hightlightFrame = CGRectMake(0.0, 10.0, borderFrame.size.width, borderFrame.size.height-10.0);
			[[UIColor colorWithWhite:1.0 alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:hightlightFrame cornerRadius:3.6] fill];
			
			// top white highlight
			CGRect topHightlightFrame = CGRectMake(0.0, 0.0, borderFrame.size.width, borderFrame.size.height-10.0);
			[[UIColor colorWithWhite:0.7f alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:topHightlightFrame cornerRadius:3.6] fill];
			
			// black outline
			CGRect blackOutlineFrame = CGRectMake(0.0, 1.0, borderFrame.size.width, borderFrame.size.height-2.0);
			
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGFloat locations[] = { 1.0f, 0.0f };
			CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) @[(id)[UIColor colorWithWhite:0.5 alpha:1.0].CGColor, (id)[UIColor colorWithWhite:0.65 alpha:1.0].CGColor], locations);
			
			CGContextSaveGState(context);
			CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:blackOutlineFrame cornerRadius:3.6f].CGPath);
			CGContextClip(context);
			
			CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, CGRectGetMinY(blackOutlineFrame)), CGPointMake(0.0f, CGRectGetMaxY(blackOutlineFrame)), 0);
			CFRelease(colorSpace);
			CFRelease(gradient);
			
			CGContextRestoreGState(context);
						
			// top inner shadow
			CGRect shadowFrame = CGRectMake(1, 2, borderFrame.size.width-2.0, 10.0);
			[[UIColor colorWithWhite:0.88 alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:shadowFrame cornerRadius:2.9] fill];	
			
			// main white area
			CGRect whiteFrame = CGRectMake(1, 3, borderFrame.size.width-2.0, borderFrame.size.height-5.0);
			[[UIColor whiteColor] set];
			[[UIBezierPath bezierPathWithRoundedRect:whiteFrame cornerRadius:2.6] fill];
		} else if(self.borderStyle == UITextBorderStyleLine) {
			[[UIColor blackColor] set];
            UIRectFrame(borderFrame);
		}
	}
}


#pragma mark UITextInput

- (id<UITextInput>) inputDelegate
{
    return nil;
}

- (void) setInputDelegate:(id<UITextInput>)inputDelegate
{
    // TODO
}

- (BOOL) hasText
{
    return _flags.hasText;
}

- (void) insertText:(NSString*)text
{
    // TODO
}


#pragma mark UIView

- (void) willMoveToWindow:(UIWindow*)window
{
    [super willMoveToWindow:window];
    if (window) {
        _interactionAssistant = [[_UITextInteractionAssistant alloc] initWithView:self];
        [self addGestureRecognizer:[_interactionAssistant singleTapGesture]];
    } else {
        [self removeGestureRecognizer:[_interactionAssistant singleTapGesture]];
        _interactionAssistant = nil;
    }
}


#pragma mark UIResponder

- (BOOL) canBecomeFirstResponder
{
    return ([self window] != nil) && [self isEnabled] && [self _textShouldBeginEditing];
}

- (BOOL) canResignFirstResponder
{
    return [self _textShouldEndEditing];
}

- (BOOL) becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        _editing = YES;
        [self _textDidBeginEditing];
        [_textLabel removeFromSuperview];
        [_placeholderTextLabel removeFromSuperview];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) resignFirstResponder
{
    if ([super resignFirstResponder]) {
        _editing = NO;
        [self _textDidEndEditing];
        if ([self hasText]) {
            if (_textLabel) {
                [self addSubview:_textLabel];
            }
        } else {
            if (_placeholderTextLabel) {
                [self addSubview:_placeholderTextLabel];
            }
        }
        return YES;
    } else {
        return NO;
    }
}


#pragma mark Events & Notification

- (BOOL) _textShouldBeginEditing
{
    return _delegateHas.shouldBeginEditing? [_delegate textFieldShouldBeginEditing:self] : YES;
}

- (void) _textDidBeginEditing
{
    BOOL shouldClear = _clearsOnBeginEditing;

    if (shouldClear && _delegateHas.shouldClear) {
        shouldClear = [_delegate textFieldShouldClear:self];
    }

    if (shouldClear) {
        [self setText:@""];
    }

    if (_delegateHas.didBeginEditing) {
        [_delegate textFieldDidBeginEditing:self];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidBeginEditingNotification object:self];
}

- (BOOL) _textShouldEndEditing
{
    return _delegateHas.shouldEndEditing? [_delegate textFieldShouldEndEditing:self] : YES;
}

- (void) _textDidEndEditing
{
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    if (_delegateHas.didEndEditing) {
        [_delegate textFieldDidEndEditing:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidEndEditingNotification object:self];
}

- (BOOL) _textShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return _delegateHas.shouldChangeCharacters? [_delegate textField:self shouldChangeCharactersInRange:range replacementString:text] : YES;
}

- (void) _textDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

- (void) _textDidReceiveReturnKey
{
    if (_delegateHas.shouldReturn) {
        [_delegate textFieldShouldReturn:self];
    }
}

- (BOOL) _textShouldDoCommandBySelector:(SEL)selector
{
	if(_delegateHas.doCommandBySelector) {
		return [(id)self.delegate textField:self doCommandBySelector:selector];
	} else {
		if(selector == @selector(insertNewline:) || selector == @selector(insertNewlineIgnoringFieldEditor:)) {
			[self _textDidReceiveReturnKey];
			return YES;
		}
	}
	
	return NO;
}


#pragma mark Misc.

- (NSAttributedString*) _adjustAttributesForPlaceholder:(NSAttributedString*)string
{
    NSMutableAttributedString* s = [string mutableCopy];
    [s addAttribute:UITextAttributeTextColor value:[UIColor colorWithRed:0.0f green:0.0f blue:0.1f alpha:0.22f] range:(NSRange){ 0, [s length] }];
    return s;
}

- (NSString*) description
{
    NSString *textAlignment = @"";
    switch (self.textAlignment) {
        case UITextAlignmentLeft:
            textAlignment = @"Left";
            break;
        case UITextAlignmentCenter:
            textAlignment = @"Center";
            break;
        case UITextAlignmentRight:
            textAlignment = @"Right";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; textAlignment = %@; editing = %@; textColor = %@; font = %@; delegate = %@>", [self className], self, textAlignment, (self.editing ? @"YES" : @"NO"), self.textColor, self.font, self.delegate];
}

- (id) mouseCursorForEvent:(UIEvent*)event
{
    return [NSCursor IBeamCursor];
}

@end
