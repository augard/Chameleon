//  Created by Sean Heber on 6/17/10.
#import "UILabel.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIGraphics.h"

@implementation UILabel
@synthesize text=_text, font=_font, textColor=_textColor, textAlignment=_textAlignment, lineBreakMode=_lineBreakMode, enabled=_enabled;
@synthesize numberOfLines=_numberOfLines, shadowColor=_shadowColor, shadowOffset=_shadowOffset;
@synthesize baselineAdjustment=_baselineAdjustment, adjustsFontSizeToFitWidth=_adjustsFontSizeToFitWidth;
@synthesize highlightedTextColor=_highlightedTextColor, minimumFontSize=_minimumFontSize, highlighted=_highlighted;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
		self.textAlignment = UITextAlignmentLeft;
		self.lineBreakMode = UILineBreakModeTailTruncation;
		self.textColor = [UIColor blackColor];
		self.backgroundColor = [UIColor whiteColor];
		self.enabled = YES;
		self.font = [UIFont systemFontOfSize:17];
		self.numberOfLines = 1;
		self.contentMode = UIViewContentModeLeft;
		self.clipsToBounds = YES;
		self.shadowOffset = CGSizeMake(0,-1);
		self.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    }
    return self;
}

- (void)dealloc
{
	[_text release];
	[_font release];
	[_textColor release];
	[_shadowColor release];
	[_highlightedTextColor release];
    [super dealloc];
}

- (void)setText:(NSString *)newText
{
	if (_text != newText) {
		[_text release];
		_text = [newText copy];
		[self setNeedsDisplay];
	}
}

- (void)setFont:(UIFont *)newFont
{
	assert(newFont != nil);

	if (newFont != _font) {
		[_font release];
		_font = [newFont retain];
		[self setNeedsDisplay];
	}
}

- (void)setTextColor:(UIColor *)newColor
{
	if (newColor != _textColor) {
		[_textColor release];
		_textColor = [newColor retain];
		[self setNeedsDisplay];
	}
}

- (void)setShadowColor:(UIColor *)newColor
{
	if (newColor != _shadowColor) {
		[_shadowColor release];
		_shadowColor = [newColor retain];
		[self setNeedsDisplay];
	}
}

- (void)setShadowOffset:(CGSize)newOffset
{
	if (!CGSizeEqualToSize(newOffset,_shadowOffset)) {
		_shadowOffset = newOffset;
		[self setNeedsDisplay];
	}
}

- (void)setTextAlignment:(UITextAlignment)newAlignment
{
	if (newAlignment != _textAlignment) {
		_textAlignment = newAlignment;
		[self setNeedsDisplay];
	}
}

- (void)setLineBreakMode:(UILineBreakMode)newMode
{
	if (newMode != _lineBreakMode) {
		_lineBreakMode = newMode;
		[self setNeedsDisplay];
	}
}

- (void)setEnabled:(BOOL)newEnabled
{
	if (newEnabled != _enabled) {
		_enabled = newEnabled;
		[self setNeedsDisplay];
	}
}

- (void)setNumberOfLines:(NSInteger)lines
{
	if (lines != _numberOfLines) {
		_numberOfLines = lines;
		[self setNeedsDisplay];
	}
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
	return bounds;
}

- (void)drawTextInRect:(CGRect)rect
{
	[_text drawInRect:rect withFont:_font lineBreakMode:_lineBreakMode alignment:_textAlignment];
}

- (void)drawRect:(CGRect)rect
{
	const CGRect bounds = self.bounds;
	const BOOL hasShadow = !CGSizeEqualToSize(_shadowOffset,CGSizeZero) && _shadowColor;
	
	CGRect drawRect = CGRectZero;
	
	// find out the actual size of the text given the size of our bounds
	CGSize maxSize = self.bounds.size;
	if (_numberOfLines > 0) {
		maxSize.height = _font.leading * _numberOfLines;
	}
	drawRect.size = [_text sizeWithFont:_font constrainedToSize:maxSize lineBreakMode:_lineBreakMode];

	// now vertically center it
	drawRect.origin.y = roundf((bounds.size.height - drawRect.size.height) / 2.f);
	
	// now position it correctly for the width
	// this might be cheating somehow and not how the real thing does it...
	// I didn't spend a ton of time investigating the sizes that it sends the drawTextInRect: method
	drawRect.origin.x = 0;
	drawRect.size.width = bounds.size.width;
	
	// if there's a shadow, let's draw that first
	if (hasShadow) {
		[_shadowColor setFill];
		[self drawTextInRect:CGRectOffset(drawRect,_shadowOffset.width,_shadowOffset.height)];
	}

	// finally, draw the real label
	UIColor *drawColor = (_highlighted && _highlightedTextColor)? _highlightedTextColor : _textColor;
	[drawColor setFill];
	[self drawTextInRect:drawRect];
}

- (void)setFrame:(CGRect)newFrame
{
	const BOOL redisplay = !CGSizeEqualToSize(newFrame.size,self.frame.size);
	[super setFrame:newFrame];
	if (redisplay) {
		[self setNeedsDisplay];
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size = CGSizeMake(((_numberOfLines > 0)? CGFLOAT_MAX : size.width), ((_numberOfLines <= 0)? CGFLOAT_MAX : (_font.leading*_numberOfLines)));
	return [_text sizeWithFont:_font constrainedToSize:size lineBreakMode:_lineBreakMode];
}

- (void)setHighlighted:(BOOL)highlighted
{
	if (highlighted != _highlighted) {
		_highlighted = highlighted;
		[self setNeedsDisplay];
	}
}

@end
