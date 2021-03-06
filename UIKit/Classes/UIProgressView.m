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

#import "UIProgressView.h"
#import "UIColor.h"
#import "UIGraphics.h"
#import "UIBezierPath.h"

@implementation UIProgressView

- (id)initWithProgressViewStyle:(UIProgressViewStyle)style
{
    if ((self=[super initWithFrame:CGRectMake(0,0,0,0)])) {
        _progressViewStyle = style;
    }
    return self;
}

- (void)setProgressViewStyle:(UIProgressViewStyle)style
{
    if (style != _progressViewStyle) {
        _progressViewStyle = style;
        [self setNeedsDisplay];
    }
}

- (void)setProgress:(float)p
{
    if (p != _progress) {
        _progress = MIN(1,MAX(0,p));
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext() ;
	CGContextSaveGState(context);
    
    CGFloat width = self.bounds.size.width - 4.0;
	CGFloat filledWidth = width * _progress;
	
	CGRect outer = CGRectInset(self.bounds, 1.0, 1.0);
	CGRect inner = CGRectInset(self.bounds, 2.0, 2.0);
	inner.size.width = filledWidth;
	
	UIBezierPath* emptyPath = [UIBezierPath bezierPathWithRoundedRect:outer cornerRadius:4];
	UIBezierPath* fillPath = [UIBezierPath bezierPathWithRoundedRect:inner cornerRadius:4];
	
	emptyPath.lineWidth = 1.0;
	[[UIColor blackColor] set];
	
	[emptyPath stroke];
	[emptyPath fill];
	
	fillPath.lineWidth = 0.0;
	
	[[UIColor whiteColor] setFill];
	[fillPath fill];
    
    CGContextRestoreGState(context);
}

@end
