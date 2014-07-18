//
//  CustomNavigationController.h
//  JiaDing_3D
//
//  Created by mark on 14-7-17.
//  Copyright (c) 2014年 mark. All rights reserved.
//
/*
 功能包括，导航条的背景图片定制，返回按钮和右边按钮的定制。统一管理每个子ViewController的导航条效果.
 */
@interface CustomNavigationController : UINavigationController
- (UIBarButtonItem *)navBarItemWithTarget:(id)target
                                   action:(SEL)action
                                imageName:(NSString*)imgName;
@end
