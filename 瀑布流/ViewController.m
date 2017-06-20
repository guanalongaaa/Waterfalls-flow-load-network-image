//
//  ViewController.m
//  瀑布流
//
//  Created by iMac on 16/9/20.
//  Copyright © 2016年 zws. All rights reserved.
//

#import "ViewController.h"

#import "AFNetworking.h"
#import "CellModel.h"
#import "WSCollectionCell.h"
#import "WSLayout.h"

//加载图片查看器
#import "MSSBrowseDefine.h"


@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) WSLayout *wslayout;

@end

@implementation ViewController {

    NSMutableArray *modelArray;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"瀑布流";
    self.view.backgroundColor = [UIColor whiteColor];
    //http://image.baidu.com/channel/listjson?pn=0&rn=30&tag1=美女&tag2=全部&ie=utf8
    
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    /**
//     *  设置frame只能控制按钮的大小
//     */
//    btn.frame= CGRectMake(0, 0, 40, 44);
//    [btn setTitle:@"刷新" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    
//    self.navigationItem.rightBarButtonItem = btn_right;
    
    
    [self requsetDate];
    
}

//-(void)buttonClicked
//{
//    [self requsetDate];
//}


//请求数据
-(void)requsetDate
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlStr = [@"http://image.baidu.com/channel/listjson?pn=0&rn=100&tag1=美女&tag2=全部&ie=utf8" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSMutableArray *array = [responseObject[@"data"] mutableCopy];
        [array removeLastObject];
        
        modelArray = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            
            CellModel *model = [[CellModel alloc]init];
            model.imgURL = dic[@"image_url"];
            model.imgWidth = [dic[@"image_width"] floatValue];
            model.imgHeight = [dic[@"image_height"] floatValue];
            model.title = dic[@"abs"];
            
            [modelArray addObject:model];
        }
        
        [self _creatSubView];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}



- (void)_creatSubView {
    
    self.wslayout = [[WSLayout alloc] init];
    self.wslayout.lineNumber = 2; //列数
    self.wslayout.rowSpacing = 5; //行间距
    self.wslayout.lineSpacing = 5; //列间距
    self.wslayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    // 透明时用这个属性(保证collectionView 不会被遮挡, 也不会向下移)
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    // 不透明时用这个属性
    //self.extendedLayoutIncludesOpaqueBars = YES;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:self.wslayout];
    
    [self.collectionView registerClass:[WSCollectionCell class] forCellWithReuseIdentifier:@"collectionCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.collectionView];
    
    
    //返回每个cell的高   对应indexPath
    [self.wslayout computeIndexCellHeightWithWidthBlock:^CGFloat(NSIndexPath *indexPath, CGFloat width) {
        
        CellModel *model = modelArray[indexPath.row];
        CGFloat oldWidth = model.imgWidth;
        CGFloat oldHeight = model.imgHeight;
        
        CGFloat newWidth = width;
        CGFloat newHeigth = oldHeight*newWidth / oldWidth;
        return newHeigth;
    }];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WSCollectionCell *cell = (WSCollectionCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    cell.model = modelArray[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSMutableArray *browseItemArray = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < [modelArray count]; i++)
    {
        CellModel * model = modelArray[i];
        NSString *imgURL = model.imgURL;
        
        MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
        browseItem.bigImageUrl = imgURL;// 加载网络图片大图地址
//        browseItem.smallImageView = imageView;// 小图
        [browseItemArray addObject:browseItem];
    }
    
    MSSBrowseNetworkViewController *bvc = [[MSSBrowseNetworkViewController alloc]initWithBrowseItemArray:browseItemArray currentIndex:indexPath.row];
        bvc.isEqualRatio = NO;// 大图小图不等比时需要设置这个属性（建议等比）
    [bvc showBrowseViewController];

    
    NSLog(@"选中了第%ld块第%ld个item",indexPath.section,indexPath.row);
}


@end
