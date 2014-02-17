//
//  CatelogBoard.h
//

#import "Bee.h"
#import "Bee_UITableBoard.h"

#pragma mark -

@interface CatelogCell : BeeUIGridCell
{
	BeeUILabel *		_title;
	BeeUILabel *		_intro;
}
@end

#pragma mark -

@interface CatelogBoard : BeeUITableBoard
{
	NSMutableArray * _lessons;
}
 
AS_SINGLETON(CatelogBoard);
@end
