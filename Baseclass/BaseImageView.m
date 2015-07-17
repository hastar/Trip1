//
//  BaseImageView.m
//  Trip1
//
//  Created by lanou on 15/6/25.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "BaseImageView.h"

@interface BaseImageView()
@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;
@property (nonatomic,assign) UIControlEvents event;
@property (nonatomic,retain) UITapGestureRecognizer *tap;
@property (nonatomic,retain) UIActivityIndicatorView *swit;
@end
@implementation BaseImageView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIActivityIndicatorView *swit = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        swit.center = CGPointMake(frame.size.width/2, frame.size.height/2);

        swit.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:swit];
        self.swit = swit;
        
        [swit release];
    }
    return self;
}

-(void)dealloc
{
    [_swit stopAnimating];
    [_swit release];
    [_tap release];
    [super dealloc];
}
-(void)setImage:(UIImage *)image
{
    if (image != nil) {


//        NSLog(@"%f   %f",image.size.width,image.size.height);

    }
    
    [super setImage:image];
}
-(void)indicatorStopAnimating
{
    [self.swit stopAnimating];
}
-(void)indicatorStartAnimating{
    [self.swit startAnimating];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_event == UIControlEventTouchUpInside) {
        [_target performSelector:_action withObject:self];
    }
}
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    _target = target;
    _action = action;
    _event = controlEvents;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
