//
//  PublicationObjTableViewController.m
//  Publications
//
//  Created by Titiaan Palazzi on 2/11/15.
//  Copyright (c) 2015 Rocky Mountain Institute. All rights reserved.
//

#import "PublicationObjTableViewController.h"

@implementation PublicationObjTableViewController

@end

- (void)viewDidLoad
{
    [PFQuery clearAllCachedResults];
    PFQuery *query = [PFQuery queryWithClassName:@"ShowContacts"];
    query.cachePolicy = kPFCachePolicyIgnoreCache;
    [query orderByAscending:@"Name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            NSMutableArray *items = [NSMutableArray array];
            for (id obj in objects)
            {
                [items addObject:obj];
            }
            self.items = items;
            NSLog(@"%@", objects);
            NSLog(@"%lu", (unsigned long)[objects count]); // 63 records according to NSLog
            [self.myTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
}
#pragma mark Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath        *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
    }
    cell.textLabel.text = [[self.items objectAtIndex:indexPath.row] objectForKey:@"Name"];
    return cell;
}