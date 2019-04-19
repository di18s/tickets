//
//  ProgressView.m
//  air_tickets
//
//  Created by Дмитрий on 12/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView()

@end

@implementation ProgressView {
    BOOL isActive;
}

+(instancetype)sharedInstance {
    static ProgressView* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ProgressView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        [instance setup];
    });
    return instance;
}

-(void)setup{
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"cloud"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.clipsToBounds = YES;
    [self addSubview:backgroundImageView];
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.bounds;
    [self addSubview:effectView];
    
    [self createPlanes];
}
-(void)createPlanes{
    
    for (int i = 1; i < 6; i++) {
        UIImageView* plane = [[UIImageView alloc] initWithFrame:CGRectMake(-50, 100 + ((float)i * 50), 50, 50)];
        plane.tag = i;
        plane.image = [UIImage imageNamed:@"plane"];
        [self addSubview:plane];
    }
}

-(void)startAnimating:(NSInteger)planeId{
    if (!isActive) return;
    if (planeId >= 6) planeId = 1;
    UIImageView* plane = [self viewWithTag:planeId];
    if (plane) {
        [UIView animateWithDuration:1 animations:^{
            plane.frame = CGRectMake(self.bounds.size.width + 50, plane.frame.origin.y, 50, 50);
        } completion:^(BOOL finished) {
            plane.frame = CGRectMake(-50, plane.frame.origin.y, 50, 50);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startAnimating:planeId + 1];
        });
    }
}
-(void)show:(void (^)(void))completion{
    self.alpha = 0;
    isActive = YES;
    [self startAnimating:1];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        completion();
    }];
}

-(void)dismiss:(void (^)(void))completion{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self->isActive = NO;
        if (completion) {
            completion();
        }
    }];
}

@end
