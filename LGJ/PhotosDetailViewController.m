//
//  PhotosDetailViewController.m
//  Trip1
//
//  Created by lanou on 15/7/2.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "PhotosDetailViewController.h"
#import "LGJHeader.h"
#import "photoCell.h"
#import "SceneModel.h"
#import "PhotosDataByCity.h"
#import "UIImageView+WebCache.h"
#import "BaseImageView.h"
@interface PhotosDetailViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSString *curentCityName;
}

@property (nonatomic,retain) UICollectionView *collectionView;
@property (nonatomic,retain) UIButton *backBtn;
@property (nonatomic,retain) UITapGestureRecognizer *sinleTap;
@end

@implementation PhotosDetailViewController

-(void)dealloc
{

    [[SDWebImageManager sharedManager] cancelAll];
    
    
    
    
    [[SDImageCache sharedImageCache] clearMemory];
    [_sinleTap release];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
//    [_backBtn release];//用buttonWithType不需要释放，alloca的需要释放
    [_model release];
    [_photosArray release];
    [_collectionView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self creatCllectionViw];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString *cityName = [[NSUserDefaults standardUserDefaults] objectForKey:@"cityName"];
    curentCityName = cityName;
    
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(20, 25, 30, 30);
    [back setImage:[UIImage imageNamed:@"back_white_colour@2x.png"] forState:UIControlStateNormal];
    [self.view addSubview:back];
    [back addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn = back;
    [back release];
    
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)creatCllectionViw
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 20);
    flowLayout.itemSize = CGSizeMake(LGJWidth, LGJHeight + 64 + 49);
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, LGJWidth + 20, LGJHeight + 49 + 64) collectionViewLayout: flowLayout];
    [self.view addSubview:collection];
    self.collectionView = collection;
    
    collection.delegate = self;
    collection.dataSource = self;
    collection.pagingEnabled = YES;
    [collection release];
    
    [flowLayout release];
    
    
    collection.backgroundColor = [UIColor blackColor];
    [collection registerClass:[photoCell class] forCellWithReuseIdentifier:@"photoCell"];
    collection.contentOffset = self.contentOffset;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [collection addGestureRecognizer:singleTap];
    [singleTap release];
    self.sinleTap = singleTap;
    
}

-(void)singleTap:(UITapGestureRecognizer *)tap
{
    
    if(self.backBtn.frame.origin.y < 0)
    {
        __block PhotosDetailViewController *wSelf = self;
        [UIView animateWithDuration:0.4 animations:^{
            wSelf.backBtn.frame = CGRectMake(10, 20, 44, 44);
            wSelf.backBtn.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }];
        
    }
    else
    {
        __block PhotosDetailViewController *wSelf = self;
        [UIView animateWithDuration:0.4 animations:^{
            wSelf.backBtn.frame = CGRectMake(10, -44, 44, 44);
            wSelf.backBtn.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }];
        
    }
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
}
//消失之后cell复原
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    photoCell *cellPhoto = (photoCell *)cell;
    [cellPhoto backToNormalFrame];
//    [cellPhoto.imgv stopAnimating];
    
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.photosArray.count - 1 ){
        [self footerRefresh];
        
        NSLog(@"-------------------");
    }
    
}
#pragma -mark 尾部刷新
-(void)footerRefresh
{
    [self addPhotosArrayByCityName:curentCityName andPage:(int)(self.photosArray.count) andModelID:self.model.ID];
}
-(void)addPhotosArrayByCityName:(NSString *)cityName andPage:(int)page andModelID:(NSString *)ID
{
    __block PhotosDetailViewController *wSelf = self;
    [PhotosDataByCity getDataByCityName:cityName andPage:page andModelID:ID  arrayBlock:^(NSMutableArray *array) {
        if (wSelf.photosArray == nil) {
            wSelf.photosArray = [[[NSMutableArray alloc] init] autorelease];
        }
        
        if (array.count != 0) {
            [wSelf.photosArray addObjectsFromArray:array];
            //刷新
            [wSelf.collectionView reloadData];
        }
        
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        photoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
        NSString *urlString = [self.photosArray objectAtIndex:indexPath.row];
        NSArray *array = [urlString componentsSeparatedByString:@"?"];
//        //预留功能
//        [cell.imgv addTarget:self action:@selector(photoViewBeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.imgv indicatorStartAnimating];
        __block photoCell *wCell = cell;
    
    
    
    
        [cell.imgv sd_setImageWithURL:[NSURL URLWithString:array[0]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (error == nil) {
                [wCell.imgv indicatorStopAnimating];
            }
        }];
    
#warning 避免手势冲突
        [self.sinleTap requireGestureRecognizerToFail:cell.doubleTap];
    NSLog(@"%ld,%ld",indexPath.row,self.photosArray.count);
        return cell;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear:animated];
    [EnabelLeftOrRIght setSideViewEnabelSwip:NO];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [[SDImageCache sharedImageCache] clearMemory];
    [super viewWillDisappear:animated];
    [EnabelLeftOrRIght setSideViewEnabelSwip:YES];
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
