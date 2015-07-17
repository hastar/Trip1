//
//  FoodPicListViewController.m
//  Trip1
//
//  Created by lanou on 15/6/28.
//  Copyright © 2015年 kevin. All rights reserved.
//

#import "FoodPicListViewController.h"
#import "EnabelLeftOrRIght.h"
#import "FoodPicListCollectionViewCell.h"
#import "FoodPicModel.h"
#import "UIImageView+WebCache.h"//SD第三方
#import "SDImageCache.h"//做缓存的时候使用
#import "AsyNetworkTool.h"
#import "BaseImageView.h"
#define XJHWidth ([[UIScreen mainScreen] bounds].size.width)
#define XJHHeight ([[UIScreen mainScreen] bounds].size.height)
#define PicUrl @"http://api.breadtrip.com/destination/place/5/"
@interface FoodPicListViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,AsyNetworkToolDelegata>
{
    int lastCount ;
    UIButton *button;
}
@property (nonatomic,retain) UICollectionView *picListCollectionView;
@property (nonatomic,retain) UITapGestureRecognizer *sinleTap;
@end

@implementation FoodPicListViewController
- (void)dealloc
{
    NSLog(@"PicListRelese");
    [_sinleTap release];
    _picListCollectionView.delegate = nil;
    //在这个页面结束的时候要进行网络的请求结束
    [[SDWebImageManager sharedManager] cancelAll];
    [[SDImageCache sharedImageCache]clearMemory];
    Block_release(_arrBlock);
    [_mID release];
    [_PicListUrl release];
    [_picListArray release];
    [_picListCollectionView release];
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(XJHWidth,XJHHeight);
    flowLayout.minimumLineSpacing = 20;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 20);
    UICollectionView *foodListPic =[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, XJHWidth+20, XJHHeight) collectionViewLayout:flowLayout] ;
    self.picListCollectionView = foodListPic;
    
    [self.view addSubview:_picListCollectionView];
    _picListCollectionView.delegate = self;
    _picListCollectionView.dataSource =self;
    _picListCollectionView.pagingEnabled =YES;
    _picListCollectionView.showsHorizontalScrollIndicator = NO;
    _picListCollectionView.showsVerticalScrollIndicator = NO;
    
    _picListCollectionView.backgroundColor = [UIColor blackColor];
    
    //点击响应的偏移对应的位置 contentOffset 偏移量
    _picListCollectionView.contentOffset = CGPointMake(XJHWidth*self.PicNumber+(self.PicNumber*20), XJHHeight);
    
    //注册
    [_picListCollectionView registerClass:[FoodPicListCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    //点击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [_picListCollectionView addGestureRecognizer:singleTap];
    [singleTap release];
    [flowLayout release];
    [foodListPic release];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(20, 30, 30, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"back_white_colour@2x"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(comeBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    // Do any additional setup after loading the view.
}
#pragma -mark 点击隐藏statuBar
-(void)singleTap:(UITapGestureRecognizer *)tap
{
    
    if(button.frame.origin.y < 0)
    {
        [UIView animateWithDuration:0.4 animations:^{
            button.frame = CGRectMake(20, 30, 32, 32);
            button.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.4 animations:^{
            button.frame = CGRectMake(20, -30, 32, 32);
            button.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }];
        
    }
}
#pragma -mark block传值的方法
-(void)retureArr:(ReturnPicArray)block
{
    self.arrBlock = block;
    
}

-(void)comeBack:(UIButton *)button
{
    
    if (self.arrBlock != nil) {
        self.arrBlock(self.picListArray);
    }
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.picListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FoodPicListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    FoodPicModel *picModel = self.picListArray[indexPath.row];
#warning 字符串截取
    NSArray *urlArray = [picModel.photo_s componentsSeparatedByString:@"?"];
    
    //    NSURL *imageUrl = [NSURL URLWithString:[picModel.photo_s substringToIndex:110-29]];
    NSURL *imageUrl = [NSURL URLWithString:urlArray[0]];
    [cell.imageView2 indicatorStartAnimating];
    //    [cell.imageView2 sd_setImageWithURL:imageUrl];
    [cell.imageView2 sd_setImageWithURL:imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //        cell.image = image;
        [cell.imageView2 indicatorStopAnimating];
    }];
#warning 避免手势冲突
    [self.sinleTap requireGestureRecognizerToFail:cell.doubleTap];
    
    return cell;
}
//消失之后cell复原
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FoodPicListCollectionViewCell *cellPhoto = (FoodPicListCollectionViewCell *)cell;
    [cellPhoto backToNormalFrame];
    
}
-(void)footerRereshing
{

    lastCount = (int)self.picListArray.count + 18;
    NSString *url =[NSString stringWithFormat:@"%@%@/photos/?count=%d",PicUrl,self.mID,lastCount];
    AsyNetworkTool *asy = [[AsyNetworkTool alloc]initWithUrlString:url];
    asy.delagate = self;
    [asy release];
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == self.picListArray.count - 1) {

        [self footerRereshing];
        
    }
}
-(void)asyResult:(id)result
{
    NSDictionary *dic = (NSDictionary *)result;
    [self upDataforModel:dic];
    
}
-(void)upDataforModel:(NSDictionary *)dic
{
    NSArray *arr = dic[@"items"];
    
    if (arr ==nil) {
        return;
    }
    [self.picListArray removeAllObjects];
    for (NSDictionary *picDic in arr) {
        FoodPicModel * foodPic = [[FoodPicModel alloc]init];
        [foodPic setValuesForKeysWithDictionary:picDic];
        [self.picListArray addObject:foodPic];
        [foodPic release];
        
    }
    [self.picListCollectionView reloadData];
    
}

//-(UICollectionViewFlowLayout *)PicListCollectionViewFlowLayout
//{
//        return flowLayout;
//}

-(void)viewWillAppear:(BOOL)animated
{
  
    [super viewWillAppear:animated];
    [EnabelLeftOrRIght setSideViewEnabelSwip:NO];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [EnabelLeftOrRIght setSideViewEnabelSwip:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSMutableArray *)picListArray
{
    if (!_picListArray) {
        _picListArray = [[NSMutableArray alloc]init];
        
    }
    return [[_picListArray retain]autorelease];
    
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
