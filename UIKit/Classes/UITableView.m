//  Created by Sean Heber on 6/4/10.
#import "UITableView.h"
#import "UITableViewCell+UIPrivate.h"
#import "UIColor.h"
#import "UITouch.h"
#import "UITableViewSection.h"
#import "UITableViewSectionLabel.h"

const CGFloat _UITableViewDefaultRowHeight = 43;

@interface UITableView ()
- (void)_setNeedsReload;
@end

@implementation UITableView
@synthesize style=_style, dataSource=_dataSource, rowHeight=_rowHeight, separatorStyle=_separatorStyle, separatorColor=_separatorColor;
@synthesize tableHeaderView=_tableHeaderView, tableFooterView=_tableFooterView, allowsSelection=_allowsSelection, editing=_editing;
@synthesize sectionFooterHeight=_sectionFooterHeight, sectionHeaderHeight=_sectionHeaderHeight;
@synthesize allowsSelectionDuringEditing=_allowsSelectionDuringEditing;
@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle
{
	if ((self=[super initWithFrame:frame])) {
		_style = theStyle;
		_cachedCells = [[NSMutableDictionary alloc] init];
		_sections = [[NSMutableArray alloc] init];
		_reusableCells = [[NSMutableSet alloc] init];

		self.separatorColor = [UIColor colorWithRed:.88f green:.88f blue:.88f alpha:1];
		self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.showsHorizontalScrollIndicator = NO;
		self.allowsSelection = YES;
		self.allowsSelectionDuringEditing = NO;
		self.sectionHeaderHeight = self.sectionFooterHeight = 22;

		if (_style == UITableViewStylePlain) {
			self.backgroundColor = [UIColor whiteColor];
		}
		
		[self _setNeedsReload];
	}
	return self;
}

- (void)dealloc
{
	[_selectedRow release];
	[_tableFooterView release];
	[_tableHeaderView release];
	[_cachedCells release];
	[_sections release];
	[_reusableCells release];
	[super dealloc];
}

- (void)setDataSource:(id<UITableViewDataSource>)newSource
{
	_dataSource = newSource;

	_dataSourceHas.numberOfSectionsInTableView = [_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)];
	_dataSourceHas.titleForHeaderInSection = [_dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)];
	_dataSourceHas.titleForFooterInSection = [_dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)];
	
	[self _setNeedsReload];
}

- (void)setDelegate:(id<UITableViewDelegate>)newDelegate
{
	[super setDelegate:newDelegate];

	_delegateHas.heightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
	_delegateHas.heightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
	_delegateHas.heightForFooterInSection = [_delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
	_delegateHas.viewForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
	_delegateHas.viewForFooterInSection = [_delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)];
	_delegateHas.willSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)];
	_delegateHas.didSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
	_delegateHas.willDeselectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)];
	_delegateHas.didDeselectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)];
}

- (void)setRowHeight:(CGFloat)newHeight
{
	_rowHeight = newHeight;
	[self setNeedsLayout];
}




- (void)_updateSectionsCache
{
	// use dataSource to rebuild the cache.
	// if no dataSource, this can't really proceed beyond clearing the old
	// cache. setting the dataSource and/or delegate likely needs to clear
	// this cache but not actually update the info immediately (do it lazily).
	
	[_sections removeAllObjects];
	
	if (_dataSource) {
		// compute the heights/offsets of everything
		const CGFloat defaultRowHeight = _rowHeight ?: _UITableViewDefaultRowHeight;
		const NSInteger numberOfSections = [self numberOfSections];
		for (NSInteger section=0; section<numberOfSections; section++) {
			const NSInteger numberOfRowsInSection = [self numberOfRowsInSection:section];
			
			UITableViewSection *sectionRecord = [[UITableViewSection alloc] init];
			sectionRecord.numberOfRows = numberOfRowsInSection;
			sectionRecord.headerView = _delegateHas.viewForHeaderInSection? [self.delegate tableView:self viewForHeaderInSection:section] : nil;
			sectionRecord.footerView = _delegateHas.viewForFooterInSection? [self.delegate tableView:self viewForFooterInSection:section] : nil;
			sectionRecord.headerTitle = _dataSourceHas.titleForHeaderInSection? [self.dataSource tableView:self titleForHeaderInSection:section] : nil;
			sectionRecord.footerTitle = _dataSourceHas.titleForFooterInSection? [self.dataSource tableView:self titleForFooterInSection:section] : nil;
			
			// make a default section header view if there's a title for it and no overriding view
			if (!sectionRecord.headerView && sectionRecord.headerTitle) {
				sectionRecord.headerView = [UITableViewSectionLabel sectionLabelWithTitle:sectionRecord.headerTitle];
			}
			
			// make a default section footer view if there's a title for it and no overriding view
			if (!sectionRecord.footerView && sectionRecord.footerTitle) {
				sectionRecord.footerView = [UITableViewSectionLabel sectionLabelWithTitle:sectionRecord.footerTitle];
			}
			
			// if there's a view, then we need to set the height, otherwise it's going to be zero
			if (sectionRecord.headerView) {
				[self addSubview:sectionRecord.headerView];
				sectionRecord.headerHeight = _delegateHas.heightForHeaderInSection? [self.delegate tableView:self heightForHeaderInSection:section] : _sectionHeaderHeight;
			} else {
				sectionRecord.headerHeight = 0;
			}
			
			if (sectionRecord.footerView) {
				[self addSubview:sectionRecord.footerView];
				sectionRecord.footerHeight = _delegateHas.heightForFooterInSection? [self.delegate tableView:self heightForFooterInSection:section] : _sectionFooterHeight;
			} else {
				sectionRecord.footerHeight = 0;
			}
			
			NSMutableArray *rowHeights = [[NSMutableArray alloc] initWithCapacity:numberOfRowsInSection];
			CGFloat totalRowsHeight = 0;
			
			for (NSInteger row=0; row<numberOfRowsInSection; row++) {
				const CGFloat rowHeight = _delegateHas.heightForRowAtIndexPath? [self.delegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]] : defaultRowHeight;
				[rowHeights addObject:[NSNumber numberWithFloat:rowHeight]];
				totalRowsHeight += rowHeight;
			}
			
			sectionRecord.rowsHeight = totalRowsHeight;
			sectionRecord.rowHeights = rowHeights;
			
			[_sections addObject:sectionRecord];
			[sectionRecord release];
			[rowHeights release];
		}
	}
}

- (void)_updateSectionsCacheIfNeeded
{
	// if there's a cache already in place, this doesn't do anything,
	// otherwise calls _updateSectionsCache.
	// this is called from _setContentSize and probably other places that
	// require access to anything that might be in the section caches (any sizing
	// information, etc)
	
	if ([_sections count] == 0) {
		[self _updateSectionsCache];
	}
}

- (void)_setContentSize
{
	// first calls _updateSectionsCacheIfNeeded, then sets the scroll view's size
	// taking into account the size of the header, footer, and all rows.
	// should be called by reloadData, setFrame, header/footer setters.
	
	[self _updateSectionsCacheIfNeeded];
	
	CGFloat height = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
	
	for (UITableViewSection *section in _sections) {
		height += [section sectionHeight];
	}
	
	if (_tableFooterView) {
		height += _tableFooterView.frame.size.height;
	}
	
	self.contentSize = CGSizeMake(0,height);	
}

- (void)_layoutTableViewIfNeeded
{
	// only works if a sectionsCache exists, if not this does nothing.
	// lays out headers and rows that are visible at the time. this should also do cell
	// dequeuing and keep a list of all existing cells that are visible and those
	// that exist but are not visible and are reusable
	
	const CGSize boundsSize = self.bounds.size;
	const CGFloat contentOffset = self.contentOffset.y;
	const CGRect visibleBounds = CGRectMake(0,contentOffset,boundsSize.width,boundsSize.height);
	CGFloat tableHeight = 0;
	
	if (_tableHeaderView) {
		CGRect tableHeaderFrame = _tableHeaderView.frame;
		tableHeaderFrame.origin = CGPointZero;
		tableHeaderFrame.size.width = boundsSize.width;
		_tableHeaderView.frame = tableHeaderFrame;
		_tableHeaderView.hidden = !CGRectIntersectsRect(tableHeaderFrame, visibleBounds);
		tableHeight += tableHeaderFrame.size.height;
	}
	
	// layout sections and rows
	NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
	const NSInteger numberOfSections = [_sections count];
	[_cachedCells removeAllObjects];
	
	for (NSInteger section=0; section<numberOfSections; section++) {
		NSAutoreleasePool *sectionPool = [[NSAutoreleasePool alloc] init];
		CGRect sectionRect = [self rectForSection:section];
		tableHeight += sectionRect.size.height;
		if (CGRectIntersectsRect(sectionRect, visibleBounds)) {
			const CGRect headerRect = [self rectForHeaderInSection:section];
			const CGRect footerRect = [self rectForFooterInSection:section];
			UITableViewSection *sectionRecord = [_sections objectAtIndex:section];
			const NSInteger numberOfRows = sectionRecord.numberOfRows;
			
			if (sectionRecord.headerView) {
				if (CGRectIntersectsRect(headerRect,visibleBounds)) {
					sectionRecord.headerView.frame = headerRect;
					sectionRecord.headerView.hidden = NO;
				} else {
					sectionRecord.headerView.hidden = YES;
				}
			}
			
			if (sectionRecord.footerView) {
				if (CGRectIntersectsRect(footerRect,visibleBounds)) {
					sectionRecord.footerView.frame = footerRect;
					sectionRecord.footerView.hidden = NO;
				} else {
					sectionRecord.footerView.hidden = YES;
				}
			}
			
			for (NSInteger row=0; row<numberOfRows; row++) {
				NSAutoreleasePool *rowPool = [[NSAutoreleasePool alloc] init];
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
				CGRect rowRect = [self rectForRowAtIndexPath:indexPath];
				if (CGRectIntersectsRect(rowRect,visibleBounds) && rowRect.size.height > 0) {
					UITableViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
					if (cell) {
						[_cachedCells setObject:cell forKey:indexPath];
						[availableCells removeObjectForKey:indexPath];
						cell.selected = [_selectedRow isEqual:indexPath];
						cell.frame = rowRect;
						cell.backgroundColor = self.backgroundColor;
						[cell _setSeparatorStyle:_separatorStyle color:_separatorColor];
						[self addSubview:cell];
					}
				}
				[rowPool release];
			}
		}
		[sectionPool release];
	}
	
	// remove old cells, but save off any that might be reusable
	for (UITableViewCell *cell in [availableCells allValues]) {
		if (cell.reuseIdentifier) {
			[_reusableCells addObject:cell];
		} else {
			[cell removeFromSuperview];
		}
	}
	
	// non-reusable cells should end up dealloced after at this point, but reusable ones live on in _reusableCells.
	[availableCells release];
	
	// now make sure that all available (but unused) reusable cells aren't on screen in the visible area.
	// this is done becaue when resizing a table view by shrinking it's height in an animation, it looks better. The reason is that
	// when an animation happens, it sets the frame to the new (shorter) size and thus recalcuates which cells should be visible.
	// If it removed all non-visible cells, then the cells on the bottom of the table view would disappear immediately but before
	// the frame of the table view has actually animated down to the new, shorter size. So the animation is jumpy/ugly because
	// the cells suddenly disappear instead of seemingly animating down and out of view like they should. This tries to leave them
	// on screen as often as possible, but only if they don't get in the way.
	for (UITableViewCell *cell in _reusableCells) {
		if (CGRectIntersectsRect(cell.frame,visibleBounds)) {
			[cell removeFromSuperview];
		}
	}
	
	if (_tableFooterView) {
		CGRect tableFooterFrame = _tableFooterView.frame;
		tableFooterFrame.origin = CGPointMake(0,tableHeight);
		tableFooterFrame.size.width = boundsSize.width;
		_tableFooterView.frame = tableFooterFrame;
		_tableFooterView.hidden = !CGRectIntersectsRect(tableFooterFrame, visibleBounds);
	}
}




- (CGRect)_CGRectFromVerticalOffset:(CGFloat)offset height:(CGFloat)height
{
	return CGRectMake(0,offset,self.bounds.size.width,height);
}

- (CGFloat)_offsetForSection:(NSInteger)index
{
	CGFloat offset = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
	
	for (NSInteger s=0; s<index; s++) {
		offset += [[_sections objectAtIndex:s] sectionHeight];
	}
	
	return offset;
}

- (CGRect)rectForSection:(NSInteger)section
{
	[self _updateSectionsCacheIfNeeded];
	return [self _CGRectFromVerticalOffset:[self _offsetForSection:section] height:[[_sections objectAtIndex:section] sectionHeight]];
}

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
	[self _updateSectionsCacheIfNeeded];
	return [self _CGRectFromVerticalOffset:[self _offsetForSection:section] height:[[_sections objectAtIndex:section] headerHeight]];
}

- (CGRect)rectForFooterInSection:(NSInteger)section
{
	[self _updateSectionsCacheIfNeeded];
	UITableViewSection *sectionRecord = [_sections objectAtIndex:section];
	CGFloat offset = [self _offsetForSection:section];
	offset += sectionRecord.headerHeight;
	offset += sectionRecord.rowsHeight;
	return [self _CGRectFromVerticalOffset:offset height:sectionRecord.footerHeight];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self _updateSectionsCacheIfNeeded];

	if (indexPath && indexPath.row >= 0 && indexPath.section < [_sections count]) {
		UITableViewSection *sectionRecord = [_sections objectAtIndex:indexPath.section];
		
		if (indexPath.row < sectionRecord.numberOfRows) {
			CGFloat offset = [self _offsetForSection:indexPath.section];
			offset += sectionRecord.headerHeight;
			
			for (NSInteger row=0; row<indexPath.row; row++) {
				offset += [[sectionRecord.rowHeights objectAtIndex:row] floatValue];
			}
			
			return [self _CGRectFromVerticalOffset:offset height:[[sectionRecord.rowHeights objectAtIndex:indexPath.row] floatValue]];
		}
	}
	
	return CGRectZero;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// this is allowed to return nil if the cell isn't visible and is not restricted to only returning visible cells
	// so this simple call should be good enough.
	return [_cachedCells objectForKey:indexPath];
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect
{
	// This needs to return the index paths even if the cells don't exist in any caches or are not on screen
	// For now I'm assuming the cells stretch all the way across the view. It's not clear to me if the real
	// implementation gets anal about this or not (haven't tested it).

	[self _updateSectionsCacheIfNeeded];

	NSMutableArray *results = [[NSMutableArray alloc] init];
	const NSInteger numberOfSections = [_sections count];
	CGFloat offset = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
	
	for (NSInteger section=0; section<numberOfSections; section++) {
		UITableViewSection *sectionRecord = [_sections objectAtIndex:section];
		const NSInteger numberOfRows = sectionRecord.numberOfRows;
		
		offset += sectionRecord.headerHeight;

		if (offset + sectionRecord.rowsHeight >= rect.origin.y) {
			for (NSInteger row=0; row<numberOfRows; row++) {
				const CGFloat height = [[sectionRecord.rowHeights objectAtIndex:row] floatValue];
				CGRect simpleRowRect = CGRectMake(rect.origin.x, offset, rect.size.width, height);
				
				if (CGRectIntersectsRect(rect,simpleRowRect)) {
					[results addObject:[NSIndexPath indexPathForRow:row inSection:section]];
				} else if (simpleRowRect.origin.y > rect.origin.y+rect.size.height) {
					break;	// don't need to find anything else.. we are past the end
				}
				
				offset += height;
			}
		} else {
			offset += sectionRecord.rowsHeight;
		}
		
		offset += sectionRecord.footerHeight;
	}
	
	return [results autorelease];
}

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point
{
	NSArray *paths = [self indexPathsForRowsInRect:CGRectMake(point.x,point.y,1,1)];
	return ([paths count] > 0)? [paths objectAtIndex:0] : nil;
}

- (NSArray *)indexPathsForVisibleRows
{
	[self _layoutTableViewIfNeeded];

	NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:[_cachedCells count]];
	const CGRect bounds = self.bounds;

	for (NSIndexPath *indexPath in [_cachedCells allKeys]) {
		if (CGRectIntersectsRect(bounds,[self rectForRowAtIndexPath:indexPath])) {
			[indexes addObject:indexPath];
		}
	}
	
	return indexes;
}

- (NSArray *)visibleCells
{
	NSMutableArray *cells = [[[NSMutableArray alloc] init] autorelease];
	for (NSIndexPath *index in [self indexPathsForVisibleRows]) {
		UITableViewCell *cell = [self cellForRowAtIndexPath:index];
		if (cell) {
			[cells addObject:cell];
		}
	}
	return cells;
}

- (void)setTableHeaderView:(UIView *)newHeader
{
	if (newHeader != _tableHeaderView) {
		[_tableHeaderView removeFromSuperview];
		[_tableHeaderView release];
		_tableHeaderView = [newHeader retain];
		[self _setContentSize];
		[self addSubview:_tableHeaderView];
	}
}

- (void)setTableFooterView:(UIView *)newFooter
{
	if (newFooter != _tableFooterView) {
		[_tableFooterView removeFromSuperview];
		[_tableFooterView release];
		_tableFooterView = [newFooter retain];
		[self _setContentSize];
		[self addSubview:_tableFooterView];
	}
}

- (NSInteger)numberOfSections
{
	if (_dataSourceHas.numberOfSectionsInTableView) {
		return [self.dataSource numberOfSectionsInTableView:self];
	} else {
		return 1;
	}
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	return [self.dataSource tableView:self numberOfRowsInSection:section];
}

- (void)reloadData
{
	// clear the caches and remove the cells since everything is going to change
	[[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_reusableCells removeAllObjects];
	[_cachedCells removeAllObjects];

	// clear prior selection
	[_selectedRow release];
	_selectedRow = nil;
	
	[self _updateSectionsCache];
	[self _setContentSize];
	
	_needsReload = NO;
}

- (void)_reloadDataIfNeeded
{
	if (_needsReload) {
		[self reloadData];
	}
}

- (void)_setNeedsReload
{
	_needsReload = YES;
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[self _reloadDataIfNeeded];
	[self _layoutTableViewIfNeeded];
	[super layoutSubviews];
}

- (void)setFrame:(CGRect)frame
{
	CGRect oldFrame = self.frame;

	[super setFrame:frame];
	
	if (!CGRectEqualToRect(oldFrame,frame)) {
		if (oldFrame.size.width != frame.size.width) {
			[self _updateSectionsCache];
		}
		[self _setContentSize];
	}
}

- (NSIndexPath *)indexPathForSelectedRow
{
	return [[_selectedRow retain] autorelease];
}

- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell
{
	for (NSIndexPath *index in [_cachedCells allKeys]) {
		if ([_cachedCells objectForKey:index] == cell) {
			return [[index retain] autorelease];
		}
	}
	
	return nil;
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	if (indexPath && [indexPath isEqual:_selectedRow]) {
		[self cellForRowAtIndexPath:_selectedRow].selected = NO;
		[_selectedRow release];
		_selectedRow = nil;
	}
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
	// unlike the other methods that I've tested, the real UIKit appears to call reload on select if the table hasn't been reloaded yet
	// other methods all appear to rebuild their internal cache "on-demand" which is what I've done here so that my table has a very
	// similar delegate and dataSource access pattern to the real thing.
	[self _reloadDataIfNeeded];
	
	if (![_selectedRow isEqual:indexPath]) {
		[self deselectRowAtIndexPath:_selectedRow animated:animated];
		[_selectedRow release];
		_selectedRow = [indexPath retain];
		[self cellForRowAtIndexPath:_selectedRow].selected = YES;
	}
	
	// I did not verify if the real UIKit will still scroll the selection into view even if the selection itself doesn't change.
	// However, this behavior was useful on Ostrich and seems harmless enough.
	[self scrollToRowAtIndexPath:_selectedRow atScrollPosition:scrollPosition animated:animated];
}

- (void)_scrollRectToVisible:(CGRect)aRect atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
	// adjust the rect based on the scroll position mode
	switch (scrollPosition) {
		case UITableViewScrollPositionTop:
			aRect.size.height = self.bounds.size.height;
			break;

		case UITableViewScrollPositionMiddle:
			aRect.origin.y -= (self.bounds.size.height / 2.f) - aRect.size.height;
			aRect.size.height = self.bounds.size.height;
			break;

		case UITableViewScrollPositionBottom:
			aRect.origin.y -= self.bounds.size.height - aRect.size.height;
			aRect.size.height = self.bounds.size.height;
			break;
	}
	
	[self scrollRectToVisible:aRect animated:animated];
}

- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
	[self _scrollRectToVisible:[self rectForRowAtIndexPath:[self indexPathForSelectedRow]] atScrollPosition:scrollPosition animated:animated];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
	[self _scrollRectToVisible:[self rectForRowAtIndexPath:indexPath] atScrollPosition:scrollPosition animated:animated];
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
	for (UITableViewCell *cell in _reusableCells) {
		if ([cell.reuseIdentifier isEqualToString:identifier]) {
			[cell retain];
			[_reusableCells removeObject:cell];
			[cell prepareForReuse];
			return [cell autorelease];
		}
	}
	
	return nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	_editing = editing;
}

- (void)setEditing:(BOOL)editing
{
	[self setEditing:editing animated:NO];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	NSIndexPath *touchedRow = [self indexPathForRowAtPoint:location];

	if (touchedRow) {
		NSIndexPath *selectedRow = [self indexPathForSelectedRow];

		if (selectedRow) {
			NSIndexPath *rowToDeselect = selectedRow;
			
			if (_delegateHas.willDeselectRowAtIndexPath) {
				rowToDeselect = [_delegate tableView:self willDeselectRowAtIndexPath:rowToDeselect];
			}
			
			[self deselectRowAtIndexPath:rowToDeselect animated:NO];
			
			if (_delegateHas.didDeselectRowAtIndexPath) {
				[_delegate tableView:self didDeselectRowAtIndexPath:rowToDeselect];
			}
		}

		NSIndexPath *rowToSelect = touchedRow;
		
		if (_delegateHas.willSelectRowAtIndexPath) {
			rowToSelect = [_delegate tableView:self willSelectRowAtIndexPath:rowToSelect];
		}

		[self selectRowAtIndexPath:rowToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
		
		if (_delegateHas.didSelectRowAtIndexPath) {
			[_delegate tableView:self didSelectRowAtIndexPath:rowToSelect];
		}
	}
}

@end
