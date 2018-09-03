//
//  AudioViewController.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioRecordView.h"
@interface AudioViewController ()<UITableViewDelegate,UITableViewDataSource,AudioDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong)NSArray *recordFileList;
@end

@implementation AudioViewController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[Audio shareAudio].audioPlay playerPause];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self actionForButton];
    [self initSubviews];
    [self refreshDataSource];
}
- (void)initSubviews{
   
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _mainTableView.rowHeight = 50;
}
- (void)actionForButton{
    [_recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [_recordButton addTarget:self action:@selector(recordButtonTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
    [_recordButton addTarget:self action:@selector(recordButtonTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
}
- (void)recordButtonTouchDown{
    [[AudioRecordView share] startRecord];
}
- (void)recordButtonTouchUpInside{
    [[AudioRecordView share] finishedRecord];
    [self refreshDataSource];
}
- (void)recordButtonTouchUpOutside{
    [[AudioRecordView share] cancelRecord];
}

- (void)recordButtonTouchDragExit{
    [[AudioRecordView share] cancelRecordWarning];
}
- (void)recordButtonTouchDragEnter{
    [[AudioRecordView share] resetDisplay];
}

- (void)refreshDataSource{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directryPath = [[AudioFile libCachePath] stringByAppendingPathComponent:AUDIO_FOLDER];
    _recordFileList =[fileManager contentsOfDirectoryAtPath:directryPath error:NULL];
    [_mainTableView reloadData];
}
- (NSDictionary *)getAudioInfo:(NSString *)fileName{
    NSString *filePath = [AudioFile AudioDefaultFilePath:fileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:filePath forKey:@"FilePath"];
    [dict setValue:fileName forKey:@"FileName"];
    long long fileSize = [AudioFile AudioGetFileSizeWithFilePath:filePath];
    [dict setValue:@(fileSize) forKey:@"FileSize"];
    NSTimeInterval fileTime = [[Audio shareAudio].audioRecord recorderDurationWithFilePath:filePath];
    [dict setValue:@(fileTime) forKey:@"FileTime"];
    return dict;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *fileName = self.recordFileList[indexPath.row];
    NSDictionary *dict = [self getAudioInfo:fileName];
    NSNumber *fileSize = dict[@"FileSize"];
    NSString *filePath = dict[@"FilePath"];
    NSNumber *fileTime = dict[@"FileTime"];
    if ([fileSize floatValue]/(1024.0*1024) > 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@( %.2fM  %.2fs)", fileName, [fileSize floatValue]/(1024.0*1024),fileTime.doubleValue];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@( %.2fkb %.2fs)", fileName, [fileSize floatValue]/1024,fileTime.doubleValue];
    }
    
    cell.detailTextLabel.text = filePath;
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recordFileList.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *fileName = self.recordFileList[indexPath.row];
    NSDictionary *dict = [self getAudioInfo:fileName];
    NSString *filePath = dict[@"FilePath"];
    [Audio shareAudio].audioPlay.delegate = self;
    [[Audio shareAudio].audioPlay playerStart:filePath complete:^(BOOL isFailed) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }]];
        [self presentViewController:alert animated:YES completion:NULL];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
