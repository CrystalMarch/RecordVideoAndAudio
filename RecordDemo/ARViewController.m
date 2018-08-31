//
//  ViewController.h
//  AR的录屏demo(有声音)
//
//  Created by LJP on 13/12/17.
//  Copyright © 2017年 poco. All rights reserved.
//



#import "ARViewController.h"
#import "Video.h"
#import "VideoPlayViewController.h"
#import "RecordProgressView.h"

//遵循代理
@interface ARViewController () <ARSessionDelegate,ARSCNViewDelegate,VideoDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong) RecordProgressView *progressView;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UILabel *timelabel;
@end

@implementation ARViewController : UIViewController

#pragma mark ======================================= 生命周期 =======================================

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ARWorldTrackingConfiguration * configuration = [[ARWorldTrackingConfiguration alloc]init];
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sceneView.session pause];
}


#pragma mark ======================================= 私有方法 =======================================

- (void)initData {
    [Video shareVideo].arVideoRecord.delegate = self;
}

- (void)initUI {
    
    
    self.progressView = [[RecordProgressView alloc] initWithFrame:CGRectMake((kScreenWidth - 62)/2, kScreenHeight - 32 - 62, 62, 62)];
    self.progressView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.progressView];
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    self.recordBtn.frame = CGRectMake(5, 5, 52, 52);
    self.recordBtn.backgroundColor = [UIColor redColor];
    self.recordBtn.layer.cornerRadius = 26;
    self.recordBtn.layer.masksToBounds = YES;
    [self.progressView addSubview:self.recordBtn];
    [self.progressView resetProgress];
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.5];
    self.topView.frame = CGRectMake(0, 0, kScreenHeight, 44);
    [self.view addSubview:self.topView];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(15, 14, 16, 16);
    [self.cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.cancelBtn];
    
    self.timeView = [[UIView alloc] init];
    self.timeView.hidden = YES;
    self.timeView.frame = CGRectMake((kScreenWidth - 100)/2, 16, 100, 34);
    self.timeView.backgroundColor = [UIColor colorWithRGB:0x242424 alpha:0.7];
    self.timeView.layer.cornerRadius = 4;
    self.timeView.layer.masksToBounds = YES;
    [self.view addSubview:self.timeView];
    
    
    UIView *redPoint = [[UIView alloc] init];
    redPoint.frame = CGRectMake(0, 0, 6, 6);
    redPoint.layer.cornerRadius = 3;
    redPoint.layer.masksToBounds = YES;
    redPoint.center = CGPointMake(25, 17);
    redPoint.backgroundColor = [UIColor redColor];
    [self.timeView addSubview:redPoint];
    
    self.timelabel =[[UILabel alloc] init];
    self.timelabel.font = [UIFont systemFontOfSize:13];
    self.timelabel.textColor = [UIColor whiteColor];
    self.timelabel.frame = CGRectMake(40, 8, 40, 28);
    [self.timeView addSubview:self.timelabel];
    
    
    [self initSceneView];
    
}

//点击按钮
-(void)clicked:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [[Video shareVideo].arVideoRecord startRecord];
    }else {
        [[Video shareVideo].arVideoRecord stopRecord];
    }
}
- (void)changeToRecordStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(28, 28);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 4;
        self.recordBtn.center = center;
    }];
}
- (void)updateViewWithRecording
{
    self.timeView.hidden = NO;
    self.topView.hidden = YES;
    [self changeToRecordStyle];
}

- (void)updateViewWithStop
{
    self.timeView.hidden = YES;
    self.topView.hidden = NO;
    [self changeToStopStyle];
    
}
- (void)changeToStopStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(52, 52);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 26;
        self.recordBtn.center = center;
    }];
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)initSceneView {
    
    self.sceneView.showsStatistics = NO;
    
    SCNScene *scene = [SCNScene new];
    
    self.sceneView.scene = scene;
    self.sceneView.session.delegate = self;
    self.sceneView.delegate = self;
    
    SCNScene * idleScene = [SCNScene sceneNamed:@"art.scnassets/wolf.dae"];
    
    SCNNode * node = [[SCNNode alloc]init];
    for (SCNNode * child in idleScene.rootNode.childNodes) {
        [node addChildNode:child];
    }
    
    node.position = SCNVector3Make(0, -0.8, -1.6); //3D模型的位置
    node.scale    = SCNVector3Make(2, 2, 2); //模型的大小
    
    [self.sceneView.scene.rootNode addChildNode:node];
    
    [Video shareVideo].arVideoRecord.renderer.scene = self.sceneView.scene;
    [Video shareVideo].arVideoRecord.needToSavedPhotosAlbum = YES;
    [Video shareVideo].arVideoRecord.needCompress = YES;
    
}
- (void)updateRecordState:(RecordState)recordState
{
    if (recordState == RecordStateInit) {
        [self updateViewWithStop];
        [self.progressView resetProgress];
    } else if (recordState == RecordStateRecording) {
        [self updateViewWithRecording];
    } else  if (recordState == RecordStateFinish) {
        [self updateViewWithStop];
        NSLog(@"video finish");
    }else if(recordState == RecordStatecompressed){
        NSLog(@"video compressed ");
    }
}

- (void)endMerge:(NSURL *)url {
    VideoPlayViewController *playVC = [[VideoPlayViewController alloc] init];
    playVC.videoUrl =  url;
    [self presentViewController:playVC animated:YES completion:nil];

}
- (void)updateRecordingProgress:(CGFloat)progress
{
    [self.progressView updateProgressWithValue:progress];
    self.timelabel.text = [self changeToVideotime:progress * VIDEO_RECORD_MAX_TIME];
    [self.timelabel sizeToFit];
}

- (NSString *)changeToVideotime:(CGFloat)videocurrent {
    
    return [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    
}


@end

