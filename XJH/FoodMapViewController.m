//
//  FoodMapViewController.m
//  Trip1
//
//  Created by lanou on 15/6/26.
//  Copyright © 2015年 kevin. All rights reserved.
//

#import "FoodMapViewController.h"
#import "NSString+URL.h"
#import "FoodModel.h"
#import "EnabelLeftOrRIght.h"
#import "MBProgressHUD.h"
#import <WebKit/WebKit.h>
#define XJHWidth ([[UIScreen mainScreen] bounds].size.width)
#define XJHHeight ([[UIScreen mainScreen] bounds].size.height)
@interface FoodMapViewController ()<WKNavigationDelegate>
@property (nonatomic, retain) WKWebView *wkFoodWedView;
@end

@implementation FoodMapViewController
-(void)dealloc
{
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];  //UIWebView才能使用
    [_wkFoodWedView removeFromSuperview];
    [_wkFoodWedView stopLoading];
    _wkFoodWedView.navigationDelegate = nil;
    [_wkFoodWedView release];
    _wkFoodWedView = nil;
    [_mapModel release];
    [super dealloc];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [EnabelLeftOrRIght setSideViewEnabelSwip:NO];

}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [EnabelLeftOrRIght setSideViewEnabelSwip:NO];
    
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wkFoodWedView = [[[WKWebView alloc]initWithFrame:CGRectMake(0, 0, XJHWidth, XJHHeight-64)]autorelease];
    _wkFoodWedView.navigationDelegate = self;
    [self getData];
    
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 25, 30, 30);
    [leftBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setImage:[UIImage imageNamed:@"back_white_colour@2x.png"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftBtn] autorelease];
    self.navigationItem.title = self.mapModel.name;
    
    // Do any additional setup after loading the view.
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getData
{
    NSDictionary *dic =  self.mapModel.location;
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",@"http://m.amap.com/navi/?dest=",dic[@"lng"],@",",dic[@"lat"],@"&destName=",self.mapModel.name,@"&hideRouteIcon=&key=5eece3e51c7180a1f01705369042c3a4"];
    NSString *new = [url URLEncodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:new]];
    [self.view addSubview:_wkFoodWedView];
    [_wkFoodWedView loadRequest:request];

}

#pragma -mark WKNavigationDelegate 代理方法
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    //小菊花控件
    //    [self p_setupProgressHud];
    [MBProgressHUD showHUDAddedTo:_wkFoodWedView animated:YES];
    //打开状态栏的小菊花
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    //开启一个 （没开启一个就要在结束的时候相对应的减少一个）
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [MBProgressHUD hideHUDForView:_wkFoodWedView animated:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

#pragma -mark 早期版本UIWebView

#pragma -mark UIWebViewDelegate 代理方法
- (void )webViewDidStartLoad:(UIWebView  *)webView
{

}
- (void )webViewDidFinishLoad:(UIWebView  *)webView
{
//    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存警告%s,%d",__FUNCTION__,__LINE__);
    
    // Dispose of any resources that can be recreated.
}



@end
