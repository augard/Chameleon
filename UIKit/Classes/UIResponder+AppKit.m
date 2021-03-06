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

#import "UIResponder+AppKit.h"
#import "UIEvent+UIPrivate.h"
#import "UIKey.h"
#import "UIApplication.h"
#import <AppKit/NSGraphics.h>
#import <AppKit/NSEvent.h>


@implementation UIResponder (AppKitIntegration)

- (void) windowDidBecomeKey
{
}

- (void) windowDidResignKey
{
}

- (void) scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(scrollWheelMoved:withEvent:)]) {
        [responder scrollWheelMoved:delta withEvent:event];
    }
}

- (void) rightClick:(UITouch *)touch withEvent:(UIEvent *)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(rightClick:withEvent:)]) {
        [responder rightClick:touch withEvent:event];
    }
}

- (void) mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(mouseExitedView:enteredView:withEvent:)]) {
        [responder mouseExitedView:exited enteredView:entered withEvent:event];
    }
}

- (void) mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(mouseMoved:withEvent:)]) {
        [responder mouseMoved:delta withEvent:event];
    }
}

- (id) mouseCursorForEvent:(UIEvent *)event
{
    id responder = [self nextResponder];
    if ([responder respondsToSelector:@selector(mouseCursorForEvent:)]) {
        return [responder mouseCursorForEvent:event];
    } else {
        return nil;
    }
}

- (BOOL)keyPressed:(UIKey *)key withEvent:(UIEvent *)event
{
    SEL command = nil;
    switch (key.type) {
        case UIKeyTypeReturn:
        case UIKeyTypeEnter: {
            command = @selector(insertNewline:);
            break;
        }
        case UIKeyTypeUpArrow: {
            if ([key isOptionKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveParagraphBackwardOrMoveUpAndModifySelection:) : @selector(moveToBeginningOfParagraphOrMoveUp:);
            } else if ([key isCommandKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveToBeginningOfDocumentAndModifySelection:) : @selector(moveToBeginningOfDocument:);
            } else if ([key isControlKeyPressed]) {
                command = @selector(scrollPageUp:);
            } else {
                command = [key isShiftKeyPressed] ? @selector(moveUpAndModifySelection:) : @selector(moveUp:);
            }
            break;
        }
        case UIKeyTypeDownArrow: {
            if ([key isOptionKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveParagraphForwardOrMoveDownAndModifySelection:) : @selector(moveToEndOfParagraphOrMoveDown:);
            } else if ([key isCommandKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveToEndOfDocumentAndModifySelection:) : @selector(moveToEndOfDocument:);
            } else if ([key isControlKeyPressed]) {
                command = @selector(scrollPageUp:);
            } else {
                command = [key isShiftKeyPressed] ? @selector(moveDownAndModifySelection:) : @selector(moveDown:);
            }
            break;
        }
        case UIKeyTypeLeftArrow: {
            if ([key isOptionKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveWordLeftAndModifySelection:) : @selector(moveWordLeft:);
            } else if ([key isCommandKeyPressed] || [key isControlKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveToBeginningOfLineAndModifySelection:) : @selector(moveToBeginningOfLine:);
            } else {
                command = [key isShiftKeyPressed] ? @selector(moveLeftAndModifySelection:) : @selector(moveLeft:);
            }
            break;
        }
        case UIKeyTypeRightArrow: {
            if ([key isOptionKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveWordRightAndModifySelection:) : @selector(moveWordRight:);
            } else if ([key isControlKeyPressed] || [key isCommandKeyPressed]) {
                command = [key isShiftKeyPressed] ? @selector(moveToEndOfLineAndModifySelection:) : @selector(moveToEndOfLine:);
            } else {
                command = [key isShiftKeyPressed] ? @selector(moveRightAndModifySelection:) : @selector(moveRight:);
            }
            break;
        }
        case UIKeyTypePageUp: {
            command = @selector(pageUp:);
            break;
        }
        case UIKeyTypePageDown: {
            command = @selector(pageDown:);
            break;
        }
        case UIKeyTypeHome: {
            command = [key isShiftKeyPressed] ? @selector(moveToBeginningOfDocumentAndModifySelection:) : @selector(scrollToBeginningOfDocument:);
            break;
        }
        case UIKeyTypeEnd: {
            command = [key isShiftKeyPressed] ? @selector(moveToEndOfDocumentAndModifySelection:) : @selector(scrollToEndOfDocument:);
            break;
        }
        case UIKeyTypeInsert: {
            // TODO something
            break;
        }
        case UIKeyTypeDelete: {
            if ([key isOptionKeyPressed]){
                command = @selector(deleteWordForward:);
            } else if ([key isControlKeyPressed]){
                command = @selector(deleteForwardByDecomposingPreviousCharacter:);
            } else {
                command = @selector(deleteForward:);
            }
            break;
        }
        case UIKeyTypeEscape: {
            command = @selector(cancelOperation:);
            break;
        }
        case UIKeyTypeCharacter: {
            switch ([key keyCode]) {
                case 0: { // 'a' key
                    if ([key isControlKeyPressed]) {
                        if ([key isShiftKeyPressed]) {
                            command = @selector(moveParagraphBackwardAndModifySelection:);
                        } else {
                            command = @selector(moveToBeginningOfParagraph:);
                        }
                    } else {
                        command = @selector(insertText:);
                    }
                    break;
                }
                    
                case 14: { // e key
                    if ([key isControlKeyPressed]) {
                        if ([key isShiftKeyPressed]) {
                            command = @selector(moveParagraphForwardAndModifySelection:);
                        } else {
                            command = @selector(moveToEndOfParagraph:);
                        }
                    } else {
                        command = @selector(insertText:);
                    }
                    break;
                }
                    
                case 7:{ // x key
                    command = [key isCommandKeyPressed]? @selector(cut:) : @selector(insertText:);
                    break;
                }
                    
                case 8:{ // c key
                    command = [key isCommandKeyPressed]? @selector(copy:) : @selector(insertText:);
                    break;
                }
                    
                case 9:{ // v key
                    command = [key isCommandKeyPressed]? @selector(paste:) : @selector(insertText:);
                    break;
                }
                    
                case 48: {
                    command = [key isShiftKeyPressed]? @selector(insertBacktab:) : @selector(insertTab:);
                    break;
                }
                    
                case 51: {
                    if ([key isOptionKeyPressed]){
                        command = @selector(deleteWordBackward:);
                    } else if ([key isControlKeyPressed]){
                        command = @selector(deleteBackwardByDecomposingPreviousCharacter:);
                    } else {
                        command = @selector(deleteBackward:);
                    }
                    break;
                }

                default: {
                    command = @selector(insertText:);
                    break;
                }
            }
            break;
        }
    }

    if (command == @selector(insertText:)) {
        UIResponder* responder = self;
        while (responder) {
            if ([responder respondsToSelector:@selector(insertText:)]) {
                [responder insertText:[key characters]];
                return YES;
            }
            responder = [responder nextResponder];
        }
    } else if (command) {
        [self doCommandBySelector:command];
        return YES;
    }
    return NO;
}

- (void) doCommandBySelector:(SEL)selector
{
    UIResponder* responder = self;
    do {
        if ([responder tryToPerform:selector with:self]) {
            return;
        }
        responder = [responder nextResponder];
    } while (responder);
    NSBeep();
}

- (BOOL) tryToPerform:(SEL)selector with:(id)object
{
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:nil];
#pragma clang diagnostic pop
        return YES;
    } else {
        return NO;
    }
}

@end
