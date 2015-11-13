//
//  JxbDebugTool.m
//  JxbHttpProtocol
//
//  Created by Peter Jin @ https://github.com/JxbSir on 15/11/12.
//  Copyright (c) 2015年 Mail:i@Jxb.name. All rights reserved.
//

#import "JxbDebugTool.h"
#import "JxbHttpProtocol.h"
#import "JxbDebugVC.h"
#import "JxbCrashVC.h"
#import "JxbHttpVC.h"
#import "JxbCrashHelper.h"

@interface JxbDebugTool()
@property (nonatomic, strong) JxbDebugVC    *debugVC;
@property (nonatomic, strong) UIWindow      *debugWin;
@end

@implementation JxbDebugTool

+ (instancetype)shareInstance {
    static JxbDebugTool* tool;
    static dispatch_once_t  once;
    dispatch_once(&once, ^{
        tool = [[JxbDebugTool alloc] init];
    });
    return tool;
}

- (id)init {
    self = [super init];
    if (self) {
        self.mainColor = [UIColor redColor];
        self.debugWin = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    }
    return self;
}

- (void)enableDebugMode {
   [NSURLProtocol registerClass:[JxbHttpProtocol class]];
    [[JxbCrashHelper sharedInstance] install];
    
    __weak typeof (self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf showOnStatusBar];
    });
}

- (void)showOnStatusBar {
    self.debugWin.windowLevel = UIWindowLevelStatusBar+1;
    self.debugWin.hidden = NO;
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 35, 2, 40, 15)];
    btn.backgroundColor = self.mainColor;
    btn.layer.cornerRadius = 3;
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn setTitle:@"Debug" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showDebug) forControlEvents:UIControlEventTouchUpInside];
    [self.debugWin addSubview:btn];
}

- (void)showDebug {
    if (!self.debugVC) {
        self.debugVC = [[JxbDebugVC alloc] init];

        UINavigationController* nav1 = [[UINavigationController alloc] initWithRootViewController:[JxbHttpVC new]];
        UINavigationController* nav2 = [[UINavigationController alloc] initWithRootViewController:[JxbCrashVC new]];
        nav1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Http" image:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [nav1.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateNormal];
        [nav1.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:self.mainColor,NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateSelected];
        
        
        nav2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Crash" image:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [nav2.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateNormal];
        [nav2.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:self.mainColor,NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateSelected];
        
        // customise NavigationBar UI Effect
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],NSForegroundColorAttributeName:self.mainColor}];
        self.debugVC.viewControllers = @[nav1,nav2];
        [[[[UIApplication sharedApplication].delegate window] rootViewController] presentViewController:self.debugVC animated:YES completion:nil];
    }
    else {
        [self.debugVC dismissViewControllerAnimated:YES completion:nil];
        self.debugVC = nil;
    }
}

@end
