//
//  BottomSheetViewController.m
//  navi-lite
//
//  Created by Phineas.Huang on 2020/5/29.
//  Copyright © 2020 Garmin. All rights reserved.
//

#import "BottomSheetViewController.h"

typedef enum Director {
    up,
    down,
}Director;

typedef enum State {
    partial,  //底部
    expanded, //中间
    full   //顶部
}State;

@interface BottomSheetViewController ()

@property (assign, nonatomic) State lastStatus;

@end

@implementation BottomSheetViewController

static CGFloat fullViewYPosition = 0;
static CGFloat partialViewYPosition = 0;
static CGFloat expandedViewYPosition = 0;

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupData];
    [self setupGestureEvent];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.6 animations:^{
        [weakSelf moveView:weakSelf.lastStatus];
    }];
}

#pragma mark -

- (void)setupData {
    fullViewYPosition = 100; //这里离最上方的距离（顶部）
    partialViewYPosition = [UIScreen mainScreen].bounds.size.height - 88;   //这里是最后停顿的位置（底部）
    expandedViewYPosition = [UIScreen mainScreen].bounds.size.height - 88 - 500; //这里是中间停顿，默认的初始位置

    self.lastStatus = full;
    
    //这里开始布局view
    UIView *backView = [[UIView alloc] init];
    backView.frame = CGRectMake(0, 88, self.view.frame.size.width, 100);
    backView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:backView];
    //
    UILabel *btLabel = [[UILabel alloc] init];
    btLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    btLabel.font = [UIFont fontWithName:@"" size:15];
    btLabel.text = @"这里展示内容";
    btLabel.textAlignment = NSTextAlignmentCenter;
    btLabel.textColor = [UIColor whiteColor];
    [backView addSubview:btLabel];
    
}

#pragma mark -

- (void)setupGestureEvent {
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.view addGestureRecognizer:gesture];
    [self roundViews];
}

- (void)moveView:(State)state {
    CGFloat yPosition = fullViewYPosition;
    if (state == partial) {
        yPosition = partialViewYPosition;

    } else if (state == expanded) {
        yPosition = expandedViewYPosition;
    }

    const CGFloat width = self.view.frame.size.width;
    const CGFloat height = self.view.frame.size.height;
    CGRect rect = CGRectMake(0 , yPosition, width, height);

    self.view.frame = rect;
}

- (void)moveViewWithGesture:(UIPanGestureRecognizer *)recognizer {
    const CGPoint translation = [recognizer translationInView:self.view];
    const CGFloat minY = self.view.frame.origin.y;

    if ((minY + translation.y >= fullViewYPosition) &&
        (minY + translation.y <= partialViewYPosition)) {
        const CGFloat width = self.view.frame.size.width;
        const CGFloat height = self.view.frame.size.height;
        const CGRect rect = CGRectMake(0 , minY + translation.y, width, height);
        self.view.frame = rect;
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
}

- (void)roundViews {
    self.view.layer.cornerRadius = 10;
    self.view.clipsToBounds = YES;
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    [self moveViewWithGesture:recognizer];

    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }

    __weak __typeof(self)weakSelf = self;
    [UIView animateKeyframesWithDuration:0.2
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
        const Director director = [recognizer velocityInView:weakSelf.view].y >= 0 ? down: up;
        State state = weakSelf.lastStatus;

        if (weakSelf.lastStatus == partial && director == up) {
            state = expanded;

        } else if (weakSelf.lastStatus == expanded && director == up) {
            state = full;
        }

        if (weakSelf.lastStatus == full && director == down) {
            state = expanded;

        } else if (weakSelf.lastStatus == expanded && director == down) {
            state = partial;
        }

        // handle
        if (recognizer.view) {
            if (state == expanded) {
                CGFloat endLocation = recognizer.view.frame.origin.y;
                if (endLocation > expandedViewYPosition &&
                    director == down) {
                    state = partial;

                } else if (endLocation < expandedViewYPosition &&
                           director == up) {
                    state = full;
                }

            } else if (state == partial &&
                weakSelf.lastStatus == partial) {
                CGFloat endLocation = recognizer.view.frame.origin.y;
                if (endLocation < expandedViewYPosition) {
                    state = expanded;
                }
            }
        }

        weakSelf.lastStatus = state;
        [weakSelf moveView:state];
                              } completion:^(BOOL finished) {
                                  // block fires when animaiton has finished
    }];
}

#pragma mark -

@end
