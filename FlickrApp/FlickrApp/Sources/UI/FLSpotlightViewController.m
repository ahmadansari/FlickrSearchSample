//
//  FLSpotlightViewController.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 13/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "FLSpotlightViewController.h"
#import "FLDataHandler.h"

@interface FLSpotlightViewController ()

@property (strong, nonatomic) NSArray *searchHistory;
@property (strong, nonatomic) NSArray *filteredResults;
@property (nonatomic) BOOL isFiltering;

@end

static NSString *const spotlightCellIdentifier = @"spotlightCellIdentifier";

@implementation FLSpotlightViewController

+ (instancetype) instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FLSpotlightViewController *spotlightController = [storyboard instantiateViewControllerWithIdentifier:@"FLSpotlightViewController"];    
    return spotlightController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSearchHistory];
    [self reloadData];
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
    NSInteger rows = 0;
    if(_isFiltering) {
        rows = [_filteredResults count];
    } else {
        rows = [_searchHistory count];
    }
    return rows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return LOC(@"KEY_STRING_SEARCH_HISTORY");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:spotlightCellIdentifier forIndexPath:indexPath];
    NSString *keyword = nil;
    // Configure the cell...
    if(_isFiltering) {
        keyword = [_filteredResults objectAtIndex:indexPath.row];
    } else {
        keyword = [_searchHistory objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = keyword;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *keyword = nil;
    // Configure the cell...
    if(_isFiltering) {
        keyword = [_filteredResults objectAtIndex:indexPath.row];
    } else {
        keyword = [_searchHistory objectAtIndex:indexPath.row];
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectHistoryKeyword:)]) {
        [_delegate didSelectHistoryKeyword:keyword];
    }
}

- (void) reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)loadSearchHistory {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchHistory = [NSMutableArray arrayWithArray:[FLDataHandler sharedHandler].searchedKeywords];
    });
}

- (void) updateSearchResultsForText:(NSString *)searchText {
    if(!isEmpty(searchText)) {
        _isFiltering = YES;
        [self loadSearchHistory];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", searchText];
        _filteredResults = [_searchHistory filteredArrayUsingPredicate:predicate];
    } else {
        _isFiltering = NO;
    }
    [self reloadData];
}
@end
