//
//  UISearchBar.m
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//
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

#import "UISearchBar.h"
#import "UISearchField.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "UIFont.h"

@implementation UISearchBar
@synthesize delegate=_delegate, showsCancelButton = _showsCancelButton, placeholder=_placeholder;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _searchField = [[UISearchField alloc] initWithFrame:frame];
		_searchField.borderStyle = UITextBorderStyleRoundedRect;
		_searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		_searchField.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
        [self addSubview:_searchField];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [_placeholder release];
    [_searchField release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	const CGFloat locations[] = { 0.0f, 1.0f };
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSArray *colors = [NSArray arrayWithObjects:(id) [UIColor colorWithRed:233.0f/255.0f green:236.0f/255.0f blue:239.0f/255.0f alpha:1.0f].CGColor, (id) [UIColor colorWithRed:215.0f/255.0f green:223.0f/255.0f blue:225.0f/255.0f alpha:1.0f].CGColor, nil];
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
	
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, self.bounds.size.height), kCGGradientDrawsBeforeStartLocation);
	
	[[UIColor colorWithRed:178.0f/255.0f green:188.0f/255.0f blue:195.0f/255.0f alpha:1.0f] set];
	CGContextFillRect(context, CGRectMake(0.0f, CGRectGetMaxY(self.bounds) - 1.0f, self.bounds.size.width, 1.0f));
	
	CFRelease(gradient);
	CFRelease(colorSpace);
}

- (NSString *)text
{
    return _searchField.text;
}

- (void)setText:(NSString *)text
{
    _searchField.text = text;
}

- (NSString *)placeholder {
	return _searchField.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder {
	_searchField.placeholder = placeholder;
}

@end
