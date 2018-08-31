//
//  VideoTableViewController.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/30.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoTableViewController.h"
#import "VideoFile.h"
#import "VideoPlayViewController.h"
@interface VideoTableViewController ()
@property (nonatomic,strong)NSArray *recordFileList;
@end

@implementation VideoTableViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshDataSource];
    [self.navigationController.navigationBar setHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
}
- (void)refreshDataSource{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directryPath = [[VideoFile libCachePath] stringByAppendingPathComponent:VIDEO_FOLDER];
    _recordFileList =[fileManager contentsOfDirectoryAtPath:directryPath error:NULL];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordFileList.count;
}
- (NSDictionary *)getAudioInfo:(NSString *)fileName{
    NSString *filePath = [VideoFile VideoFilePath:fileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:filePath forKey:@"FilePath"];
    [dict setValue:fileName forKey:@"FileName"];
    long long fileSize = [VideoFile VideoGetFileSizeWithFilePath:filePath];
    [dict setValue:@(fileSize) forKey:@"FileSize"];
    return dict;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *fileName = self.recordFileList[indexPath.row];
    NSDictionary *dict = [self getAudioInfo:fileName];
    NSNumber *fileSize = dict[@"FileSize"];
    NSString *filePath = dict[@"FilePath"];
    if ([fileSize floatValue]/(1024.0*1024) > 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@( %.2fM )", fileName, [fileSize floatValue]/(1024.0*1024)];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@( %.2fkb)", fileName, [fileSize floatValue]/1024];
    }
    
    cell.detailTextLabel.text = filePath;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileName = self.recordFileList[indexPath.row];
    NSString *filePath = [VideoFile VideoFilePath:fileName];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    VideoPlayViewController *playVC = [[VideoPlayViewController alloc] init];
    playVC.videoUrl =  url;
     [self presentViewController:playVC animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
