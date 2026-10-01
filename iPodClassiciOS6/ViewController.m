//
//  ViewController.m
//  iPodClassiciOS6
//

#import "ViewController.h"

@interface ViewController () {
    iPodDisplayView *_displayView;
    ClickWheelView *_clickWheelView;
    MusicLibraryManager *_musicManager;
    
    NSMutableArray *_navigationStack;
    NSArray<TrackItem *> *_currentSongList;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background silver metal body of iPod Classic
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.89 blue:0.91 alpha:1.0];
    
    CGRect screenBounds = self.view.bounds;
    
    // 1. LCD Screen Display (Upper Half - 3.5 inch display of iPhone 4)
    CGFloat displayHeight = screenBounds.size.height * 0.42;
    _displayView = [[iPodDisplayView alloc] initWithFrame:CGRectMake(12, 28, screenBounds.size.width - 24, displayHeight)];
    [self.view addSubview:_displayView];
    
    // 2. Click Wheel View (Lower Half)
    CGFloat wheelSize = MIN(screenBounds.size.width - 30, screenBounds.size.height - displayHeight - 60);
    CGFloat wheelY = displayHeight + 45.0 + (screenBounds.size.height - displayHeight - 50.0 - wheelSize) / 2.0;
    
    _clickWheelView = [[ClickWheelView alloc] initWithFrame:CGRectMake((screenBounds.size.width - wheelSize) / 2.0, wheelY, wheelSize, wheelSize)];
    _clickWheelView.delegate = self;
    [self.view addSubview:_clickWheelView];
    
    // 3. Setup Music Manager
    _musicManager = [MusicLibraryManager sharedManager];
    _musicManager.delegate = self;
    
    // 4. Initial Navigation Menu Stack
    _navigationStack = [NSMutableArray array];
    [self openMainMenu];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)openMainMenu {
    [_navigationStack removeAllObjects];
    [_navigationStack addObject:@"MainMenu"];
    
    NSArray *menu = @[@"Música", @"Artistas", @"Álbumes", @"Canciones", @"Reproduciendo", @"Ajustes"];
    [_displayView updateMenuItems:menu title:@"iPod"];
    _displayView.screenState = iPodScreenStateMainMenu;
}

#pragma mark - ClickWheelDelegate

- (void)clickWheelDidScrollClockwise {
    [_displayView moveSelectionDown];
}

- (void)clickWheelDidScrollCounterClockwise {
    [_displayView moveSelectionUp];
}

- (void)clickWheelDidPressButton:(ClickWheelButtonType)buttonType {
    switch (buttonType) {
        case ClickWheelButtonTypeMenu:
            [self handleMenuButton];
            break;
            
        case ClickWheelButtonTypeCenterSelect:
            [self handleSelectButton];
            break;
            
        case ClickWheelButtonTypePlayPause:
            [_musicManager togglePlayPause];
            break;
            
        case ClickWheelButtonTypeNext:
            [_musicManager nextTrack];
            break;
            
        case ClickWheelButtonTypePrevious:
            [_musicManager previousTrack];
            break;
            
        default:
            break;
    }
}

- (void)handleMenuButton {
    if (_navigationStack.count > 1) {
        [_navigationStack removeLastObject];
        NSString *currentLevel = [_navigationStack lastObject];
        [self loadLevel:currentLevel];
    } else {
        [self openMainMenu];
    }
}

- (void)handleSelectButton {
    if (_displayView.screenState == iPodScreenStateNowPlaying) {
        return;
    }
    
    NSInteger idx = _displayView.selectedIndex;
    NSString *currentLevel = [_navigationStack lastObject];
    
    if ([currentLevel isEqualToString:@"MainMenu"]) {
        switch (idx) {
            case 0: // Música -> Songs
            case 3: // Canciones
                [self openSongsList];
                break;
            case 1: // Artistas
                [self openArtistsList];
                break;
            case 2: // Álbumes
                [self openAlbumsList];
                break;
            case 4: // Reproduciendo
                [_displayView setScreenState:iPodScreenStateNowPlaying];
                [_navigationStack addObject:@"NowPlaying"];
                break;
            default:
                break;
        }
    } else if ([currentLevel isEqualToString:@"SongsList"]) {
        // Play song
        if (_currentSongList.count > idx) {
            [_musicManager playTrackAtIndex:idx fromList:_currentSongList];
            [_displayView setScreenState:iPodScreenStateNowPlaying];
            [_navigationStack addObject:@"NowPlaying"];
        }
    }
}

- (void)loadLevel:(NSString *)levelName {
    if ([levelName isEqualToString:@"MainMenu"]) {
        [self openMainMenu];
    } else if ([levelName isEqualToString:@"SongsList"]) {
        [self openSongsList];
    } else if ([levelName isEqualToString:@"ArtistsList"]) {
        [self openArtistsList];
    } else if ([levelName isEqualToString:@"AlbumsList"]) {
        [self openAlbumsList];
    }
}

- (void)openSongsList {
    _currentSongList = [_musicManager getAllSongs];
    NSMutableArray *songTitles = [NSMutableArray array];
    for (TrackItem *t in _currentSongList) {
        [songTitles addObject:t.title];
    }
    [_displayView updateMenuItems:songTitles title:@"Canciones"];
    _displayView.screenState = iPodScreenStateSongsList;
    [_navigationStack addObject:@"SongsList"];
}

- (void)openArtistsList {
    NSArray *artists = [_musicManager getAllArtists];
    [_displayView updateMenuItems:artists title:@"Artistas"];
    _displayView.screenState = iPodScreenStateArtistsList;
    [_navigationStack addObject:@"ArtistsList"];
}

- (void)openAlbumsList {
    NSArray *albums = [_musicManager getAllAlbums];
    [_displayView updateMenuItems:albums title:@"Álbumes"];
    _displayView.screenState = iPodScreenStateAlbumsList;
    [_navigationStack addObject:@"AlbumsList"];
}

#pragma mark - MusicPlayerDelegate

- (void)musicPlayerStateDidChangeIsPlaying:(BOOL)isPlaying {
    // Update Play/Pause status indicator
}

- (void)musicPlayerTrackDidChange:(TrackItem *)currentTrack {
    [_displayView updateNowPlayingTrack:currentTrack isPlaying:_musicManager.isPlaying];
}

- (void)musicPlayerProgressDidChangeTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    [_displayView updatePlaybackProgress:currentTime duration:duration];
}

@end
