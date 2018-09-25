//
//  VideoViewController.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/30.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoView.h"
#import "VideoPlayViewController.h"
@interface VideoViewController ()<VideoViewDelegate>
@property(nonatomic,strong)VideoView *videoView;
@end

@implementation VideoViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    if (_videoView) {
        [_videoView reset];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoView  =[[VideoView alloc] initWithFMVideoViewType:TypeFullScreen];
    _videoView.delegate = self;
    _videoView.needCompress = YES;
    _videoView.needToSavedPhotosAlbum = YES;
    [self.view addSubview:_videoView];
    self.view.backgroundColor = [UIColor blackColor];
    [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)dismissVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)recordFinishWithvideoUrl:(NSURL *)videoUrl
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
