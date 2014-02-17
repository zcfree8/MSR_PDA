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
#import "TestDataShowBoard.h"
#import "TestDataShowMode.h"
#import "Bee_Runtime.h"

#define MethodNameOpenDataTable @"OpenDataTable2"
#define MethodNameOpenDataTableParams @"OpenDataTableParams2"
#define MethodNameUIManage @"UIManage2"
#define MethodNameFlowVerif @"FlowVerif2"
#define MethodNameInsertStore @"InsertStore2"

@implementation TestDataShowBoard

@synthesize iDiffDay=_iDiffDay;
@synthesize blContainer=_blContainer;

/*
 1.扫描
 --2.光标
 //3.验证类
 //4.系统的三个按钮
 5.开窗
 --6.MBProgressHUD
 //7.checkPCDone
 //8.算当天离下次检验日期相差天数
 */

#pragma mark Init Methods

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    delegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
}

- (void)load{
	[super load];
    
    //申请新容器
	_datas = [[NSMutableArray alloc] init];
    
    //设置需要显示的列名、显示的列
    if (!_colNameList) {
        _colNameList=[[NSMutableArray alloc] init];
        [_colNameList addObject:@{@"FPCNumber":@"派车单号"}];
        [_colNameList addObject:@{@"FAirBottleBarcode":@"气瓶条码"}];
        [_colNameList addObject:@{@"FMode":@"气瓶品种"}];
        [_colNameList addObject:@{@"FSize":@"气瓶型号"}];
        [_colNameList addObject:@{@"FAirBottleNumber": @"气瓶钢号"}];
        [_colNameList addObject:@{@"FItemNumber": @"物料代码"}];
        [_colNameList addObject:@{@"FItemModel": @"物料名称"}];
        [_colNameList addObject:@{@"FItemSize": @"物料规格"}];
        [_colNameList addObject:@{@"FQty": @"数量"}];
        [_colNameList addObject:@{@"FCBarcode": @"集装格条码"}];
    }
    
    serverlist=[[NSMutableArray alloc] init];
    
   
        [serverlist addObject:@{@"FPCNumber":@"---------------",@"FAirBottleBarcode":@"------------------",@"FMode":@"----------------",@"FSize":@"---------------",@"FAirBottleNumber":@"--------------------",@"FItemNumber":@"-------------------",@"FItemModel":@"---------------",@"FItemSize":@"-----------------",@"FQty":@"------------------",@"FCBarcode":@"-----------------------",@"FItemID_hide":@"0",@"FAirBottleID_hide":@"0",@"FStockID_hide":@"0",@"FStockPID_hide":@"0",@"FStockPlaceID_hide":@"0",@"FStockPlacePID_hide":@"0",@"FContainerID_hide":@"0",@"FType_hide":@"0"}];
    
    //NSLog(@"%@",serverlist);
//    for (int i=0;i<serverlist.count ;i++) {
//        
//        //“_hide”后缀不需要创建列宽字段  如：testid_hide  新建字段为：testid
//        //其他字段需建立列宽 如：testname 新建字段为：testname   testnamewidth
//        //请参照TestDataShowMode.h
//        [serverlist addObject:
//         @{@"FItemID_hide":@"1"
//         ,@"FNumber":@""
//         ,@"FStock":@"",@"FStockPlace":@"",@"FBarcode":@""}];
//        //NSLog(@"%d",serverlist.count);
//    
//    }
    
    [self addDataBase];
}

-(void)addDataBase{
    //解析宽度
    NSEnumerator *enumerator = [serverlist reverseObjectEnumerator];
    //NSLog(@"%@",serverlist);
    id object;
    CGSize labelStrSize;  //单列数据的宽高
    float allWidth = 0.0;//总宽度
    NSString *tempname;
    NSString *tempval;
    unsigned int showcount=0;
    if ( [BeeDatabase openSharedDatabase:@"BarCode.db"] )
	{
		TestDataShowMode.DB.EMPTY();
    }
    while (object = [enumerator nextObject]) {
        allWidth = 0.0;
        showcount=0;
        BeeDatabase *data=TestDataShowMode.DB;
        for(id key in object)
        {
            //NSLog(@"%@",key);
            tempname= [key stringByReplacingOccurrencesOfString:@"_hide" withString:@""] ;//列名
            tempval=[NSString stringWithFormat:@"%@", [object objectForKey:key] ] ;//内容
            
            //默认设置最大宽度300  高度80
            labelStrSize= [ tempval sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(500, _table.rowHeight) lineBreakMode:UILineBreakModeWordWrap];
            
            
            
            data.SET( tempname, [tempval copy] );//添加数据
            
            NSRange  nr=[key rangeOfString:@"hide"];//服务器端控制列：判断是否带后缀_hide  存在则计入列宽
            
            if (nr.location==NSNotFound) {
                
                if (labelStrSize.width<=60) {//设置最小宽度
                    labelStrSize.width=60;
                }
                allWidth+=labelStrSize.width;
                
                NSString *temp=[NSString stringWithFormat:
                                @"%@width",tempname];
                
                data.SET( temp, __INT(labelStrSize.width) );//添加单列的宽度
                
                ++showcount;
            }
            
        }
        //  NSLog(@"%d",showcount);
        data
        .SET(@"cellwidth",[NSString stringWithFormat:@"%f",allWidth])
        .SET(@"cellshow",[NSString stringWithFormat:@"%d",showcount])
        .INSERT();
        
    }
    
    //设置view的宽度
    CGRect viewRect=self.view.frame;
    
    viewRect.size.width= [self currentviewWidth];
    
    
    
    [self updateColumnWidth];
    [self currentviewWidth];
    [self createTableHeaderName];
    
    
    TestDataShowMode.DB.ORDER_DESC_BY(@"rid").GET();
    
    if ( TestDataShowMode.DB.succeed )
    {
        //NSLog(@"%@",TestDataShowMode.DB.resultArray);
        [_datas removeAllObjects];
        [_datas addObjectsFromArray:TestDataShowMode.DB.resultArray];
        
    }
    
    //把每列最大宽度取出来设置
//    if ( 0 == _datas.count )
//    {
//        TestDataShowMode.DB.ORDER_DESC_BY(@"rid").GET();
//        
//        if ( TestDataShowMode.DB.succeed )
//        {
//            NSLog(@"%@",TestDataShowMode.DB.resultArray);
//            [_datas addObjectsFromArray:TestDataShowMode.DB.resultArray];
//            
//        }
//        //     NSLog(@"%@",_datas);
//        //  [self asyncReloadData];
//    }

}

//设置view的width
-(CGFloat)currentviewWidth{
    //    NSDictionary *dicNameHeight=    TestDataShowMode.DB.SELECT_MAX_ALIAS( @"testcellwidth",@"testcellwidth" ).firstRecord;
    //    NSString *testcellwidth=[NSString stringWithFormat:@"%@",[dicNameHeight valueForKey:@"testcellwidth"] ];
    //    CGFloat result=[testcellwidth floatValue];
    //    cellwidth=result;
    //    return result;
    CGFloat resul= [self updateColumnWidth];
    cellwidth=resul;
    return resul;
}

//更新table每列最大的宽度
-(int)updateColumnWidth{
    
    NSString *colname=@"";
    NSString *colWidthName=@"";
    int addwidth=0;  //cellwidth  最大宽度
    for(int i = 0; i < [_colNameList count]; i++) {
        
        NSDictionary *namek_v=[_colNameList objectAtIndex:i];
        
        id keys = [namek_v allKeys];
        colname = [keys objectAtIndex: 0];  //表列名
        colWidthName=[NSString stringWithFormat:@"%@width",colname];
        
        NSString *colwidth= [self selectColMaxWidthByName:colWidthName];
        
        TestDataShowMode.DB.SET(colWidthName,colwidth).UPDATE();
        addwidth+=[colwidth intValue];
    }
    return addwidth;
}

//得到列宽
-(NSString*)selectColMaxWidthByName:(NSString *)colName{
    NSString *resul=@"0";
    NSDictionary *tempDic= TestDataShowMode.DB.
    SELECT_MAX_ALIAS(colName,colName).firstRecord;
    
    NSString *tempWidth=[NSString stringWithFormat:@"%@",[tempDic valueForKey:colName]];
    if (tempWidth) {
        resul=tempWidth;
    }
    return resul;
}

- (void)unload{
	[_datas removeAllObjects];
	[_datas release];
    
    [_colNameList removeAllObjects];
    [_colNameList release];
    
    [serverlist removeAllObjects];
    [serverlist release];
    
    [L1 release];
    [L2 release];
    [L3 release];
    [L4 release];
	[super unload];
}

- (void)handleUISignal_BeeUIBoard:(BeeUISignal *)signal{
	[super handleUISignal:signal];
    //[self.navigationController setNavigationBarHidden:NO];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
    backItem.title=@"";
    self.navigationItem.leftBarButtonItem=backItem;
    [backItem release];
    
    UIBarButtonItem *scanItem=[[UIBarButtonItem alloc]init];
    scanItem.title=@"扫描   ";
    [scanItem setAction:@selector(Scan)];
    self.navigationItem.rightBarButtonItem=scanItem;
    [scanItem release];
    
    
	if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
	{
		[self setTitleString:@"客户仓入库"];
		[self showNavigationBarAnimated:NO];
        //NSLog(@"%f",CGRectGetWidth(self.view.frame));
        
        _scroll = [[UIScrollView alloc]init];
        _table=[[UITableView alloc] init];
        
        
        //_table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.delegate = self;
        _table.dataSource = self;
        //_table.rowHeight = 40;
        
        _table.showsVerticalScrollIndicator = YES;
        _table.showsHorizontalScrollIndicator = NO;
        _table.bounces = YES;
        _table.separatorColor =[UIColor grayColor];
        [_scroll addSubview:_table];
        
        [self.view addSubview:_scroll];
        
        _headView=[[UIView alloc] init];
        _headView.backgroundColor=[UIColor redColor];
        
        [_scroll addSubview:_headView];
        
        /*边框*/
        CALayer *layer = [_table layer];
        layer.borderColor = [[UIColor grayColor] CGColor];
        layer.borderWidth = 1;
        
        /* title阴影*/
        _headView.layer.shadowColor = [UIColor grayColor].CGColor;
        _headView.layer.shadowOpacity = 1.0;
        _headView.layer.shadowRadius = 5.0;
        _headView.layer.shadowOffset = CGSizeMake(0,5);
        
        [self setOtherView];
        
    }
	else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
	{
        SAFE_RELEASE_SUBVIEW(_scroll);
        SAFE_RELEASE_SUBVIEW(_table);
        SAFE_RELEASE_SUBVIEW(_headView);
	}
	else if ( [signal is:BeeUIBoard.LAYOUT_VIEWS] )
	{
        CGRect tableFrame=self.view.frame;
        //CGRect scrollFrame=self.view.frame;
        
        
        tableFrame.size.width=cellwidth;
        //tableFrame.size.height=self.viewSize.height-40;
        tableFrame.origin.y=0;
        
        _scroll.frame=CGRectMake(1, 135, 320, 360);
        
        _table.frame=tableFrame;
        _scroll.contentSize=CGSizeMake(cellwidth, 0);
        
        _headView.frame=CGRectMake(0, 0, cellwidth, 40);
        
        
	}
    
    
    
}

-(void)setOtherView{
    
    UILabel *la1=[[UILabel alloc]initWithFrame:CGRectMake(5, 80, 78, 21)];
    la1.text=@"派车单号:";
    [self.view addSubview:la1];
    [la1 release];
    
    txtPCDH=[[UITextField alloc]initWithFrame:CGRectMake(85, 76, 150, 30)];
    txtPCDH.borderStyle=UITextBorderStyleLine;
    txtPCDH.delegate=self;
    [self.view addSubview:txtPCDH];
    [txtPCDH addTarget:self action:@selector(txtPCD_KeyUp) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    
    L1=[[UILabel alloc]initWithFrame:CGRectMake(235, 76, 30, 30)];
    L1.textAlignment=NSTextAlignmentCenter;
    L1.text=@"-";
    [self.view addSubview:L1];
    
    
    UILabel *la2=[[UILabel alloc]initWithFrame:CGRectMake(5, 118, 78, 21)];
    la2.text=@"仓库仓位:";
    [self.view addSubview:la2];
    [la2 release];
    
    txtCK=[[UITextField alloc]initWithFrame:CGRectMake(85, 114, 45, 30)];
    txtCK.borderStyle=UITextBorderStyleLine;
    txtCK.delegate=self;
    [self.view addSubview:txtCK];
    [txtCK addTarget:self action:@selector(txtCK_KeyUp) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    L2=[[UILabel alloc]initWithFrame:CGRectMake(130, 113, 30, 30)];
    L2.textAlignment=NSTextAlignmentCenter;
    L2.text=@"-";
    [self.view addSubview:L2];
    
    txtCW=[[UITextField alloc]initWithFrame:CGRectMake(160, 114, 75, 30)];
    txtCW.borderStyle=UITextBorderStyleLine;
    txtCW.delegate=self;
    [self.view addSubview:txtCW];
    [txtCW addTarget:self action:@selector(txtCW_KeyUp) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    L3=[[UILabel alloc]initWithFrame:CGRectMake(235, 113, 30, 30)];
    L3.textAlignment=NSTextAlignmentCenter;
    L3.text=@"-";
    [self.view addSubview:L3];
    
    UILabel *la3=[[UILabel alloc]initWithFrame:CGRectMake(5, 155, 78, 21)];
    la3.text=@"气瓶条码:";
    [self.view addSubview:la3];
    [la3 release];
    
    txtQPTM=[[UITextField alloc]initWithFrame:CGRectMake(85, 151, 150, 30)];
    txtQPTM.borderStyle=UITextBorderStyleLine;
    txtQPTM.delegate=self;
    [self.view addSubview:txtQPTM];
    [txtQPTM addTarget:self action:@selector(txtQPTM_KeyUp) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    L4=[[UILabel alloc]initWithFrame:CGRectMake(235, 151, 30, 30)];
    L4.textAlignment=NSTextAlignmentCenter;
    L4.text=@"-";
    [self.view addSubview:L4];
    
    UIButton *btnClear=[[UIButton alloc]initWithFrame:CGRectMake(260, 76, 47, 30)];
    [btnClear setTitle:@"删除" forState:UIControlStateNormal];
    btnClear.backgroundColor=[UIColor grayColor];
    [btnClear addTarget:self action:@selector(btnClear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnClear];
    [btnClear release];
    
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(260, 113, 47, 30)];
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    btnBack.backgroundColor=[UIColor grayColor];
    [btnBack addTarget:self action:@selector(btnBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    [btnBack release];
    
    UIButton *btnSubmit=[[UIButton alloc]initWithFrame:CGRectMake(260, 151, 47, 30)];
    [btnSubmit setTitle:@"提交" forState:UIControlStateNormal];
    btnSubmit.backgroundColor=[UIColor grayColor];
    [btnSubmit addTarget:self action:@selector(btnSubmit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSubmit];
    [btnSubmit release];
    
    [self setKeyToolbar];
    //[self UIManage];
}

-(void)setKeyToolbar{
    UIToolbar *topView=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:@"隐藏键盘" style:UIBarButtonItemStyleDone target:self action:@selector(resignKeyboard)];
    UIBarButtonItem *spaceButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *openButton=[[UIBarButtonItem alloc]initWithTitle:@"开窗" style:UIBarButtonItemStyleDone target:self action:@selector(openWin)];
    NSArray *buttonsArray=[NSArray arrayWithObjects:openButton,spaceButton,doneButton,nil ];
    [topView setItems:buttonsArray];
    [txtPCDH setInputAccessoryView:topView];
    [txtCK setInputAccessoryView:topView];
    [txtCW setInputAccessoryView:topView];
    [txtQPTM setInputAccessoryView:topView];
}

-(void)resignKeyboard{
    [txtPCDH resignFirstResponder];
    [txtCK resignFirstResponder];
    [txtCW resignFirstResponder];
    [txtQPTM resignFirstResponder];
}

-(void)openWin{
    
}

//根据业务类别来管控界面操作
-(void)UIManage{
    sFType=@"X";//业务类别 "K"
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope %@>\n"
                             "<soap:Body>\n"
                             "<%@ xmlns=\"%@\">\n"
                             "<Paras>%@</Paras>\n"
                             "<wType>%@</wType>\n"
                             "</%@>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",Envelopesoap,MethodNameUIManage,NameSpace,UserParas,sFType,MethodNameUIManage
                             ];
    
    //NSLog(@"%@",soapMessage);
    NSString *soapActionURL=[NSString stringWithFormat:@"%@%@",NameSpace,MethodNameUIManage];
    NetWebServiceRequest *request=[NetWebServiceRequest serviceRequestUrl:URLIP SOAPActionURL:soapActionURL ServiceMethodName:MethodNameUIManage SoapMessage:soapMessage];
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest=request;
    
}

#pragma mark KeyUp Methods

-(void)txtPCD_KeyUp{
    @try {
    
        [self CheckPCD:true];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

-(BOOL)CheckPCD:(BOOL)blNextFocus{
    NSString *str = [txtPCDH.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(str.length==0){
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"派车单号不能为空!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [a show];
        [a release];
        L1.text=@"×";
        [txtPCDH becomeFirstResponder];
        return false;
    }else if (![self CheckPCDone]){
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"已扫描了其他的派车单" message:@"一次只能提交一张派车单的资料，请先提交!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [a show];
        [a release];
        L1.text=@"×";
        [txtPCDH becomeFirstResponder];
        return false;
    }else{
        
        NSString *SQL=[NSString stringWithFormat:@"select a.FNumber as 派车单号,a.FDate as 派车时间,b.FCarNO as 车牌号 from tb_SendCar a(nolock) left join tb_Car b(nolock) on a.FCarID=b.FItemID where a.FState='1' and a.FNumber='%@'",str];
        //NSLog(@"%@",SQL);
        
        result=[self OpenDataTable:UserParas WithSQL:SQL];
        
        //NSLog(@"%@",result);
        if([result isEqualToString:@""]){
            UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"派车单号不存在!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [a show];
            [a release];
            L1.text=@"×";
            [txtPCDH becomeFirstResponder];
            return false;
        }else{
            if(!blNextFocus){
                return true;
            }
            L1.text=@"√";
            if(txtCK.enabled){
                [txtCK becomeFirstResponder];
                return true;
            }else{
                if([sFPlaceManageYN isEqualToString:@"N"]){
                    L2.text=@"√";
                    txtCW.enabled=false;
                    [txtQPTM becomeFirstResponder];
                }else{
                    txtCW.enabled=[self.sFStockPlaceYN isEqualToString:@"N"]? false:true;
                    if(!txtCW.enabled){
                        L2.text=@"√";
                        [txtQPTM becomeFirstResponder];
                    }else{
                        L2.text=@"-";
                        [txtCW becomeFirstResponder];
                    }
                }
            }
            
            return true;
        }
        

    }
}

-(BOOL)CheckPCDone{
    @try {
        BOOL FPCNumberYN=true;
        NSString *str = [txtPCDH.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        for(int i=1;i<serverlist.count;i++){
            NSDictionary *tempDic=[serverlist objectAtIndex:i];
            NSString *FPCNumber=[tempDic valueForKey:@"FPCNumber"];
            if(![FPCNumber isEqualToString:str]){
                FPCNumberYN=false;
                break;
            }
        }
        return FPCNumberYN;//无 false 有
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        return false;
    }
    @finally {
        
    }
    
}

-(void)txtCK_KeyUp{
    @try {
        [self CheckCK:true];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}

-(BOOL)CheckCK:(BOOL)blNextFocus{
    NSString *str = [txtCK.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(str.length==0){
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"仓库不能为空!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [a show];
        [a release];
        L2.text=@"×";
        [txtCK becomeFirstResponder];
        return false;
    }else{
        NSString *SQL=[NSString stringWithFormat:@"select FNumber,FName,FInterID,FPlaceYN from tb_Stock (nolock) where FNumber='%@'",str];
        //NSLog(@"%@",SQL);
        result=[self OpenDataTable:UserParas WithSQL:SQL];
        
        //NSLog(@"%@",result);
        
        NSDictionary *resultdict=[self strToDic:result];
        if([result isEqualToString:@""]){
            UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"仓库不存在!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [a show];
            [a release];
            L2.text=@"×";
            [txtCK becomeFirstResponder];
            return false;
        }else{
            txtCK.tag=[[resultdict valueForKey:@"FInterID"] intValue];
            sFPlaceManageYN=[[resultdict valueForKey:@"FPlaceYN"] uppercaseString];
            if(!blNextFocus){
                return true;
            }
            L2.text=@"√";
            if([sFPlaceManageYN isEqualToString:@"N"]){
                L3.text=@"√";
                txtCW.text=@"";
                txtCW.tag=0;
                txtCW.enabled=false;
                [txtQPTM becomeFirstResponder];
            }else{
                txtCW.enabled=[self.sFStockPlaceYN isEqualToString:@"N"]? false:true;
                if(!txtCW.enabled){
                    L3.text=@"√";
                    [txtQPTM becomeFirstResponder];
                }else{
                    L3.text=@"-";
                    [txtCW becomeFirstResponder];
                }
            }
            
            return true;
        }
        

    }
    
}

-(void)txtCW_KeyUp{
    @try {
        [self CheckCW:true];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}

-(BOOL)CheckCW:(BOOL)blNextFocus{
    NSString *str=[txtCW.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(str.length==0){
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"仓位不能为空!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [a show];
        [a release];
        L3.text=@"×";
        [txtCW becomeFirstResponder];
        return false;
    }else{
        //NSString *SQL=[NSString stringWithFormat:@"select a.FNumber as 代码,a.FName as 名称,a.FItemID from tb_SendCarD1 x left join VW_Organization y on x.FSupplyID=y.FItemID and x.FType='1' join tb_StockPlace a(nolock) on y.FNumber=a.FNumber where a.FStockID=1311008 and x.FNumber='%@' order by a.FNumber",txtPCDH.text];
        NSString *SQL=[NSString stringWithFormat:@"select FNumber,FName,FItemID from tb_StockPlace (nolock) where FNumber='%@' and FStockID=%ld",txtCW.text,(long)txtCK.tag];
        //NSLog(@"%@",SQL);
        result=[self OpenDataTable:UserParas WithSQL:SQL];
        //NSLog(@"%@",result);
        NSDictionary *resultdict=[self strToDic:result];
        if([result isEqualToString:@""]){
            UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"仓位不存在!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [a show];
            [a release];
            L3.text=@"×";
            [txtCW becomeFirstResponder];
            return false;
        }else{
            txtCW.tag=[[resultdict valueForKey:@"FItemID"] intValue];
            if(!blNextFocus){
                return true;
            }
            L3.text=@"√";
            [txtQPTM becomeFirstResponder];
            return true;
        }
        
    }
    

}

-(void)txtQPTM_KeyUp{
    @try {
        
        if([self CheckQPTM]){
//            dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//            dispatch_group_t group=dispatch_group_create();
//            dispatch_group_async(group, queue, ^{
//                [self CheckAll];
//            });
            dispatch_queue_t queue=dispatch_get_global_queue(0, 0);
            dispatch_async(queue, ^{
                [self CheckAll];
            });
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}

-(BOOL)CheckQPTM{
    
    NSString *str=[txtQPTM.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(str.length==0){
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"气瓶条码不能为空!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [a show];
        [a release];
        L4.text=@"×";
        [txtQPTM becomeFirstResponder];
        return false;
    }else{
        //使用<>会报错,用!=替代
        NSString *SQL=@"select FItemID from tb_BottleContainer  where FState !='2' and FBarcode=@FBarcode";
        NSString *ParamList=@"@FBarcode varchar(50)";
        NSString *ParamValue=[NSString stringWithFormat:@"@FBarcode='%@'",str];
        //NSLog(@"%@",SQL);
        result=[self OpenDataTableParams:UserParas WithSQL:SQL ParamList:ParamList ParamValue:ParamValue];
        //NSLog(@"%@",result);
        
        NSDictionary *resultdict=[self strToDic:result];
        if([result isEqualToString:@""]){
            //单瓶操作
            blContainer=false;
            SQL=@"select FBarcode,FItemID,FNextTestDate from tb_AirBottle (nolock) where FContainerID=0 and FState='1' and FBarcode=@FBarcode";
            ParamList=@"@FBarcode varchar(50)";
            ParamValue=[NSString stringWithFormat:@"@FBarcode='%@'",str];
            result=[self OpenDataTableParams:UserParas WithSQL:SQL ParamList:ParamList ParamValue:ParamValue];
            //NSLog(@"%@",result);
            resultdict=[self strToDic:result];
            if([result isEqualToString:@""]){
                UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"气瓶条码不存在!［或气瓶已装格或不为正常气瓶］，请查看！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
                [a show];
                [a release];
                L4.text=@"×";
                [txtQPTM becomeFirstResponder];
                return false;
            }else{
                txtQPTM.tag=[[resultdict valueForKey:@"FItemID"] intValue];
                @try {
                    if([[resultdict valueForKey:@"FNextTestDate"] isEqualToString:@""]){
                        iDiffDay=0;
                    }else{
                        //算出时间间隔天数
                        NSLog(@"%@",[resultdict valueForKey:@"FNextTestDate"]);
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                        NSDate *date = [dateFormatter dateFromString:[resultdict valueForKey:@"FNextTestDate"]];
                        NSDate *dateNow=[NSDate date];
                        NSTimeInterval ss=[date timeIntervalSinceDate:dateNow];
                        long long dTime=[[NSNumber numberWithDouble:ss] longLongValue];
                        iDiffDay=(int)(dTime/(3600*24));
                        [dateFormatter release];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception);
                    iDiffDay=0;
                }
                @finally {
                    
                }
                
                if([self CheckIsExists:@"K"]){
                    L4.text=@"√";
                    [txtQPTM becomeFirstResponder];
                    return true;
                }else{
                    return false;
                }
            }
        }else{
            //集装格操作
            blContainer=true;
            SQL=@"select min(FNextTestDate) as FNextTestDate from tb_AirBottle (nolock) where FState='1' and FContainerID=@FContainerID";
            ParamList=@"@FContainerID int";
            int FItemID=[[resultdict valueForKey:@"FItemID"] intValue];
            ParamValue=[NSString stringWithFormat:@"@FContainerID=%d",FItemID];
            result=[self OpenDataTableParams:UserParas WithSQL:SQL ParamList:ParamList ParamValue:ParamValue];
            //NSLog(@"%@",result);
            resultdict=[self strToDic:result];
            if([result isEqualToString:@""]){
                UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"此集装格条码未作装格处理，或不为正常气瓶!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
                [a show];
                [a release];
                L4.text=@"×";
                [txtQPTM becomeFirstResponder];
                return false;
            }else{
                txtQPTM.tag=FItemID;
                @try {
                    if([[resultdict valueForKey:@"FNextTestDate"] isEqualToString:@""]){
                        iDiffDay=0;
                    }else{
                        //算出时间间隔天数
                        NSLog(@"%@",[resultdict valueForKey:@"FNextTestDate"]);
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                        NSDate *date = [dateFormatter dateFromString:[resultdict valueForKey:@"FNextTestDate"]];
                        NSDate *dateNow=[NSDate date];
                        NSTimeInterval ss=[date timeIntervalSinceDate:dateNow];
                        long long dTime=[[NSNumber numberWithDouble:ss] longLongValue];
                        iDiffDay=(int)(dTime/(3600*24));
                        [dateFormatter release];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception);
                    iDiffDay=0;
                }
                @finally {
                    
                }
                
                if([self CheckIsExists:@"K"]){
                    L4.text=@"√";
                    [txtQPTM becomeFirstResponder];
                    return true;
                }else{
                    return false;
                }
            }
        }
    }
}

#pragma mark OpenDataTable Methods
//将得到的数据转为字典
-(NSDictionary *)strToDic:(NSString *)str{
    NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultdic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *Objects=[[resultdic allKeys]objectAtIndex:0];
    NSArray *resultArr=[resultdic valueForKey:Objects];
    NSDictionary *resultdict=[resultArr objectAtIndex:0];
    return resultdict;
}

-(NSString *)OpenDataTable:(NSString *)Paras WithSQL:(NSString *)SQL{
    
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope %@>\n"
                             "<soap:Body>\n"
                             "<%@ xmlns=\"%@\">\n"
                             "<Paras>%@</Paras>\n"
                             "<SQL>%@</SQL>\n"
                             "</%@>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",Envelopesoap,MethodNameOpenDataTable,NameSpace,UserParas,SQL,MethodNameOpenDataTable
                             ];
    
    //NSLog(@"%@",soapMessage);
    NSString *soapActionURL=[NSString stringWithFormat:@"%@%@",NameSpace,MethodNameOpenDataTable];
    NetWebServiceRequest *request=[NetWebServiceRequest serviceRequestUrl:URLIP SOAPActionURL:soapActionURL ServiceMethodName:MethodNameOpenDataTable SoapMessage:soapMessage];
//    [request startAsynchronous];
//    [request setDelegate:self];
//    self.runningRequest=request;
    [request startSynchronous];
    return [request responseString];
    
}

-(NSString *)OpenDataTableParams:(NSString *)Paras WithSQL:(NSString *)SQL ParamList:(NSString *)ParamList ParamValue:(NSString *)ParamValue{
    
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope %@>\n"
                             "<soap:Body>\n"
                             "<%@ xmlns=\"%@\">\n"
                             "<Paras>%@</Paras>\n"
                             "<SQL>%@</SQL>\n"
                             "<ParamList>%@</ParamList>\n"
                             "<ParamValue>%@</ParamValue>\n"
                             "</%@>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",Envelopesoap,MethodNameOpenDataTableParams,NameSpace,UserParas,SQL,ParamList,ParamValue,MethodNameOpenDataTableParams
                             ];
    //NSLog(@"%@",soapMessage);
    NSString *soapActionURL=[NSString stringWithFormat:@"%@%@",NameSpace,MethodNameOpenDataTableParams];
    NetWebServiceRequest *request=[NetWebServiceRequest serviceRequestUrl:URLIP SOAPActionURL:soapActionURL ServiceMethodName:MethodNameOpenDataTableParams SoapMessage:soapMessage];
//    [request startAsynchronous];
//    [request setDelegate:self];
//    self.runningRequest=request;
    [request startSynchronous];
    return [request responseString];
}

#pragma mark NetWebServiceRequestDelegate Methods

-(void)netRequestStarted:(NetWebServiceRequest *)request{
    HUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setHidden:NO];
    NSLog(@"---------Start");
    
}

-(void)netRequestFinished:(NetWebServiceRequest *)request finishedInfoToResult:(NSString *)resultinfo responseData:(NSData *)requestData{
    [HUD setHidden:YES];
    result=resultinfo;
    NSLog(@"----------%@",resultinfo);
    if(![result isEqualToString:@""]){
        NSDictionary *resultDict=[self strToDic:result];
        iFStockID=[[resultDict valueForKey:@"FStockID"] intValue];
        iFStockPlaceID=[[resultDict valueForKey:@"FStockPlaceID"] intValue];
        txtCK.text=[resultDict valueForKey:@"FStockName"];
        txtCK.tag=iFStockID;
        txtCW.text=[resultDict valueForKey:@"FStockPlaceName"];
        txtCW.tag=iFStockPlaceID;
        
        self.sFStockYN=[[resultDict valueForKey:@"FStockYN"] uppercaseString];
        self.sFStockPlaceYN=[[resultDict valueForKey:@"FStockPlaceYN"] uppercaseString];
        self.sFSaveUpdateYN=[[resultDict valueForKey:@"FSaveUpdateYN"] uppercaseString];
        
        if([self.sFStockYN isEqualToString:@"N"]){
            txtCK.enabled=false;
        }else{
            txtCK.enabled=true;
        }
        if([self.sFStockPlaceYN isEqualToString:@"N"]){
            txtCW.enabled=false;
        }else{
            txtCW.enabled=true;
        }
        
    }
    [txtPCDH becomeFirstResponder];

    
}

-(void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(NSError *)error{
    [HUD setHidden:YES];
    NSLog(@"error-----%@",error);
}


#pragma Mark CheckData Methods

-(BOOL)CheckIsExists:(NSString *)FType{
    @try {
        if(blContainer){
            //判断集装格条码是否重复扫描了
            NSString *SQL=@"select top 1 a.FNumber from tb_InOutStore a(nolock) left join tb_InOutStoreD1 b(nolock) on a.FNumber=b.FNumber where a.FSure<>'Y' and a.FType=@FType and b.FContainerID=@FContainerID";
            NSString *ParamList=@"@FType varchar(1),@FContainerID int";
            NSString *ParamValue=[NSString stringWithFormat:@"@FType='%@',@FContainerID=%ld",FType,(long)txtQPTM.tag];
            result=[self OpenDataTableParams:UserParas WithSQL:SQL ParamList:ParamList ParamValue:ParamValue];
            if(![result isEqualToString:@""]){
                UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"该集装格条码已经有扫描记录!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
                [a show];
                [a release];
                L4.text=@"×";
                [txtQPTM becomeFirstResponder];
                return false;
            }
            if(serverlist !=NULL && serverlist.count>0){
                BOOL FContainerIDYN=false;
                for(int i=0;i<serverlist.count;i++){
                    NSDictionary *tempDic=[serverlist objectAtIndex:i];
                    int FContainerID=[[tempDic valueForKey:@"FContainerID_hide"] intValue];
                    if(txtQPTM.tag==FContainerID){
                        FContainerIDYN=true;
                        break;
                    }
                }
                
                if(FContainerIDYN){
                    UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"该条码已扫描在明细中!不可重复扫描!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    [a show];
                    [a release];
                    L4.text=@"×";
                    [txtQPTM becomeFirstResponder];
                    return false;
                }
            }
            
            return true;
        }else{
            //判断气瓶条码是否重复扫描
            NSString *SQL=[NSString stringWithFormat:@"select top 1 a.FNumber from tb_InOutStore a(nolock) left join tb_InOutStoreD1 b(nolock) on a.FNumber=b.FNumber where a.FSure<>'Y' and a.FType='%@' and b.FAirBottleID=%ld",FType,(long)txtQPTM.tag];
            result=[self OpenDataTable:UserParas WithSQL:SQL];
            if(![result isEqualToString:@""]){
                UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"该气瓶条码已经有扫描记录!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
                [a show];
                [a release];
                L4.text=@"×";
                [txtQPTM becomeFirstResponder];
                return false;
            }
            if(serverlist !=NULL && serverlist.count>0){
                BOOL FAirBottleIDYN=false;
                for(int i=0;i<serverlist.count;i++){
                    NSDictionary *tempDic=[serverlist objectAtIndex:i];
                    int FAirBottleID=[[tempDic valueForKey:@"FAirBottleID"] intValue];
                    if(txtQPTM.tag==FAirBottleID){
                        FAirBottleIDYN=true;
                        break;
                    }
                }
                
                if(FAirBottleIDYN){
                    UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:@"该条码已扫描在明细中!不可重复扫描!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    [a show];
                    [a release];
                    L4.text=@"×";
                    [txtQPTM becomeFirstResponder];
                    return false;
                }
            }
            return true;
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        return false;
    }
    @finally {
        
    }
    
}

-(void)CheckAll{
    @try {
        NSString *ErrMsg=[self FlowVerif];
        if(![ErrMsg isEqualToString:@""]){
            NSString *ErrMsg0=[ErrMsg substringToIndex:(ErrMsg.length-1)];
            NSString *ErrMsg1=[ErrMsg substringFromIndex:(ErrMsg.length-1)];
            NSLog(@"%@---%@",ErrMsg0,ErrMsg1);
            if(![ErrMsg0 isEqualToString:@""]){
                //提醒
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *a=[[UIAlertView alloc]initWithTitle:nil message:ErrMsg0 delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    [a show];
                    [a release];

                });
            if(![ErrMsg1 isEqualToString:@"1"]){
                    return;
                }
            }
        }
        
        if(![self CheckPCD:false]){
            return;
        }
        if(![self CheckCK:false]){
            return;
        }
        if(![self CheckCW:false]){
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addDataIn];
        });
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
}

-(NSString *)FlowVerif{
    NSString *iFStockIDs=[NSString stringWithFormat:@"%ld",(long)txtCK.tag];
    NSString *iFStockPlaceIDs=[NSString stringWithFormat:@"%ld",(long)txtCW.tag];
    NSString *DiffDays=[NSString stringWithFormat:@"%d",iDiffDay];
    NSString *blContainers=blContainer==true ? @"1": @"0";
    NSString *iFBarcodeIDs=[NSString stringWithFormat:@"%ld",(long)txtQPTM.tag];
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope %@>\n"
                             "<soap:Body>\n"
                             "<%@ xmlns=\"%@\">\n"
                             "<Paras>%@</Paras>\n"
                             "<FType>%@</FType>\n"
                             "<iFStockIDs>%@</iFStockIDs>\n"
                             "<iFStockPlaceIDs>%@</iFStockPlaceIDs>\n"
                             "<DiffDays>%@</DiffDays>\n"
                             "<blContainers>%@</blContainers>\n"
                             "<iFBarcodeIDs>%@</iFBarcodeIDs>\n"
                             "</%@>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",Envelopesoap,MethodNameFlowVerif,NameSpace,UserParas,sFType,iFStockIDs,iFStockPlaceIDs,DiffDays,blContainers,iFBarcodeIDs,MethodNameFlowVerif
                             ];
    
    //NSLog(@"%@",soapMessage);
    NSString *soapActionURL=[NSString stringWithFormat:@"%@%@",NameSpace,MethodNameFlowVerif];
    NetWebServiceRequest *request=[NetWebServiceRequest serviceRequestUrl:URLIP SOAPActionURL:soapActionURL ServiceMethodName:MethodNameFlowVerif SoapMessage:soapMessage];
    [request startSynchronous];
    return [request responseString];
}

-(void)addDataIn{
    NSString *str=[txtQPTM.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(blContainer){
        NSString *SQL=@"select FContainerID,FItemID,FFullAirID,FCBarcode,FBarcode,FNumber,FQty,FMode,FSize,FFullAirNumber,FFullAirName,FFullAirModel,FStockName,FStockPlaceName,FStockPlaceID,FStockID from VW_BottleBarcodeItem where FCBarcode=@FCBarcode";
        NSString *ParamList=@"@FCBarcode varchar(50)";
        NSString *ParamValue=[NSString stringWithFormat:@"@FCBarcode='%@'",str];
        result=[self OpenDataTableParams:UserParas WithSQL:SQL ParamList:ParamList ParamValue:ParamValue];
        
    }else{
        NSString *SQL=@"select FContainerID,FItemID,FFullAirID,FCBarcode,FBarcode,FNumber,FQty,FMode,FSize,FFullAirNumber,FFullAirName,FFullAirModel,FStockName,FStockPlaceName,FStockPlaceID,FStockID from VW_BottleBarcodeItem where FBarcode=@FBarcode";
        NSString *ParamList=@"@FBarcode varchar(50)";
        NSString *ParamValue=[NSString stringWithFormat:@"@FBarcode='%@'",str];
        result=[self OpenDataTableParams:UserParas WithSQL:SQL ParamList:ParamList ParamValue:ParamValue];
        
    }
    NSDictionary *resultdict=[self strToDic:result];
    if(![result isEqualToString:@""]){
        //放入serverlist
        NSString *strPCD=[txtPCDH.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [serverlist addObject:@{@"FPCNumber":strPCD,
                                @"FAirBottleBarcode":[resultdict valueForKey:@"FBarcode"],
                                @"FMode":[resultdict valueForKey:@"FMode"],
                                @"FSize":[resultdict valueForKey:@"FSize"],
                                @"FAirBottleNumber":[resultdict valueForKey:@"FNumber"],
                                @"FItemNumber":[resultdict valueForKey:@"FFullAirNumber"],
                                @"FItemModel":[resultdict valueForKey:@"FFullAirModel"],
                                @"FItemSize":[resultdict valueForKey:@"FFullAirName"],
                                @"FQty":[resultdict valueForKey:@"FQty"],
                                @"FCBarcode":[resultdict valueForKey:@"FCBarcode"],
                                @"FItemID_hide":[resultdict valueForKey:@"FFullAirID"],
                                @"FAirBottleID_hide":[resultdict valueForKey:@"FItemID"],
                                @"FStockID_hide":[NSString stringWithFormat:@"%ld",(long)txtCK.tag],
                                @"FStockPID_hide":[resultdict valueForKey:@"FStockID"],
                                @"FStockPlaceID_hide":[NSString stringWithFormat:@"%ld",(long)txtCW.tag],
                                @"FStockPlacePID_hide":[resultdict valueForKey:@"FStockPlaceID"],
                                @"FContainerID_hide":[resultdict valueForKey:@"FContainerID"],
                                @"FType_hide":@"K"}];
        
        [self reloadData];
        [self ClearAll];
    }
    
}

-(void)reloadData{
    [self addDataBase];
    [_table reloadData];
}

-(void)ClearAll{
    txtPCDH.text=@"";
    txtQPTM.text=@"";
    txtCK.text=@"";
    txtCW.text=@"";
    L1.text=@"-";
    L2.text=@"-";
    L3.text=@"-";
    L4.text=@"-";
}

-(void)SetFocus{
    
}

//系统的四个按钮
-(void)btnClear{
    NSLog(@"Clear");
    
}

-(void)btnBack{
    NSLog(@"Back");
    if(serverlist.count==1){
        [self.stack popViewControllerAnimated:YES];
    }else{
        NSLog(@"PDA刷入条码资料未提交!");
    }
    
}

-(void)btnSubmit{
    if(serverlist.count==1){
        NSLog(@"无资料可提交!");
    }else{
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"欧软提示" message:@"确认提交数据?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        [a show];
        [a release];
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    if(buttonIndex==1){
        [self InsertStore];
    }
}

-(void)InsertStore{
    NSMutableDictionary *tempDic=[NSMutableDictionary dictionary];
    for(int i=1;i<serverlist.count;i++){
        NSMutableArray *tempArr=[NSMutableArray array];
        [tempArr addObject:[serverlist objectAtIndex:i]];
        [tempDic setObject:tempArr forKey:[NSString stringWithFormat:@"Table%d",i]];
    }
    NSError *error=nil;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:tempDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *DataJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"DataJson------------%@",DataJson);
    NSString *ErpUserID=@"1310001";
    NSString *PrgKey=@"";
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope %@>\n"
                             "<soap:Body>\n"
                             "<%@ xmlns=\"%@\">\n"
                             "<Paras>%@</Paras>\n"
                             "<DataJson>%@</DataJson>\n"
                             "<ErpUserID>%@</ErpUserID>\n"
                             "<PrgKey>%@</PrgKey>\n"
                             "</%@>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",Envelopesoap,MethodNameInsertStore,NameSpace,UserParas,DataJson,ErpUserID,PrgKey,MethodNameInsertStore
                             ];
    
    //NSLog(@"%@",soapMessage);
    NSString *soapActionURL=[NSString stringWithFormat:@"%@%@",NameSpace,MethodNameInsertStore];
    NetWebServiceRequest *request=[NetWebServiceRequest serviceRequestUrl:URLIP SOAPActionURL:soapActionURL ServiceMethodName:MethodNameInsertStore SoapMessage:soapMessage];
    [request startSynchronous];
    result=[request responseString];
    if([result isEqualToString:@"1"]){
        NSLog(@"提交成功!");
    }else{
        NSLog(@"%@",result);
    }
}
//
//-(void)Scan{
//    NSLog(@"Scan %@",self.index);
//    ZBarReaderViewController *reader=[ZBarReaderViewController new];
//    reader.readerDelegate=self;
//
//    reader.showsZBarControls=NO;
//    
//    [self setOverlayPickerView:reader];
//    
//    reader.supportedOrientationsMask=ZBarOrientationMaskAll;
//    
//    ZBarImageScanner *scanner=reader.scanner;
//    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
//    [self presentViewController:reader animated:YES completion:nil];
//
//}
//
////填充界面
//-(void)setOverlayPickerView:(ZBarReaderViewController *)reader{
//    for(UIView *temp in [reader.view subviews])
//    {
//        for(UIButton *btn in [temp subviews]){
//            if([btn isKindOfClass:[UIButton class]]){
//                [btn removeFromSuperview];
//            }
//        }
//        for(UIToolbar *toolbar in [temp subviews]){
//            if([toolbar isKindOfClass:[UIToolbar class]]){
//                [toolbar setHidden:YES];
//                [toolbar removeFromSuperview];
//            }
//        }
//    }
//    
//    //cancelButton
//    UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeRoundedRect ];
//    cancelButton.alpha=0.4;
//    [cancelButton setFrame:CGRectMake(20, 390, 280, 40)];
//    [cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
//    [cancelButton addTarget:self action:@selector(dismissOverlayView:) forControlEvents:UIControlEventTouchUpInside];
//    [reader.view addSubview:cancelButton];
//}
//
//-(void)dismissOverlayView:(id)sender{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    id<NSFastEnumeration> results=
//    [info objectForKey:ZBarReaderControllerResults];
//    ZBarSymbol *symbol=nil;
//    for(symbol in results)
//        break;
//    
//    NSLog(@"%@",symbol.data);
//    NSLog(@"%d",delegate.index);
//    int s=[delegate.index intValue];
//    switch (s) {
//        case 1:
//            txtPCDH.text=symbol.data;
//            [self txtPCD_KeyUp];
//            break;
//        case 2:
//            txtCK.text=symbol.data;
//            [self txtCK_KeyUp];
//            break;
//        case 3:
//            txtCW.text=symbol.data;
//            [self txtCW_KeyUp];
//            break;
//        case 4:
//            txtQPTM.text=symbol.data;
//            [self txtQPTM_KeyUp];
//            break;
//    }
//    
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"-9.000000",
                                                                  @"2",@"29.000000",
                                                                  @"4",@"66.000000",
                                                                  @"3",@"-46.000000", nil];
    double c=textField.frame.origin.y-textField.frame.origin.x;
    NSString *e=[NSString stringWithFormat:@"%f",c];
    NSString *f=[dic valueForKey:e];
    delegate.index=f;
    return true;
}

#pragma mark -TableViewDelegate Methods

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (cell) {
        [[cell contentView] removeAllSubviews];
        [cell removeAllSubviews];
        cell=nil;
    }
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
        
        cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        cell.selectedBackgroundView.backgroundColor =
        [UIColor colorWithRed:214/255.0 green:229/255.0 blue:239/255.0 alpha:1];
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self AddCell:indexPath forCell:cell];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSDictionary *selectCell=[_datas objectAtIndex:indexPath.row];
    //NSString *testid=  [selectCell valueForKey:@"testid"];
    //NSString *testname=  [selectCell valueForKey:@"testname"];
    
    //NSString *msg=[NSString stringWithFormat:@"testid=%@,\n 名字:%@",testid,testname];
    //NSLog(@"%@",msg);
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
    
    NSLog(@"%d",indexPath.row);
}

- (void)AddCell:(NSIndexPath *)indexPath forCell:(UITableViewCell *)cell{
    NSDictionary *cellData=[_datas objectAtIndex:indexPath.row];
    
    NSString *tempval=@"";
    // cellwidth
    float x = 0; //x 坐标
    
    //NSLog(@"%@",_colNameList);
    
    for(int i = 0; i < [_colNameList count]; i++) {
        NSString *titlename=@"";
        NSString *colname=@"";
        NSDictionary *namek_v=[_colNameList objectAtIndex:i];
        
        
        NSArray *keys = [namek_v allKeys];
        
        for (unsigned int i = 0; i < [keys count]; i++)
        {
            colname = [keys objectAtIndex: i];  //表列名
            titlename= [namek_v objectForKey: colname];//显示界面上的列名
        }
        
        
        tempval=[cellData valueForKey:colname];//值
        
        /*列宽px*/
        NSString *tempname=[NSString stringWithFormat:@"%@width",colname];
        NSString *tempwidth=[cellData valueForKey:tempname];
        
        @try {
            
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(x, 0, [tempwidth intValue], _table.rowHeight)] autorelease];
            
            label.contentMode = UIViewContentModeCenter;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = tempval;
            label.textColor=[UIColor colorWithRed:96/255.0 green:97/255.0 blue:100/255.0 alpha:1];
            label.font = [UIFont systemFontOfSize:14.0];
            [[cell contentView] addSubview:label];
            
            //线
            UILabel *lineh=[[[UILabel alloc] init] autorelease];
            CGRect cg_lineh=label.frame;
            //cg_lineh.origin.x+=cg_lineh.size.width-1;
            cg_lineh.size.width=1;
            lineh.frame=cg_lineh;
            lineh.backgroundColor=[UIColor grayColor];
            [[cell contentView] addSubview:lineh];
            //            NSLog(@"%@--width",tempwidth);
            //            NSLog(@"%@--value",tempval);
            //            NSLog(@"%f--x",colWidth);
            if (tempwidth!=nil) {
                x+=[tempwidth floatValue];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"ERROR:%@", exception.name);
            
        }
    }
}

//创建Table头 列名
-(void)createTableHeaderName{
    
    NSString *showColName=@"";
    NSString *colname=@"";
    NSString *colWidthName=@"";
    
    CGFloat x=0;
    for(int i = 0; i < [_colNameList count]; i++) {
        
        NSDictionary *namek_v=[_colNameList objectAtIndex:i];
        
        id keys = [namek_v allKeys];
        colname = [keys objectAtIndex: 0];  //表列名
        showColName=[namek_v valueForKey:colname];//显示界面列名
        
        NSString *temp=[NSString stringWithFormat:@"%@",showColName];
        colWidthName=[NSString stringWithFormat:@"%@width",colname];
        
        NSString *colwidth= [self selectColMaxWidthByName:colWidthName];
        //NSLog(@"%@--width",colwidth);
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(x, 0, colwidth.floatValue ,40)] autorelease];
        label.backgroundColor=[UIColor clearColor];
        
        
        
        label.contentMode = UIViewContentModeCenter;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = temp;  //列名
        label.font = [UIFont systemFontOfSize:15.0];
        [_headView addSubview:label];
        
        
        //线
        UILabel *lineh=[[[UILabel alloc] init] autorelease];
        CGRect cg_lineh=label.frame;
        //cg_lineh.origin.x+=cg_lineh.size.width-1;
        cg_lineh.size.width=1;
        lineh.frame=cg_lineh;
        lineh.backgroundColor=[UIColor grayColor];
        [_headView addSubview:lineh];
        
        x+=colwidth.floatValue;
    }
    
    
}

@end


