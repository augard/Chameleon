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

#import "UIFont.h"
#import <Cocoa/Cocoa.h>

static NSString *UIFontSystemFontName = nil;
static NSString *UIFontBoldSystemFontName = nil;

@implementation UIFont

+ (void)setSystemFontName:(NSString *)aName
{
	[UIFontSystemFontName release];
	UIFontSystemFontName = [aName copy];
}

+ (void)setBoldSystemFontName:(NSString *)aName
{
	[UIFontBoldSystemFontName release];
	UIFontBoldSystemFontName = [aName copy];
}

+ (UIFont *)_fontWithCTFont:(CTFontRef)aFont
{
	UIFont *theFont = [[UIFont alloc] init];
	theFont->_font = CFRetain(aFont);
	return [theFont autorelease];
}

+ (UIFont *)fontWithNSFont:(NSFont *)aFont
{
	if (aFont) {
		CTFontRef newFont = CTFontCreateWithName((CFStringRef)[aFont fontName], [aFont pointSize], NULL);
		if (newFont) {
			UIFont *theFont = [self _fontWithCTFont:newFont];
			CFRelease(newFont);
			return theFont;
		}
	}
	return nil;
}

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
	return [self fontWithNSFont:[NSFont fontWithName:fontName size:fontSize]];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize
{
	NSFont *systemFont = UIFontSystemFontName? [NSFont fontWithName:UIFontSystemFontName size:fontSize] : [NSFont systemFontOfSize:fontSize];
	return [self fontWithNSFont:systemFont];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize
{
	NSFont *systemFont = UIFontBoldSystemFontName? [NSFont fontWithName:UIFontBoldSystemFontName size:fontSize] : [NSFont boldSystemFontOfSize:fontSize];
	return [self fontWithNSFont:systemFont];
}

- (void)dealloc
{
	CFRelease(_font);
	[super dealloc];
}

- (NSString *)fontName
{
	return [(NSString *)CTFontCopyFullName(_font) autorelease];
}

- (CGFloat)ascender
{
	return CTFontGetAscent(_font);
}

- (CGFloat)descender
{
	return -CTFontGetDescent(_font);
}

- (CGFloat)pointSize
{
	return CTFontGetSize(_font);
}

- (CGFloat)xHeight
{
	return CTFontGetXHeight(_font);
}

- (CGFloat)capHeight
{
	return CTFontGetCapHeight(_font);
}

- (CGFloat)lineHeight
{
	return ceilf(self.ascender - self.descender + CTFontGetLeading(_font));
}

- (NSString *)familyName
{
	return [(NSString *)CTFontCopyFamilyName(_font) autorelease];
}

- (UIFont *)fontWithSize:(CGFloat)fontSize
{
	CTFontRef newFont = CTFontCreateCopyWithAttributes(_font, fontSize, NULL, NULL);
	if (newFont) {
		UIFont *theFont = [isa _fontWithCTFont:newFont];
		CFRelease(newFont);
		return theFont;
	} else {
		return nil;
	}
}

- (NSFont *)NSFont
{
	return [NSFont fontWithName:self.fontName size:self.pointSize];
}

+ (CGFloat)systemFontSize {
  return [NSFont systemFontSize];
}

+ (CGFloat)smallSystemFontSize {
  return [NSFont smallSystemFontSize];
}

+ (CGFloat)labelFontSize {
  return [NSFont labelFontSize];
}


@end
