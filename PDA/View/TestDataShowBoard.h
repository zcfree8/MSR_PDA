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
#import "Bee.h"
#import "Bee_UITableBoard.h"
#import "AppDelegate.h"
#import "NetWebServiceRequest.h"
#import "MBProgressHUD.h"
//@interface CellLayout1 : NSObject
//AS_SINGLETON(CellLayout1);
//@end
@interface testCell : BeeUIGridCell{
    BeeUILabel *_lbltestname;
    BeeUILabel *_lbltestsex;
    BeeUILabel *_lbltestage;
    BeeUILabel *_lbltesttel;
    BeeUILabel *_lbltestaddress;
    
}
@end


@interface TestDataShowBoard : BeeUIBoard<UITableViewDelegate,UITableViewDataSource,NetWebServiceRequestDelegate,ZBarReaderDelegate,UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    
    UITableView *_table;
    UIScrollView *_scroll;
    UIView *_headView;
    
    CGFloat cellwidth;
    
    NSMutableArray *serverlist;//获取数据
    NSMutableArray *	_datas;//转换可用数据
    NSMutableArray *_colNameList; //需要显示的数据
    
    UITextField *txtPCDH;//派车单号
    UITextField *txtCK;//仓库
    UITextField *txtCW;//仓位
    UITextField *txtQPTM;//气瓶条码
    
    UILabel *L1;
    UILabel *L2;
    UILabel *L3;
    UILabel *L4;

    AppDelegate *delegate;
    NSString *result;//全局数据
    BOOL blContainer;//是否为集装格操作
    int iDiffDay;//当天离下次检验日期相差天数
    int iFStockID;
    int iFStockPlaceID;
    NSString *sFType;//业务类别
    NSString *sFPlaceManageYN;//仓库是否启用仓位管理
    NSString *sPrgKey;
}

@property(nonatomic,assign)BOOL blContainer;//是否为集装格操作
@property(nonatomic,assign)int iDiffDay;//当天离下次检验日期相差天数
//仓库,仓位是否可编辑
@property(nonatomic,retain)NSString *sFStockYN;
@property(nonatomic,retain)NSString *sFStockPlaceYN;
@property(nonatomic,retain)NSString *sFSaveUpdateYN;//是否保存后更新库存

@property(nonatomic,retain)NSString *index;
@property(nonatomic,retain)NetWebServiceRequest *runningRequest;

@end
