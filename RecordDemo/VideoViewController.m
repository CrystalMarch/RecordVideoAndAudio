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
    _videoView  =[[VideoView alloc] initWithFMVideoViewType:TypeFullScreen];
    _videoView.delegate = self;
    [self.view addSubview:_videoView];
    self.view.backgroundColor = [UIColor blackColor];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [_videoView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    VideoPlayViewController *playVC = [[VideoPlayViewController alloc] init];
    playVC.videoUrl =  videoUrl;
    [self presentViewController:playVC animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
