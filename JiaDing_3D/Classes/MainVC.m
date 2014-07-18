//
//  MainVC.m
//  JiaDing_3D
//
//  Created by mark on 14-7-17.
//  Copyright (c) 2014年 mark. All rights reserved.
//

#import "MainVC.h"
#import "VenueTable.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>  //@strongify/@weakify

@interface MainVC ()
//用于显示内容的，TODO，建立nib文件的关联连接。
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewA;
@property (weak, nonatomic) IBOutlet VenueTable *tableViewB;

@property (weak, nonatomic) IBOutlet UIButton *changguan_btn;
@property (weak, nonatomic) IBOutlet UIButton *zhanpin_btn;
@property (weak, nonatomic) IBOutlet UIButton *collection_btn;
@property (weak, nonatomic) IBOutlet UIImageView *topBtnImg;


@property (weak, nonatomic) IBOutlet UIButton *personal;

//英文翻译比较麻烦，都是些少见的词汇，所以用中文拼音，一般情况下用英文。
@property (weak, nonatomic) IBOutlet UIButton *ciqi_btn;
@property (weak, nonatomic) IBOutlet UIButton *yuqi_btn;
@property (weak, nonatomic) IBOutlet UIButton *huihua_btn;
@property (weak, nonatomic) IBOutlet UIButton *wenhuajiading_btn;
@property (weak, nonatomic) IBOutlet UIButton *zhuke_btn;
@property (weak, nonatomic) IBOutlet UIButton *shufa_btn;
@property (weak, nonatomic) IBOutlet UIButton *qingtong_btn;
@property (weak, nonatomic) IBOutlet UIButton *keju_btn;

@end

@implementation MainVC

//设置导航栏隐藏
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)rac_settings{
    @weakify(self);
    //使用这句话之后只需要改变scrollViewB是否隐藏就可以了，另一个会自动跟着变成相反的状态
    RAC(self.scrollViewA, hidden) =
    [RACObserve(self.tableViewB,hidden) map:^id(NSNumber * value){
        @strongify(self);
        //不通的按钮点击会改变hidden属性，然后跟着改变顶部图片的内容。
        if(value.boolValue == YES)
            self.topBtnImg.image = [UIImage imageNamed:@"tt_场馆.png"];
        else
            self.topBtnImg.image = [UIImage imageNamed:@"tt_展品.png"];
        return @(!value.boolValue);
    }];
    
    //两个按钮的点击切换不同的内容。
    [[self.changguan_btn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
        @strongify(self);
        self.tableViewB.hidden = YES;
    }];
    [[self.zhanpin_btn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
        @strongify(self);
        self.tableViewB.hidden = NO;
    }];
    
    [[self.collection_btn rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(id x) {
        @strongify(self);
        UIViewController *vc = [[UIViewController alloc] init];
        [self.navigationController pushViewController:vc animated:NO];
        //设置标题和背景
        UILabel *lb  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        lb.font      = [UIFont systemFontOfSize:15];
        lb.textColor = [UIColor blueColor];
        lb.text      = @"收藏";
        vc.navigationItem.titleView = lb;
        
    }];
    //TODO，修改为对应的UIViewController.也有可能是同一个ViewController，但是参数不同
    UIViewController *ciqi_vc   = [[UIViewController alloc] init];
    UIViewController *yuqi_vc   = [[UIViewController alloc] init];
    UIViewController *huihua_vc = [[UIViewController alloc] init];
    UIViewController *wenhuajiading_vc = [[UIViewController alloc] init];
    UIViewController *zhuke_vc  = [[UIViewController alloc] init];
    UIViewController *shufa_vc  = [[UIViewController alloc] init];
    UIViewController *qingtong_vc = [[UIViewController alloc] init];
    UIViewController *keju_vc   = [[UIViewController alloc] init];
    
    NSDictionary *btns2actions  =
    @{@"瓷器":@[self.ciqi_btn, ciqi_vc],
      @"玉器":@[self.yuqi_btn, yuqi_vc],
      @"绘画":@[self.huihua_btn, huihua_vc],
      @"文化嘉定":@[self.wenhuajiading_btn, wenhuajiading_vc],
      @"竹刻":@[self.zhuke_btn, zhuke_vc],
      @"书法":@[self.shufa_btn, shufa_vc],
      @"青铜":@[self.qingtong_btn, qingtong_vc],
      @"科举":@[self.keju_btn, keju_vc]};
    //定制每个button事件跳转的视图控制器。
    for(NSString *key in btns2actions){
        NSArray* array       = btns2actions[key];
        UIButton *btn        = array[0];
        UIViewController *vc = array[1];
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {
             @strongify(self);
             [self.navigationController pushViewController:vc animated:NO];
         }];
//        btn.backgroundColor = [UIColor clearColor];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self rac_settings];
    
    self.mainView.backgroundColor  = [UIColor clearColor];
    
    if(!IS_IPHONE5){
        self.scrollViewA.contentSize   = CGSizeMake(0, 600);
        self.tableViewB.frame = CGRectMake(self.tableViewB.frame.origin.x,
                                           self.tableViewB.frame.origin.y,
                                           self.tableViewB.frame.size.width,
                                           400);
    }
    self.tableViewB.navigationController = self.navigationController;
    self.tableViewB.delegate        = self.tableViewB;
    self.tableViewB.dataSource      = self.tableViewB;
    self.tableViewB.backgroundColor = [UIColor clearColor];
    [self.tableViewB setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableViewB setupData];
    //A和B是隐藏显示关系相反，RAC中观察了一个，另一个就不用跟着改了。
    self.tableViewB.hidden = YES;
}


@end
