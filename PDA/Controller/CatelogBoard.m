//
//  CatelogBoard.m
//

#import "CatelogBoard.h"
#import "Bee_Debug.h"
#import "Bee_Runtime.h"

#pragma mark -

@implementation CatelogCell

+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return CGSizeMake( bound.width, 60.0f );
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
	_title.frame = CGRectMake( 10.0f, 5.0f, cell.bounds.size.width - 20.0f, 30.0f );
	_intro.frame = CGRectMake( 10.0f, 32.0f, cell.bounds.size.width - 20.0f, 20.0f );
}

- (void)load
{
	[super load];
    
	_title = [[BeeUILabel alloc] init];
	_title.font = [UIFont boldSystemFontOfSize:18.0f];
	_title.textColor = [UIColor blackColor];
	_title.textAlignment = UITextAlignmentLeft;
	[self addSubview:_title];
    
	_intro = [[BeeUILabel alloc] init];
	_intro.font = [UIFont systemFontOfSize:14.0f];
	_intro.textColor = [UIColor grayColor];
	_intro.textAlignment = UITextAlignmentLeft;
	[self addSubview:_intro];
}

- (void)unload
{
	SAFE_RELEASE_SUBVIEW( _title );
	SAFE_RELEASE_SUBVIEW( _intro );
	
	[super unload];
}

- (void)dataWillChange
{
	[super dataWillChange];
}

- (void)dataDidChanged
{
	[super dataDidChanged];
	
	if ( self.cellData )
	{
		[_title setText:[(NSArray *)self.cellData objectAtIndex:1]];
		[_intro setText:[(NSArray *)self.cellData objectAtIndex:2]];
	}
	else
	{
		[_title setText:nil];
		[_intro setText:nil];
	}
}

@end

#pragma mark -

@implementation CatelogBoard

DEF_SINGLETON(CatelogBoard)
- (void)load
{
	[super load];
    
	_lessons = [[NSMutableArray alloc] init];
    //[self.navigationController setNavigationBarHidden:YES];
        [_lessons addObject:[NSArray arrayWithObjects:@"TestDataShowBoard", @"CLMT04", @"客户仓入库", nil]];
	 
}

- (void)unload
{
	[_lessons removeAllObjects];
	[_lessons release];
	
	[super unload];
}

- (void)handleUISignal_BeeUIBoard:(BeeUISignal *)signal
{
	[super handleUISignal:signal];
    
	if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
	{
		[self setTitleString:@"梅塞尔PDA"];
		[self showNavigationBarAnimated:NO];
        //[self.navigationController setNavigationBarHidden:YES];
        
	}
	else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
	{
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize bound = CGSizeMake( self.view.bounds.size.width, 0.0f );
	return [CatelogCell sizeInBound:bound forData:nil].height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_lessons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BeeUITableViewCell * cell = (BeeUITableViewCell *)[self dequeueWithContentClass:[CatelogCell class]];
	if ( cell )
	{
		if ( indexPath.row % 2 )
		{
			[cell.gridCell setBackgroundColor:[UIColor whiteColor]];
		}
		else
		{
			[cell.gridCell setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
		}
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
		cell.cellData = [_lessons objectAtIndex:indexPath.row];
		return cell;
	}
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	NSArray * data = [_lessons objectAtIndex:indexPath.row];
	BeeUIBoard * board = [[(BeeUIBoard *)[BeeRuntime allocByClassName:(NSString *)[data objectAtIndex:0]] init] autorelease];
	if ( board )
	{
        NSLog(@"%f",board.view.frame.size.width);
		[self.stack pushBoard:board animated:NO];
	}
}

@end
