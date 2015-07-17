//
//  RecommendViewController.m
//  Trip1
//
//  Created by lanou on 15/6/20.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "RecommendViewController.h"
#import "AFHTTPRequestOperation.h"
#import "C_DataHandle.h"
#import "City.h"
#import "UIImageView+WebCache.h"
#import "LineViewController.h"
#import "YRSideViewController.h"
#import "AppDelegate.h"

#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationDrop.h"
#import "PopupView.h"
#import "DetailTravelController.h"
#import "MBProgressHUD.h"
#import "EnabelLeftOrRIght.h"
#import "DomesticCityData.h"
//=======
//#import "BaseImageView.h"
//>>>>>>> .r82
@interface RecommendViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIImageView *_hubView;
}
@property (nonatomic,retain) NSMutableArray *array;
@property (nonatomic,retain) NSString *cityName;
@property (nonatomic,retain) NSString *BaseID;
//{
//    BaseImageView *base;
//}
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCollectionView];
    [DomesticCityData shareInstance].domesticCityDic;
    
    //添加活动指示器
    _hubView = [[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds]autorelease];
    _hubView.image = [UIImage imageNamed:@"hub"];
    _hubView.tag = 1000;
    [C_DataHandle addView:_hubView HubToView:self.view];
    self.view.backgroundColor = [UIColor grayColor];

    //读取保存在沙盒里的城市名称
    self.cityName = [[NSUserDefaults standardUserDefaults] objectForKey:@"cityName"];
    if (self.cityName == nil) {
        self.cityName = @"上海";
    }
    //导航栏
    self.navigationItem.title = self.cityName;

    

    //获得URL
    [self refreshBaseID];
    
    [self getCityDataByUrlString:self.BaseID];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doNotification:) name:@"notificationCityName" object:nil];

//
    
    //添加左右按钮
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"showRight"  ofType:@"png"];
//    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    right.frame = CGRectMake(0, 0, 25, 25);
    [right setImage:[UIImage imageNamed:@"showRight@2x"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:right]autorelease];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(0, 0, 30, 30);
    [left setImage:[UIImage imageNamed:@"showLeft"] forState:UIControlStateNormal];
    [left addTarget:self action:@selector(cityChoose) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:left]autorelease];
    
    


}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [EnabelLeftOrRIght setSideViewEnabelSwip:YES];
}

-(void)refreshBaseID
{
    //---------------------------------------------
    //首先读取studentInfo.plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSDictionary *dictionary = [[[NSDictionary alloc] initWithContentsOfFile:plistPath]autorelease];
    
    
    NSString *string  = [dictionary objectForKey: self.cityName];
    self.BaseID = [NSString stringWithFormat:@"http://api.breadtrip.com/destination/place/%@/",string];
    //  NSLog(@"self.baseid = %@",self.BaseID);
    
    //------------------------------------------------------

}

#pragma -mark 通知执行的方法
-(void)doNotification:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    NSString *cityname = dic[@"city"];
  //  NSLog(@"--cityname = %@",cityname);
    //  NSLog(@"self.cityName = %@ ",self.cityName);
    if (![self.cityName isEqualToString:cityname]) {
        self.cityName = cityname;
        //        NSLog( @"self.cityName = %@",cityname);
        //     NSLog(@"count ==~~~~~~~~~~~~~~~~~~~~~~~~~~~%ld",[self.navigationController.viewControllers count]);
        
        if (self.navigationController.viewControllers.count > 1) {
            //        NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%@",[self.navigationController.viewControllers objectAtIndex:1]);
            
            if ([[self.navigationController.viewControllers objectAtIndex:1]isKindOfClass:[ LineViewController class]]) {
                self.navigationItem.title = cityname;
                [self.array removeAllObjects];
                [self refreshBaseID];
                [self getCityDataByUrlString:self.BaseID];
                [C_DataHandle  hiddenHubAndView:_hubView];
                return;
            }
        }
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSUserDefaults standardUserDefaults]setObject:cityname forKey:@"cityName"];
        self.navigationItem.title = cityname;
        [self.array removeAllObjects];
        [self refreshBaseID];
        [self getCityDataByUrlString:self.BaseID];
        //   NSLog(@"--------------");
        
    }
    
}

#pragma -mark 懒加载
-(NSMutableArray *)array
{
 //    NSLog(@"----+++++---");
    if (_array == nil) {

        _array = [[NSMutableArray alloc]init];
       
    }
    return [_array retain];
}


-(void)getCityDataByUrlString:(NSString *)urlString
{
    //static int c = 0;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic=[NSJSONSerialization  JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//NSLog(@"获取到的数据为：%@",dic);
        NSArray *array1 = dic[@"hottest_places"];
        
        for (NSDictionary *dic1 in array1) {
            City *city = [[[City alloc]init]autorelease];
            [city  setValuesForKeysWithDictionary:dic1];
            [self.array addObject:city];
   //         NSLog(@"city.image = %@",city.photo);
//
        }
   //     NSLog(@"self.array = %@",self.array);
        
       // if (c == 0) {
        
        
          //  c++;
        NSArray *viewArray =   self.view.subviews;
  
        for (UIView *view in viewArray) {
            if (view.tag == 1000) {
                [C_DataHandle  hiddenHubAndView:view];
            }
            if ([view isKindOfClass:[MBProgressHUD class]]) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];

            }
        }
        [self.collectionView reloadData];
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
    }];
    
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init]autorelease];
    [queue addOperation:operation1];

}





#pragma -mark collectionView

-(void)initCollectionView
{
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64) collectionViewLayout:[self PicListCollectionViewFlowLayout]];
    if (self.h1 == [UIScreen mainScreen].bounds.size.height-49) {
        self.collectionView.frame =  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49);
    }
    [self.view addSubview:_collectionView];
    _collectionView.delegate = self;
    _collectionView.dataSource =self;
    // _collectionView.pagingEnabled =YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    // NSLog(@"------------");
    // _collectionView.contentOffset = CGPointMake(XJHWidth*self.PicNumber+(self.PicNumber*20), XJHHeight);
    
    
    //注册
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cityCell"];
    [self.collectionView release];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
   //  NSLog(@"array.count = %ld",self.array.count);
    return self.array.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
  //  NSLog(@"cellll");
//    UINib *nib = [UINib nibWithNibName:@"cityCell" bundle: [NSBundle mainBundle]];
//    [collectionView registerNib:nib forCellWithReuseIdentifier:@"cityCell"];
//   UICollectionViewCell *cell = [[UICollectionViewCell alloc]init];
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cityCell" forIndexPath:indexPath];
    if (cell == nil) {
     //   NSLog(@"+++++++++++++++");
        cell = [[[UICollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, 200, 200)]autorelease];
    }
    City *city = self.array[indexPath.row];
    
    UIImageView *imageView1 = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)]autorelease];
    [imageView1 sd_setImageWithURL:[NSURL URLWithString:city.photo]];
 //   NSLog(@"city.hottest_places = %@",city.photo);
    //   [cell.contentView addSubview:imageView1];
    cell.backgroundView = imageView1;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.navigationController.viewControllers;
     NSInteger  a =  array.count;
    if (a> 1) {
        if ( [array[a-2] isKindOfClass:[LineViewController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
   
    City *city = self.array[indexPath.row];
    DetailTravelController  *dvc = [[[DetailTravelController alloc]init]autorelease];
    NSInteger m = city.trip_id;
   // NSLog(@"m = %ld",m);
    if (m == 0) {
        m = 2387675584;
    }
    dvc.travelID = [NSString stringWithFormat:@"%ld",m];
    dvc.hidesBottomBarWhenPushed = YES ;
    [self.navigationController pushViewController:dvc animated:YES];
    
}







-(UICollectionViewFlowLayout *)PicListCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc]init]autorelease];
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 330);
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(1, 0, 0, 0);
 //   NSLog(@"lay ouy ");
    return flowLayout;
    
}

#pragma -mark 左右侧滑动作按键
-(void)cityChoose
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    YRSideViewController *sideViewController=[delegate sideViewController];
    [sideViewController showLeftViewController:YES];
    
}

-(void)settings
{
        AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
        YRSideViewController *sideViewController = delegate.sideViewController;
        [sideViewController showRightViewController:YES];
    
//    PopupView *view = [PopupView defaultPopuView];
//    view.parentVC = self;
//    [self lew_presentPopupView:view animation:[LewPopupViewAnimationDrop new] dismissed:^{
    
//    }];
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

- (void)dealloc {
    [_collectionView release];
    [_cityName release];
    [_BaseID release];
    _collectionView.delegate = nil;
    [super dealloc];
}
@end
