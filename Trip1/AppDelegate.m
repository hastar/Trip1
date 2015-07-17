//
//  AppDelegate.m
//  Trip1
//
//  Created by lanou on 15/6/20.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "RootViewController.h"

#import "TravelViewController.h"

#import "RecommendViewController.h"
#import "YRSideViewController.h"
#import "BaseNavigationViewController.h"
#import "SceneViewController.h"
#import "FoodViewController.h"
#import "FoodListViewController.h"


@interface AppDelegate ()<UINavigationControllerDelegate>
{
    FoodListViewController *fd;
}
@end

@implementation AppDelegate
-(void)dealloc{
//    [_reachability release];
//    [_reachability stopNotifier];
    [_sideViewController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    TravelViewController *travel = [[[TravelViewController alloc] init]autorelease];
    
    RecommendViewController *recommend = [[[RecommendViewController alloc] init]autorelease];
    
    FoodViewController*food = [[[FoodViewController alloc]init]autorelease];
    
    BaseNavigationViewController *travelNavi = [[[BaseNavigationViewController alloc] initWithRootViewController:travel]autorelease];
    BaseNavigationViewController *recommendNavi = [[[BaseNavigationViewController alloc] initWithRootViewController:recommend]autorelease];;
    
    BaseNavigationViewController *foodNavi = [[[BaseNavigationViewController alloc]initWithRootViewController:food]autorelease];

    

    travelNavi.tabBarItem.title = @"游记";

    recommendNavi.tabBarItem.title = @"推荐";
    
    SceneViewController *scene = [[[SceneViewController alloc] init]autorelease];
    BaseNavigationViewController *sceneNavi = [[[BaseNavigationViewController alloc] initWithRootViewController:scene]autorelease];
    sceneNavi.tabBarItem.title = @"景点";

    foodNavi.tabBarItem.title = @"美食";
    travelNavi.tabBarItem.image = [UIImage imageNamed:@"youji@2x.png"];
    recommendNavi.tabBarItem.image = [UIImage imageNamed:@"tuijian@2x.png"];
    foodNavi.tabBarItem.image = [UIImage imageNamed:@"meishi@2x.png"];
    sceneNavi.tabBarItem.image = [UIImage imageNamed:@"gongjujingdian@2x.png"];

    
    
    
    RootViewController *root = [[[RootViewController alloc] init]autorelease];


    root.viewControllers = @[recommendNavi,travelNavi,sceneNavi,foodNavi];


    
    LeftViewController *left = [[[LeftViewController alloc] init]autorelease];
    RightViewController *right = [[[RightViewController alloc] init]autorelease];
    
    YRSideViewController *sideView = [[[YRSideViewController alloc] initWithNibName:nil bundle:nil]autorelease];
    sideView.leftViewController = left;
    sideView.rightViewController = right;
    sideView.rootViewController = root;

    self.sideViewController = sideView;
    
    self.window.rootViewController = sideView;
    
    //加载首页时间设置
    [NSThread sleepForTimeInterval:2.0];
    
//    //网络模块
//    // 监听网络状态发生改变的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
//    // 获得Reachability对象
//    self.reachability = [Reachability reachabilityForInternetConnection];
//    // 开始监控网络
//    [self.reachability startNotifier];
    

    return YES;
}
//- (void)networkStateChange
//{
//    //NSLog(@"网络状态改变了");
//    [self checkNetworkState];
//}
///**
// *  监测网络状态
// */
//- (void)checkNetworkState
//{
//    if ([HMNetworkTool isEnableWIFI]||[HMNetworkTool isEnable3G]) {
//        self.isReachable = YES;
//        NSLog(@"yes");
//    } else {
//        self.isReachable = NO;
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"网路链接异常,请检查网络" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        NSLog(@"no");
//    }
//}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
