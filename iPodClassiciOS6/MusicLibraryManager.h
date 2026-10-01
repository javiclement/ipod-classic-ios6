//
//  MusicLibraryManager.h
//  iPodClassiciOS6
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface TrackItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, strong) UIImage *artwork;
@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, strong) MPMediaItem *mediaItem;
@end

@protocol MusicPlayerDelegate <NSObject>
@optional
- (void)musicPlayerStateDidChangeIsPlaying:(BOOL)isPlaying;
- (void)musicPlayerProgressDidChangeTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
- (void)musicPlayerTrackDidChange:(TrackItem *)currentTrack;
@end

@interface MusicLibraryManager : NSObject

@property (nonatomic, weak) id<MusicPlayerDelegate> delegate;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) TrackItem *currentTrack;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;

+ (instancetype)sharedManager;

- (NSArray<NSString *> *)getAllArtists;
- (NSArray<NSString *> *)getAllAlbums;
- (NSArray<TrackItem *> *)getAllSongs;
- (NSArray<TrackItem *> *)getSongsForArtist:(NSString *)artist;
- (NSArray<TrackItem *> *)getSongsForAlbum:(NSString *)album;

- (void)playTrackAtIndex:(NSInteger)index fromList:(NSArray<TrackItem *> *)trackList;
- (void)togglePlayPause;
- (void)nextTrack;
- (void)previousTrack;
- (void)seekToProgress:(float)percentage;
- (void)setVolume:(float)volume;

@end
