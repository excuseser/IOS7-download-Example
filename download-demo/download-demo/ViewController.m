//
//  ViewController.m
//  download-demo
//
//  Created by kan xu on 15/11/13.
//  Copyright © 2015年 kan xu. All rights reserved.
//

#import "ViewController.h"
#import "downloadCell.h"

#import "FLDownloader.h"


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>{
    
    NSMutableArray *downloads;
    NSArray *downUrl;
    NSInteger currentIndex;
    
}

@property (nonatomic, strong) IBOutlet UITableView *listTable;
@property (nonatomic, strong) NSString *url;

-(IBAction)addNewDownload:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    downUrl = @[@"http://down1.cndzq.com/demo/yamaha_p115/voicedemo/grandpiano_demo_p115.mp3",
                @"http://down1.cndzq.com/demo/yamaha_p115/voicedemo/brightgrand_demo_p115.mp3",
                @"http://down1.cndzq.com/demo/yamaha_p115/voicedemo/mellowgrand_demo_p115.mp3",
                @"http://down1.cndzq.com/demo/yamaha_p115/grandpiano_p115.mp3",
                @"http://down1.cndzq.com/demo/yamaha_p115/voicedemo/DX_epiano_demo_p115.mp3",
                @"http://down1.cndzq.com/demo/yamaha_p115/voicedemo/stage_epiano_demo_p115.mp3",
                @"http://down1.cndzq.com/demo/yamaha_p115/voicedemo/vintage_epiano_demo_p115.mp3"];
    
    [FLDownloader sharedDownloader];
    
    [self downloadEnd];
    
    downloads = [[[[FLDownloader sharedDownloader] tasks] allValues] mutableCopy];
    for (FLDownloadTask *download in downloads) {
        [self doDown:download];
        //[download resumeOrPause]; 开始状态为暂停
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Action

- (void)addNewDownload:(id)sender{
    _url=downUrl[currentIndex];
    [self newDownload];
    currentIndex++;
}


#pragma mark -  table-代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"downloadCell";
    downloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    FLDownloadTask *download =  [downloads objectAtIndex:indexPath.row];
    cell.nameLabel.text = download.fileName;
    cell.stateLabel.text = [self stateType:[download state]];
    // 提供了download.info[@"ext"] 可以存储扩展信息;
    return cell;    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FLDownloadTask *download =  [downloads objectAtIndex:indexPath.row];
    [download resumeOrPause];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger row = [indexPath row];
    
    downloadCell *cell = (downloadCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    cell.stateLabel.text = [self stateType:[download state]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FLDownloadTask *download =  [downloads objectAtIndex:indexPath.row];
        [download cancel];
        
        [downloads removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - method
-(void)newDownload{
    if (_url.length>0) {
        //new download
        NSURL *url = [NSURL URLWithString:_url];
        
        FLDownloadTask *download = [FLDownloadTask downloadTaskForURL:url];
        [download start];
        
        _listTable.hidden = NO;
        
        downloads = [[[[FLDownloader sharedDownloader] tasks] allValues] mutableCopy];
        [self doDown:download];
        [_listTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (NSString *)stateType:(int)state{
    switch (state) {
        case 0:
            return @"下载中";
            break;
        case 1:
            return @"已暂停";
            break;
        case 2:
            return @"已取消";
            break;
        case 3:
            return @"已完成";
            break;
        default:
            return @"无状态";
            break;
    }
}

- (NSString*)formatByteCount:(long long)size {
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

-(void)doDown:(FLDownloadTask *)download{
    __block FLDownloadTask *weakdownload = download;
    [download setCompletionBlock:^(BOOL success, NSError *error, NSString *fileName) {
        if (!success) {
            NSLog(@"download err");
            [weakdownload cancel];
            [self downloadEnd];
            return;
        }
        
        NSInteger index = [downloads indexOfObject:weakdownload];
        downloadCell *cell = (downloadCell *)[_listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.stateLabel.text = @"下载结束";
            NSLog(@"下载结束");
        });
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *dir = [[self mp3Dir] stringByAppendingPathComponent:weakdownload.fileName];
        if ([fileManager fileExistsAtPath:dir]) {
            [fileManager removeItemAtPath:dir error:&error];
        }
        BOOL remove = [fileManager moveItemAtPath:fileName toPath:dir error:&error];
        if (remove) {
            NSLog(@"存取成功");
            [fileManager removeItemAtPath:fileName error:nil];
        }
        
        [self downloadEnd];
        
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            });
        });
         */
        
    }];
    
    [download setProgressBlock:^(NSURL *url, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        NSLog(@"Progress: %.2f", progress);
        NSString *downloadedkb =[self formatByteCount:totalBytesWritten];
        NSString *totalkb = [self formatByteCount:totalBytesExpectedToWrite];
        
        NSInteger index = [downloads indexOfObject:weakdownload];        
        downloadCell *cell = (downloadCell *)[_listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.fileProgress.progress = progress;
        cell.progressLabel.text = [NSString stringWithFormat:@"%.@/%@", downloadedkb, totalkb];
        cell.stateLabel.text = [self stateType:[weakdownload state]];
    }];
}


- (void)downloadEnd{
    //下载并且处理结束要退回到主画面
    downloads = [[[[FLDownloader sharedDownloader] tasks] allValues] mutableCopy];
    if (downloads.count>0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_listTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            _listTable.hidden=YES;
            //[self.navigationController popViewControllerAnimated:YES];
        });
    }
}


-(NSString *)mp3Dir{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES) lastObject];
    dir = [dir stringByAppendingPathComponent:@"mp3"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir]) {
        BOOL directoriesCreated = [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        if (!directoriesCreated) {
            NSLog(@"no xiaolu-mp3 dir");
        }
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dir isDirectory:YES]];
    }
    return dir;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}



@end
