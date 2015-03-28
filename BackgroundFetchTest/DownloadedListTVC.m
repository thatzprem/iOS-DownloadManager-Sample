//
//  DownloadedListTVC.m
//  BackgroundFetchTest
//
//  Created by Prem kumar on 25/03/14.
//  Copyright (c) 2014 happiestminds. All rights reserved.
//

#import "DownloadedListTVC.h"
#import "DetailsTVC.h"

@interface DownloadedListTVC ()

@end

@implementation DownloadedListTVC

- (void)viewDidLoad{
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        self.title = [NSString stringWithFormat:@"%d items",[self.downloadedFileNamesArray count]];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.downloadedFileNamesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"List Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.downloadedFileNamesArray objectAtIndex:indexPath.row];
    
    return cell;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareViewController:(id)viewController
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    if ([viewController isKindOfClass:[DetailsTVC class]]) {
        DetailsTVC *downloadedListTVC = (DetailsTVC *)viewController;
        downloadedListTVC.filenNameString = [self.downloadedFileNamesArray objectAtIndex:indexPath.row];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

@end
