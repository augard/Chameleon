
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

#import <UIKit/UIEvent.h>

@class UIView;

@interface UIResponder : NSObject
#pragma mark Managing the Responder Chain
- (UIResponder*) nextResponder;
- (BOOL) isFirstResponder;
- (BOOL) canBecomeFirstResponder;
- (BOOL) becomeFirstResponder;
- (BOOL) canResignFirstResponder;
- (BOOL) resignFirstResponder;

#pragma mark Managing Input Views
@property (readonly, retain) UIView* inputView;
@property (readonly, retain) UIView* inputAccessoryView;
- (void)reloadInputViews;

#pragma mark Responding to Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

#pragma mark Responding to Motion Events
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event;

#pragma mark Responding to Remote-Control Events
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;

#pragma mark Getting the Undo Manager
@property(readonly) NSUndoManager *undoManager;

#pragma mark Validating Commands
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;

@end


@interface NSObject (UIResponderStandardEditActions)

#pragma mark Handling Copy, Cut, Delete, and Paste Commands
- (void) copy:(id)sender;
- (void) cut:(id)sender;
- (void) delete:(id)sender;
- (void) paste:(id)sender;

#pragma mark Handling Selection Commands
- (void) select:(id)sender;
- (void) selectAll:(id)sender;

#pragma mark Handling Styled Text Editing
- (void) toggleBoldface:(id)sender;
- (void) toggleItalics:(id)sender;
- (void) toggleUnderline:(id)sender;

#pragma mark Handling Writing Direction Changes
- (void) makeTextWritingDirectionLeftToRight:(id)sender;
- (void) makeTextWritingDirectionRightToLeft:(id)sender;

@end
