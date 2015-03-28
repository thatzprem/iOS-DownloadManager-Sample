//
//  ViewController.m
//  BackgroundFetchTest
//
//  Created by Prem kumar on 20/03/14.
//  Copyright (c) 2014 happiestminds. All rights reserved.
//

#import "HomeVC.h"
#import "DownloadCompleteNotification.h"
#import "FileDownloadManager.h"
#import "DownloadedListTVC.h"
#import "Utilities.h"

#define FETCH_URLSTRING @"http://images.apple.com/v/iphone-5s/gallery/a/images/download/photo_3.jpg" //3 MB Image file
//#define FETCH_URLSTRING @"http://10.20.26.239/test.json"
//#define FETCH_URLSTRING @"http://10.20.27.53/crystalski/test180MB.json" //180 MB Json file

//#define FETCH_URLSTRING @"http://tibcoproductfeb.cloudapp.net:7778/bulk" //Tibco file

@interface HomeVC ()

@property (nonatomic,strong) NSURL *localFileURL;
@property (weak, nonatomic) IBOutlet UIImageView *displayImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *tasksInQueueCountLabel;
@property (nonatomic,strong) FileDownloadManager *fileDownloadManager;

@end

@implementation HomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //Setup FileDownload manager
    self.fileDownloadManager = [[FileDownloadManager alloc] init];
    self.fileDownloadManager.broadcastPendingDownloads = YES;
}
- (IBAction)clearDocumentsDirectory:(id)sender {
    [Utilities clearDocmentsDirectory];
}
- (IBAction)copyLocalJsonToDD:(id)sender {
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"citylots" ofType:@"json"];
    [Utilities copyFileToDocumentsFromURL:[NSURL URLWithString:resourcePath] withFileName:@"CopiedJson.json"];
}

- (IBAction)cancelDownload:(id)sender
{
    [self.fileDownloadManager cancelDownload];
}

- (IBAction)resumeDownload:(id)sender
{
    [self.fileDownloadManager resumeDownload];
}
- (IBAction)startDownloadButtonPressed:(id)sender
{
    [self.fileDownloadManager broadcastPendingDownloadTasksCount];
    [self.spinner startAnimating];

    //Create requestURL
    NSMutableArray * downloadUrlsArray = [[NSMutableArray alloc]init];
    int count = 0;
    do {
        NSURL *downloadURL = [NSURL URLWithString:FETCH_URLSTRING];
        [downloadUrlsArray addObject:downloadURL];
        count++;
    }while( count < 1 );
//    [self.fileDownloadManager downloadUsingDelegates:downloadUrlsArray];
    
    [self.fileDownloadManager downloadUsingBlock:[NSURL URLWithString:FETCH_URLSTRING]];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DownloadCompleteNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *downloadQueueCount = note.userInfo[DownloadCompleteNotificationContext];
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"Tasks in the queue: %d",[downloadQueueCount intValue]);
            if (![downloadQueueCount intValue]) {
                [self.spinner stopAnimating];
            }
            self.tasksInQueueCountLabel.text = [NSString stringWithFormat:@"%d",[downloadQueueCount intValue]];
        });
    }];
}

- (void)prepareViewController:(id)viewController
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    if ([viewController isKindOfClass:[DownloadedListTVC class]]) {
        DownloadedListTVC *downloadedListTVC = (DownloadedListTVC *)viewController;
        downloadedListTVC.downloadedFileNamesArray = [Utilities getFilesFromDocumentsDirectory];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = nil;
        [self prepareViewController:segue.destinationViewController
                           forSegue:segue.identifier
                      fromIndexPath:indexPath];
    });
}

@end
