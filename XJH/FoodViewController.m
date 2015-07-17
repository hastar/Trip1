//
//  FoodViewController.m
//  Trip1
//
//  Created by lanou on 15/6/22.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "FoodViewController.h"
#import "FoodTableViewCell.h"
#import "AsyNetworkTool.h"
#import "DomesticCity.h"
#import "DomesticCityData.h"
#import "FoodModel.h"
#import "MJRefresh.h"
#import "FoodListViewController.h"
#import "FoodPicListViewController.h"
#import "AppDelegate.h"
#import "YRSideViewController.h"
#define XJHWidth ([[UIScreen mainScreen] bounds].size.width)
#define XJHHeight ([[UIScreen mainScreen] bounds].size.height - 64 - 49)
static int lastCount= 20;
@interface FoodViewController ()<UITableViewDataSource,UITableViewDelegate,AsyNetworkToolDelegata,UINavigationControllerDelegate,UIAlertViewDelegate>
{
    DomesticCity *model;
    NSString *currentCityName;
    NSString *cityName;
    DomesticCityData *data;
}
@property (nonatomic, retain) NSMutableArray *foodArray;
@property (nonatomic, retain) UITableView *foodTableView;
@end

@implementation FoodViewController

-(void)dealloc
{
    NSLog(@"foodvd");
    self.hud = nil;
    [_foodTableView release];
    [_foodArray release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //为了隐藏navBar而遵守的代理方法
    self.navigationController.delegate = self;
 
    self.foodTableView = [[[UITableView alloc]initWithFrame:CGRectMake(0, 0, XJHWidth, XJHHeight) style:UITableViewStylePlain]autorelease];
    _foodTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.foodTableView.dataSource = self;
    self.foodTableView.delegate = self;
    [self.view addSubview:_foodTableView];
    self.foodTableView.backgroundColor = BackgroundColor;
    [_foodTableView release];
//    NSLog(@"self.foodTableView.retainCount=%lu",self.foodTableView.retainCount);
    //本地数据持久化
    currentCityName = [[NSUserDefaults standardUserDefaults] objectForKey:@"cityName"];
    
    if (currentCityName == nil) {
        currentCityName = @"上海";
        self.navigationItem.title = currentCityName;
        [self lodaData:@"上海"];
    }else
    {
        [self lodaData:currentCityName];
        self.navigationItem.title = currentCityName;
    }
    
    //通知第一步
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceive:) name:@"notificationCityName" object:nil];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    [leftBtn addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"showLeft@2x"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftBtn]autorelease];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 5, 25, 25);
    [rightBtn addTarget:self action:@selector(showRight) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"showRight@2x"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBtn]autorelease];


    // Do any additional setup after loading the view.
}
-(void)showLeft
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    YRSideViewController *sideView = app.sideViewController;
    [sideView showLeftViewController:YES];
}
-(void)showRight
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    YRSideViewController *sideView = app.sideViewController;
    [sideView showRightViewController:YES];
}


#pragma -mark加载数据
-(void)lodaData:(NSString *)city
{
    data = [DomesticCityData shareInstance];
    model = [data.domesticCityDic objectForKey:city];
    NSString *str = @"pois/restaurant/?sort=default&start=0";
    NSString *url = [model.fullPath stringByAppendingString:str];
    
    NSLog(@"url==%@ %d %s",url,__LINE__,__FUNCTION__);
    
    AsyNetworkTool *asy = [[AsyNetworkTool alloc]initWithUrlString:url];
    asy.delagate = self;
    
    if (url != nil ) {
        //小菊花
        [self p_setupProgressHud];
        //打开状态栏的小菊花
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        //开启一个 （没开启一个就要在结束的时候相对应的减少一个）
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    }
     //添加上拉更新控件
    [self.foodTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
   
    
    [asy release];
    
}
#pragma -mark侧滑选中执行的方法
-(void)notificationReceive:(NSNotification *)notification
{
    
    cityName = [notification.userInfo objectForKey:@"city"];
    if ([cityName isEqualToString: currentCityName]) {
        return;
    }
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    currentCityName = cityName;
    [self.foodArray removeAllObjects];
    [self lodaData:currentCityName];
    [self.foodTableView reloadData];
    self.navigationItem.title = cityName;
//    if (_foodArray.count == 0 ) {
//         [_hud hide:YES afterDelay:3];
//         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
//        
//    }
}
#pragma -mark设置loading
-(void)p_setupProgressHud
{
    self.hud = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
    _hud.frame = self.view.bounds;
    _hud.minSize = CGSizeMake(100, 100);
    _hud.mode = MBProgressHUDModeCustomView;
    [self.view addSubview:_hud];
    [_hud show:YES];
    
    
}
#pragma -mark下拉刷新数据
- (void)footerRereshing
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    if (model.fullPath == nil) {
        [self lodaData:currentCityName];
    }
    if (model.fullPath !=0 ) {
        if (_foodArray.count == 0 ) {
            lastCount= 0;
            [_hud show:YES];
            [self.foodTableView.footer endRefreshing];
        
        }
        NSString *url = [NSString stringWithFormat:@"%@pois/restaurant/?sort=default&start=%d",model.fullPath,lastCount];
        NSLog(@"%@   ---%d%s",url,__LINE__,__FUNCTION__);
        //    NSLog(@"%@",NSHomeDirectory());
        AsyNetworkTool *asy = [[AsyNetworkTool alloc]initWithUrlString:url];
        asy.delagate = self;
        lastCount += 20;
        [asy release];
        return;

    }
    [self.foodTableView.footer endRefreshing];
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    

}

#warning UINavigationControllerDelegate 代理方法
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ( [viewController isKindOfClass:[FoodListViewController class]]) {
        [navigationController setNavigationBarHidden:YES animated:animated];
        [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
    } else if ( [navigationController isNavigationBarHidden] ) {
        [navigationController setNavigationBarHidden:NO animated:animated];
    }
}

#pragma -mark数据存进Model
-(void)upDataDic:(NSDictionary *)dic
{
  ;
    NSArray *array = dic[@"items"];
    
    for (NSDictionary *dic in array) {

        FoodModel *food = [[FoodModel alloc]init];
        
        [food setValuesForKeysWithDictionary:dic];
        
        [self.foodArray addObject:food];
        [food release];
    }

    [self.foodTableView reloadData];
    
    [self.foodTableView.footer endRefreshing];
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    [_hud hide:YES];
}
#pragma -mark 网址请求数据的代理方法
-(void)asyResult:(id)result
{
    if (result !=nil) {
        NSDictionary *dic =(NSDictionary *)result;
        
        [self upDataDic:dic];

    }else
    {
        [self.foodTableView.footer endRefreshing];
        
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        [_hud hide:YES];
    }
    
    
}
#pragma -mark UITableViewDataSource的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foodArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    FoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[FoodTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
#warning 取消cell的选中状态
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    FoodModel *food = _foodArray[indexPath.row];
    cell.foodModel = food;
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //选中动画效果
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    FoodListViewController *foodList = [[FoodListViewController alloc]init];
    foodList.hidesBottomBarWhenPushed = YES;
    //传值
    FoodModel *foodModel=_foodArray[indexPath.row];
    foodList.model = foodModel;
    
    [self.navigationController pushViewController:foodList animated:YES];
    [foodList release];
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self viewDidLoad];
    }
}
#pragma -mark 懒加载
-(NSMutableArray *)foodArray
{
    if (!_foodArray) {
        _foodArray = [[NSMutableArray alloc]init];
    }
    return [[_foodArray retain]autorelease];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
