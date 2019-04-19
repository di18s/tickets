//
//  ProgressView.h
//  air_tickets
//
//  Created by Дмитрий on 12/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressView : UIView

+(instancetype)sharedInstance;
-(void)show:(void(^)(void))completion;
-(void)dismiss:(void(^)(void))completion;

@end

