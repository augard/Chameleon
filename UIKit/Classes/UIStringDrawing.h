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

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

UIKIT_EXTERN NSString* const UITextAttributeFont;
UIKIT_EXTERN NSString* const UITextAttributeTextColor;
UIKIT_EXTERN NSString* const UITextAttributeTextShadowColor;
UIKIT_EXTERN NSString* const UITextAttributeTextShadowOffset;

typedef enum {
    UILineBreakModeWordWrap = 0,
    UILineBreakModeCharacterWrap,
    UILineBreakModeClip,
    UILineBreakModeHeadTruncation,
    UILineBreakModeTailTruncation,
    UILineBreakModeMiddleTruncation,
} UILineBreakMode;

typedef enum {
    UITextAlignmentLeft = 0,
    UITextAlignmentCenter = 2,
    UITextAlignmentRight = 1,
} UITextAlignment;

typedef enum {
    UIBaselineAdjustmentAlignBaselines,
    UIBaselineAdjustmentAlignCenters,
    UIBaselineAdjustmentNone,
} UIBaselineAdjustment;

@class UIFont;

@interface NSString (UIStringDrawing)

#pragma mark Computing Metrics for a Single Line of Text
- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode;
- (CGSize)sizeWithFont:(UIFont *)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode; //NI

#pragma mark Computing Metrics for Multiple Lines of Text
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(UILineBreakMode)lineBreakMode;

#pragma mark Drawing Strings on a Single Line
- (CGSize)drawAtPoint:(CGPoint)point withFont:(UIFont *)font;
- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode;
- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font fontSize:(CGFloat)fontSize lineBreakMode:(UILineBreakMode)lineBreakMode baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment;
- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize lineBreakMode:(UILineBreakMode)lineBreakMode baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment; // NI

#pragma mark Drawing Strings in a Given Area
- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font;
- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode;
- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment;

@end
