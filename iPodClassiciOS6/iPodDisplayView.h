//
//  iPodDisplayView.h
//  iPodClassiciOS6
//

#import <UIKit/UIKit.h>
#import "MusicLibraryManager.h"

typedef NS_ENUM(NSInteger, iPodScreenState) {
    iPodScreenStateMainMenu,
    iPodScreenStateArtistsList,
    iPodScreenStateAlbumsList,
    iPodScreenStateSongsList,
    iPodScreenStateNowPlaying,
    iPodScreenStateSettings
};

@interface iPodDisplayView : UIView

@property (nonatomic, assign) iPodScreenState screenState;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)updateMenuItems:(NSArray<NSString *> *)items title:(NSString *)title;
- (void)moveSelectionDown;
- (void)moveSelectionUp;
- (void)updateNowPlayingTrack:(TrackItem *)track isPlaying:(BOOL)isPlaying;
- (void)updatePlaybackProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

@end
