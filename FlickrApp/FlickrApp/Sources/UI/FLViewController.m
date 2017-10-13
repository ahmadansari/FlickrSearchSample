//
//  FLViewController.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "FLViewController.h"
#import "FLCollectionView.h"
#import "FLDataHandler.h"
#import "UICollectionView+NSFetchedResultsController.h"
#import "FLPhotoViewController.h"
#import "FLSpotlightViewController.h"

@interface FLViewController () <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, FLSpotlightControllerDelegate>
@property (weak, nonatomic) IBOutlet FLCollectionView *collectionView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@end

@implementation FLViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.title = LOC(@"KEY_STRING_APP_TITLE");
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    //Initializing FRC
    [self inititalizeFetchedResultsController];
    
    //Setting Up Navigation Bar Style
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    //Setting Up Search Controller
    FLSpotlightViewController *spotlightController = [FLSpotlightViewController instance];
    spotlightController.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:spotlightController];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    _searchController.searchBar.returnKeyType = UIReturnKeySearch;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    self.navigationItem.searchController = _searchController;
    
    //For demo purpose, default search for Kittens
    //_searchController.searchBar.text = @"Kittens";
    [self updateSearchResultsWithText:@"Kittens"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:
(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // before rotation
    [coordinator animateAlongsideTransition:^(id _Nonnull context) {
        // during rotation: update our image view's bounds and centre
        [self reloadData];
    } completion:^(id _Nonnull context) {
        // after rotation
    }];
}

#pragma mark - Collection View Methods
#pragma mark-- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float columnCount = 3.0;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = (screenWidth - 10) / columnCount;
    CGSize size = CGSizeMake(cellWidth, 150);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)
collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)
collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

#pragma mark-- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    NSInteger sections = 1;
    sections = [[_fetchedResultsController sections] count];
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger rows = 0;
    id<NSFetchedResultsSectionInfo> sectionInfo;
    sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    rows = [sectionInfo numberOfObjects];
    return rows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    PhotoItemCell *photoCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:collectionCellPhotoItem forIndexPath:indexPath];
    Photo *photo = [_fetchedResultsController objectAtIndexPath:indexPath];
    [photoCell configure:photo];
    
    //If Last Cell is Rendered, Load More Items
    if ([self isLastCell:indexPath]) {
        //Save Last IndexPath to Keep Scroll Position
        self.lastIndexPath = indexPath;
        [self loadMorePhotos];
    }
    return photoCell;
}

- (void)loadMorePhotos {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *searchText = self.navigationItem.searchController.searchBar.text;
        [self updateSearchResultsWithText:searchText];
    });
}

- (BOOL)isLastCell:(NSIndexPath *)indexPath {
    BOOL isLast = NO;
    NSInteger totalRows = [[_fetchedResultsController fetchedObjects] count];
    if (indexPath.row == totalRows - 1) {
        isLast = YES;
    }
    return isLast;
}


#pragma mark-- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark-- Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    if(indexPath) {
        Photo *photo = [_fetchedResultsController objectAtIndexPath:indexPath];
        FLPhotoViewController *photoViewController = (FLPhotoViewController *)segue.destinationViewController;
        photoViewController.photo = photo;
    }
}

#pragma mark - Fetched Results Controller
- (void)inititalizeFetchedResultsController {
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        DDLogError(@"fetchedResultsController, Unresolved error %@, %@", error,
                   [error userInfo]);
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:[Photo entityName]
                inManagedObjectContext:[DatabaseContext sharedContext]
     .managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *nameDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameDescriptor]];
    
    // Create and initialize the fetch results controller.
    NSFetchedResultsController *aFetchedResultsController = [
                                                             [NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:[DatabaseContext sharedContext].managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}



#pragma mark-- NSFetchedResultsControllerDelegate
/**
 Delegate methods of NSFetchedResultsController to respond to additions,
 removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so
    // prepare the table view for updates.
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    // Collection View Updates
    [self.collectionView addChangeForObjectAtIndexPath:indexPath
                                         forChangeType:type
                                          newIndexPath:newIndexPath];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    // Collection View Updates
    [self.collectionView addChangeForSection:sectionInfo
                                     atIndex:sectionIndex
                               forChangeType:type];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the
    // table view to process all updates.
    
    // Collection View Updates
    [self.collectionView commitChanges];
}


#pragma mark - UISearchResultsUpdating
- (BOOL) isSearching {
    return !isEmpty(self.navigationItem.searchController.searchBar.text);
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    dispatch_async(dispatch_get_main_queue(), ^{
        searchController.searchResultsController.view.hidden = NO;
    });
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //Update Spotlight Search Controller Here to filtere Recent History.
    NSString *searchText = searchController.searchBar.text;
    NSLog(@"Keyword: %@", searchText);
    FLSpotlightViewController *spotlightController = (FLSpotlightViewController *)searchController.searchResultsController;
    [spotlightController updateSearchResultsForText:searchText];
    dispatch_async(dispatch_get_main_queue(), ^{
        searchController.searchResultsController.view.hidden = NO;
    });
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search : %@", searchBar.text);
    NSString *searchText = searchBar.text;
    [self.navigationItem.searchController setActive:NO];
    searchBar.text = searchText;
    [[FLDataHandler sharedHandler] saveSearchKeyword:searchText];
    [self updateSearchResultsWithText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if(![self isSearching]) {
        [self cancelSearch];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if(![self isSearching]) {
        [self cancelSearch];
    }
}

- (void)updateSearchResultsWithText:(NSString *)searchText {
    if(!isEmpty(searchText)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Start Progress Before Requesting Data
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        [[FLDataHandler sharedHandler]
         searchFlickrPhotosWithText:searchText
         completion:^(BOOL error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //Stop Progress on Load Complete
                 [MBProgressHUD hideHUDForView:self.view animated:NO];
                 
                 //Display Filtered Results
                 NSSet *filteredPhotoIDs = [FLDataHandler sharedHandler].searchedPhotoIDs;
                 NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
                 if([self isSearching] && !isEmpty(filteredPhotoIDs)) {
                     predicate = [NSPredicate predicateWithFormat:@"SELF.photoID IN %@", filteredPhotoIDs];
                 }
                 self.fetchedResultsController.fetchRequest.predicate = predicate;
                 [self inititalizeFetchedResultsController];
                 [self reloadData];
             });
         }];
    }
}

- (void) cancelSearch {
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    [self inititalizeFetchedResultsController];
    [self reloadData];
}

- (void) reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        if([self isSearching] && _lastIndexPath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView scrollToItemAtIndexPath:self.lastIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            });
        }
    });
}

#pragma mark - FLSpotlightControllerDelegate
- (void) didSelectHistoryKeyword:(NSString *)keyword {
    [self.navigationItem.searchController setActive:NO];
    _searchController.searchBar.text = keyword;
    [[FLDataHandler sharedHandler] saveSearchKeyword:keyword];
    [self updateSearchResultsWithText:keyword];
}

@end

