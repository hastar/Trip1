//
//  photoCell.m
//  Trip1
//
//  Created by lanou on 15/6/25.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "photoCell.h"
#import "BaseImageView.h"

@interface photoCell()<UIScrollViewDelegate>
//@property (nonatomic,retain) UIScrollView *scroll;
@property (nonatomic,retain,readwrite) UITapGestureRecognizer *doubleTap;
@end
@implementation photoCell

-(void)dealloc
{
    NSLog(@"photosCell release ok");
    [_doubleTap release];
    [_scrollView release];
    [_imgv release];
    [super dealloc];
}



-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor blackColor];
        self.scrollView = [[[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        
        self.scrollView.maximumZoomScale = 3;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.alwaysBounceVertical = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        
        self.scrollView.decelerationRate = 0.5;
        
        self.scrollView.delegate = self;
       
        [self.contentView addSubview:self.scrollView];

    
        BaseImageView *imageV = [[BaseImageView alloc] initWithFrame:[[UIScreen mainScreen]bounds] ] ;
        imageV.userInteractionEnabled = YES;
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        self.imgv = imageV;
        [self.scrollView addSubview:imageV];
        [imageV release];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [self.contentView addGestureRecognizer:doubleTap];
        [doubleTap release];
        
        self.doubleTap = doubleTap;
    
    }
    return self;
}

-(void)doubleTap:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:tap.view];
    
    
    //设置以点击的点为中心放大
    CGPoint pointInImgv = CGPointMake(touchPoint.x + self.scrollView.contentOffset.x, touchPoint.y + self.scrollView.contentOffset.y);
    CGFloat scaleX = pointInImgv.x / self.imgv.frame.size.width;
    CGFloat scaleY = pointInImgv.y / self.imgv.frame.size.height;
    
    
    if(self.scrollView.zoomScale == 1){
        
        CGPoint contectOffSet = CGPointMake(self.scrollView.frame.size.width * 2 * scaleX - [[UIScreen mainScreen] bounds].size.width / 2, self.scrollView.frame.size.height * 2 * scaleY - [[UIScreen mainScreen] bounds].size.height / 2);
        
        if (contectOffSet.x < 0) {
            contectOffSet.x = 0;
        }
        else if (contectOffSet.x > self.scrollView.frame.size.width * 2 - [[UIScreen mainScreen] bounds].size.width) {
            contectOffSet.x = self.scrollView.frame.size.width * 2 - [[UIScreen mainScreen] bounds].size.width;
        }
        
        if (contectOffSet.y < 0) {
            contectOffSet.y = 0;
        }
        else if (contectOffSet.y > self.scrollView.frame.size.height * 2 - [[UIScreen mainScreen] bounds].size.height) {
            contectOffSet.y = self.scrollView.frame.size.height * 2 - [[UIScreen mainScreen] bounds].size.height;
        }

        
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.zoomScale = 2;
            
            self.scrollView.contentOffset = contectOffSet;
            
            [self setScrollViewContentInset];
        }];
    }
    else{
        [UIView animateWithDuration:0.3 animations:^{
            [self backToNormalFrame];
        }];
        
    }
}


-(void)backToNormalFrame
{
    self.scrollView.zoomScale = 1;
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//    if (self.scrollView.zooming && scrollView.contentSize.width <= [[UIScreen mainScreen] bounds].size.width)
//    {
//        self.scrollView.contentOffset = CGPointMake((self.imgv.frame.size.width - self.scrollView.frame.size.width) /2,(self.imgv.frame.size.height - self.scrollView.frame.size.height) /2);
//        
//    }
    
    //缩放的时候设置在中心
    CGFloat verticalPadding = [self imageHeight] < self.scrollView.frame.size.height ? (self.scrollView.frame.size.height - [self imageHeight]) / 2 : 0;
    
    CGFloat horiPadding = [self imageWidth] < self.scrollView.frame.size.width ? (self.scrollView.frame.size.width - [self imageWidth]) / 2 : 0;
    
    
    self.scrollView.contentInset =UIEdgeInsetsMake(verticalPadding, horiPadding, verticalPadding, horiPadding);
   
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"ppppppppp%g",self.scrollView.contentOffset.y);
    if (([self imageHeight]) <= [[UIScreen mainScreen] bounds].size.height && scrollView.zooming == NO) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x,(self.imgv.frame.size.height - self.scrollView.frame.size.height) /2);
    }
    
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self setScrollViewContentInset];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgv;
}

-(void)setScrollViewContentInset
{
    if (([self imageHeight]) <= [[UIScreen mainScreen] bounds].size.height) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }
    else{
        self.scrollView.contentInset = UIEdgeInsetsMake(-(self.scrollView.contentSize.height - [self imageHeight])  * 0.5, 0, -(self.scrollView.contentSize.height - [self imageHeight])  * 0.5, 0);
    }
}
-(CGFloat)imageHeight
{
    CGFloat scaleHeight = self.imgv.image.size.height /self.imgv.image.size.width;
    CGFloat imageHeight = self.scrollView.frame.size.width * scaleHeight;
    return imageHeight * self.scrollView.zoomScale;
}
-(CGFloat)imageWidth
{
    
    return self.scrollView.frame.size.width * self.scrollView.zoomScale;
}

//-(void)scrollPinch:(UIPinchGestureRecognizer *)pinch
//{
//    if (pinch.state == UIGestureRecognizerStateEnded) {
//        [self performSelector:@selector(gestureEnd) withObject:nil];
//        return;
//    }
//    self.imgv.transform = CGAffineTransformScale(self.imgv.transform, pinch.scale, pinch.scale);
//    pinch.scale = 1;
//}

-(void)gestureEnd
{
    
    if (self.imgv.frame.size.width < ([[UIScreen mainScreen] bounds].size.width) * 0.5) {
        NSLog(@"%@",self.imgv);
        [UIView animateWithDuration:0.3 animations:^{
            self.imgv.frame = CGRectMake(0, 0, ([[UIScreen mainScreen] bounds].size.width) * 0.5, ([[UIScreen mainScreen] bounds].size.height) * 0.5);
            self.imgv.center = self.contentView.center;

        }];
    }
    else if(self.imgv.frame.size.width > ([[UIScreen mainScreen] bounds].size.width) * 2)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.imgv.frame = CGRectMake(0, 0, ([[UIScreen mainScreen] bounds].size.width) * 2, ([[UIScreen mainScreen] bounds].size.height) * 2);
            self.imgv.center = self.contentView.center;
            
        }];
    }
}
@end
