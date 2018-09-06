//
//  AudioViewController.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioRecordButton.h"
#import "AudioPlayView.h"
@interface AudioViewController ()<UITableViewDelegate,UITableViewDataSource,AudioRecordButtonDelegate>
@property (weak, nonatomic) IBOutlet AudioRecordButton *recordButton;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) NSArray *recordFileList;
@property (nonatomic,strong) NSMutableArray *playViews;
@property (nonatomic,strong) AudioPlayView *lastPlayView;
@end

@implementation AudioViewController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[Audio shareAudio].audioPlay playerPause];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _playViews = [[NSMutableArray alloc] init];
    [self initSubviews];
    [self refreshDataSource];
}
- (void)initSubviews{
    _recordButton.delegate = self;
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _mainTableView.rowHeight = 50;
    [_mainTableView setSeparatorColor:[UIColor clearColor]];
}
- (void)refreshDataSource{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directryPath = [[AudioFile libCachePath] stringByAppendingPathComponent:AUDIO_FOLDER];
    _recordFileList =[fileManager contentsOfDirectoryAtPath:directryPath error:NULL];
    //数组排序
    _recordFileList = [_recordFileList sortedArrayUsingSelector:@selector(compare:)];
    [self.playViews removeAllObjects];
    [_mainTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *fileName = self.recordFileList[indexPath.row];
    NSString *filePath = [AudioFile AudioDefaultFilePath:fileName];
  
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    AudioPlayView *voiceButton;
    if (indexPath.row >= self.playViews.count || self.playViews.count == 0) {
        voiceButton = [[AudioPlayView alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
        voiceButton.filePath = filePath;
        voiceButton.isShowLeftImg = YES;
        if (![self.playViews containsObject:voiceButton]) {
           [self.playViews addObject:voiceButton];
        }
        if (indexPath.row % 2 == 0){
            voiceButton.isInvert = YES;
            voiceButton.frame =CGRectMake(kScreenWidth-210, 10, 200, 30);
        }
    }else{
        voiceButton = [self.playViews objectAtIndex:indexPath.row];
    }
    [cell.contentView addSubview:voiceButton];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recordFileList.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - audio record delegate
-(void)endRecord{
    [self refreshDataSource];
}


@end
