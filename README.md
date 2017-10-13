# Flickr Photo Search App
This application demonstrates how to perform a Flickr pubilc photo library search on ios application using flickr search api. Application persists the searched information local database and displays photos in 3 column based collection view. Application provides means to search through photos, list previous search history items, and fetch endless photo feeds on scrolling to bottom of the view.


## Installation
- Application is using CocoaPods, so open the application using 'FlickrApp.xcworkspace' file.
- Using terminal install the pods and open the applicaiton.
- Build and run the application on simulator or actual device running iOS 11.0 or later using Xcode 9.X.
- After running, the application, it will auto download the first page with photos of "kittens".

## User Guidelines
- Tap on search bar, you would see the list of recent searches.
- While you are typing your previous search history gets filtered automatically.
- Type keyword, or select from search history and hit the Search button.
- New photos will start to download.
- Per page 50 photos are downloaded.
- As long as search bar contains some keyword, application will automatically fetch next page of photos, when scrolling to bottom
- So, just type a keyword, hit enter, and start scrolling and you would see enless photo stream.
- Photos are downloaded and cahced, so previous downloaded photos will be displayed immediately, other wise lazy loading mechanism is there which keeps the UI interactable.
- CollectionView will show 3x3 grid of photo cells, and every cells shows a photos and its title above it.
- On tapping any photo, a Photo Viewer will be opened, where photo can be seen in full ratio.
- Application support portrait and landscape orientations, as shown in screen shots.
- Application preserves the search history up to last 20 keywords count, and truncates the tail when it reaches the limit. (First In Last Out).
- Applciation is using Core Data to store downloaded photos information, and will work in offline mode.
- Search feature does not work in offline mode, becuase its live api search.
- But in offline mode, user can see previously downloaded photos.

## Main Files
__FLDataHandler__:
-   __FLDataHandler is a singleton class providing interface to perform repository data web requests, and communication with model objects to persist downloaded information. This class is also responsible for pagination mechanism, it uses Repository entity count and page size to calculate next requsting range.

__DatabaseContext__:
- __DatabaseContext handles Core Data Stack. It provides utilitiy methods and multiple NSManagedObjectContexts for writing and reading purposes.

__FLlickrModel.xcdatamodeld__:
- Defines core data model having entity description.

__Photo__:
- __Photo is NSManagedObject subclass that contains dynamically generated properites for database model object. Mainly responsible for providng interface to manipulate data and retrieving information. It decouples all relevant logic to the database entity from other parts like data handler or service handler.

__FLViewController__:
- __FLViewController is the main view controller that displays flickr photos in collection view. It uses NSFetchedResultsController to track database events when photo data is modified. This controller handles all delegates of UISearchController, UISearchBar and provides mechanism to filter and request new photos on user demand.

__FLPhotoViewController__:
- __FLPhotoViewController displays photo in large scale mode, along with the photo title.

__FLSpotlightViewController__:
- __FLSpotLightViewController serves as recent search history display/filter controller. It is associated with UISearchController's searchResultController, but instead of displaying searched photos, it displays recent search history, and on typing it filters history to show tableview list.

__FLCollectionView__:
- __FLCollectionView is a UICollectionView subclass. It registers defualts custom cells.

__PhotoItemCell__:
- __PhotoItemCell is a custom collection view cell that displays photo and its title. It loads the photo in lazy fashion to keep UI interactable.

__Constants__:
- __Constants classholds all constant values, like color codes, page size (Default is 50), etc. You can change different values here to test the applicaiton behavior.

__Macros__:
- __Macros file contains utility macros that are used in entire application at different points, e,g; isEmpty(object), etc.

__FLDefines__:
- __FLDefines contains all define directives, like web service URLs, database defines, etc.

__FlickrPhotoService__:
- __FlickrPhotoService is subclass of __AFRestService  and has sole purpose of making web requests and fetching searched photos from flickr server. It users AFNetworking as underlying framework to make requests.

__AFRestService__:
- __AFRestService is custom wrapper class written to provide a single interface for making different kind of web requests, (Data Tasks, Download Tasks, etc) using AFNetworking underneath. All service classes are inherited from this super class, and uses its predefined logic to make requests.

__AXNetwork__:
- Custom written network monitoring utility, keep tracks of network state changes Used by Network services while making requests.

## Other Notes
Application has been strucutred nicely, with three main folders, Sources, Resources, Supporting Files.
- Soruces contains all appication source code.
- Resources contains images, localizations files, assets, etc.
- Supporting Files contains different file like, info.plist, main.m and prefix header files.

## Dependencies
Dependencies are managed using CocoaPods
- AFNetworking: Is used to perform web request.
- CocoaLumberJack: Used for logging.
- SDWebImage: Used for lazzy image loading, and web caching.
- MBProgressHud: User for displaying activity indicator on loading photos.
- UICollectionView+NSFetchedResultsController: Helper Catagory that populates collection view on database events.

