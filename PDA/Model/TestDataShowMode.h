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

#import "Bee_ActiveRecord.h"

#pragma mark -

@interface TestDataShowMode : BeeActiveRecord

@property (nonatomic, retain) NSNumber *	rid;
@property (nonatomic, retain) NSString *	FItemID;
@property (nonatomic, retain) NSString *    FAirBottleID;
@property (nonatomic, retain) NSString *	FStockID;
@property (nonatomic, retain) NSString *	FStockPID;
@property (nonatomic, retain) NSString *	FStockPlaceID;
@property (nonatomic, retain) NSString *	FStockPlacePID;
@property (nonatomic, retain) NSString *	FContainerID;
@property (nonatomic, retain) NSString *    FType;

@property (nonatomic, retain) NSString *    FPCNumber;
@property (nonatomic, retain) NSNumber *    FPCNumberwidth;

@property (nonatomic, retain) NSString *    FAirBottleBarcode;
@property (nonatomic, retain) NSNumber *    FAirBottleBarcodewidth;

@property (nonatomic, retain) NSString *    FMode;
@property (nonatomic, retain) NSNumber *    FModewidth;

@property (nonatomic, retain) NSString *    FSize;
@property (nonatomic, retain) NSNumber *    FSizewidth;

@property (nonatomic, retain) NSString *    FAirBottleNumber;
@property (nonatomic, retain) NSNumber *    FAirBottleNumberwidth;

@property (nonatomic, retain) NSString *    FItemNumber;
@property (nonatomic, retain) NSNumber *    FItemNumberwidth;

@property (nonatomic, retain) NSString *    FItemModel;
@property (nonatomic, retain) NSNumber *    FItemModelwidth;

@property (nonatomic, retain) NSString *    FItemSize;
@property (nonatomic, retain) NSNumber *    FItemSizewidth;

@property (nonatomic, retain) NSString *    FQty;
@property (nonatomic, retain) NSNumber *    FQtywidth;

@property (nonatomic, retain) NSString *    FCBarcode;
@property (nonatomic, retain) NSNumber *    FCBarcodewidth;



@property (nonatomic, retain) NSNumber *	cellwidth;
@property (nonatomic, retain) NSNumber *	cellshow;

@end

