//
//
//	Powered by BeeFramework
//
//
//  TestDataShowBoard.m
//  Company
//
//  Created by yorke on 14-1-20.
//    Copyright (c) 2014年 yorke. All rights reserved.
//
#import "TestDataShowMode.h"

#pragma mark -

@implementation TestDataShowMode

@synthesize rid = _rid;

@synthesize FItemID=_FItemID;
@synthesize FAirBottleID=_FAirBottleID;
@synthesize FStockID=_FStockID;
@synthesize FStockPID=_FStockPID;
@synthesize FStockPlaceID=_FStockPlaceID;
@synthesize FStockPlacePID=_FStockPlacePID;
@synthesize FContainerID=_FContainerID;
@synthesize FType=_FType;

@synthesize FPCNumber=_FPCNumber;
@synthesize FPCNumberwidth=_FPCNumberwidth;

@synthesize FAirBottleBarcode=_FAirBottleBarcode;
@synthesize FAirBottleBarcodewidth=_FAirBottleBarcodewidth;

@synthesize FMode=_FMode;
@synthesize FModewidth=_FModewidth;

@synthesize FSize=_FSize;
@synthesize FSizewidth=_FSizewidth;

@synthesize FAirBottleNumber=_FAirBottleNumber;
@synthesize FAirBottleNumberwidth=_FAirBottleNumberwidth;

@synthesize FItemNumber=_FItemNumber;
@synthesize FItemNumberwidth=_FItemNumberwidth;

@synthesize FItemModel=_FItemModel;
@synthesize FItemModelwidth=_FItemModelwidth;

@synthesize FItemSize=_FItemSize;
@synthesize FItemSizewidth=_FItemSizewidth;

@synthesize FQty=_FQty;
@synthesize FQtywidth=_FQtywidth;

@synthesize FCBarcode=_FCBarcode;
@synthesize FCBarcodewidth=_FCBarcodewidth;

@synthesize cellwidth=_cellwidth;
@synthesize cellshow=_cellshow;

+ (void)mapRelation
{
	[self mapPropertyAsKey:@"rid"];
    [self mapProperty:@"FItemID" defaultValue:@0];
    [self mapProperty:@"FAirBottleID" defaultValue:@0];
    [self mapProperty:@"FStockID" defaultValue:@0];
    [self mapProperty:@"FStockPID" defaultValue:@0];
    [self mapProperty:@"FStockPlaceID" defaultValue:@0];
    [self mapProperty:@"FStockPlacePID" defaultValue:@0];
    [self mapProperty:@"FContainerID" defaultValue:@0];
    [self mapProperty:@"FType" defaultValue:@""];
    [self mapProperty:@"FPCNumber" defaultValue:@""];
    [self mapProperty:@"FPCNumberwidth" defaultValue:0];
	[self mapProperty:@"FAirBottleBarcode"	defaultValue:@""];
    [self mapProperty:@"FAirBottleBarcodewidth"	defaultValue:0];
    [self mapProperty:@"FMode"	defaultValue:@""];
    [self mapProperty:@"FModewidth"	defaultValue:0];
    [self mapProperty:@"FSize"	defaultValue:@""];
    [self mapProperty:@"FSizewidth"	defaultValue:0];
    [self mapProperty:@"FAirBottleNumber"	defaultValue:@""];
    [self mapProperty:@"FAirBottleNumberwidth"	defaultValue:0];
    [self mapProperty:@"FItemNumber" defaultValue:@""];
    [self mapProperty:@"FItemNumberwidth" defaultValue:0];
    [self mapProperty:@"FItemModel" defaultValue:@""];
    [self mapProperty:@"FItemModelwidth" defaultValue:0];
    [self mapProperty:@"FItemSize" defaultValue:@""];
    [self mapProperty:@"FItemSizewidth" defaultValue:0];
    [self mapProperty:@"FQty" defaultValue:@""];
    [self mapProperty:@"FQtywidth" defaultValue:0];
    [self mapProperty:@"FCBarcode" defaultValue:@""];
    [self mapProperty:@"FCBarcodewidth" defaultValue:0];
    
    [self mapProperty:@"cellwidth"	defaultValue:0];
    [self mapProperty:@"cellshow"	defaultValue:0];
    
    
}

- (void)load
{
	[super load];
}

- (void)unload
{
	self.rid = nil;
	self.FItemID = nil;
	self.FAirBottleID = nil;
    self.FStockID = nil;
    self.FStockPID=nil;
    self.FStockPlaceID=nil;
    self.FStockPlacePID=nil;
    self.FContainerID=nil;
    self.FType=nil;
    
    self.FPCNumber=nil;
    self.FPCNumberwidth=nil;
    
    self.FAirBottleBarcode=nil;
    self.FAirBottleBarcodewidth=nil;
    
    self.FMode=nil;
    self.FModewidth=nil;
    
    self.FSize=nil;
    self.FSizewidth=nil;
    
    self.FAirBottleNumber=nil;
    self.FAirBottleNumberwidth=nil;
    
    self.FItemNumber=nil;
    self.FItemNumberwidth=nil;
    
    self.FItemModel=nil;
    self.FItemModelwidth=nil;
    
    self.FItemSize=nil;
    self.FItemSizewidth=nil;
    
    self.FQty=nil;
    self.FQtywidth=nil;
    
    self.FCBarcode=nil;
    self.FCBarcodewidth=nil;
    
    self.cellwidth=nil;
    self.cellshow=nil;
    
	[super unload];
}

@end