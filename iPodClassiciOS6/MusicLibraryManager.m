//
//  MusicLibraryManager.m
//  iPodClassiciOS6
//

#import "MusicLibraryManager.h"

@implementation TrackItem
@end

@interface MusicLibraryManager () <AVAudioPlayerDelegate> {
    AVAudioPlayer *_audioPlayer;
    MPMusicPlayerController *_systemMusicPlayer;
    NSArray<TrackItem *> *_currentPlaylist;
    NSInteger _currentIndex;
    NSTimer *_progressTimer;
}
@end

@implementation MusicLibraryManager

+ (instancetype)sharedManager {
    static MusicLibraryManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MusicLibraryManager alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentPlaylist = [NSMutableArray array];
        _currentIndex = -1;
        
        // Setup Audio Session for Background Playback (Crucial for iOS 6)
        NSError *error = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        [session setActive:YES error:&error];
        
        _systemMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    }
    return self;
}

- (NSArray<TrackItem *> *)getAllSongs {
    NSMutableArray<TrackItem *> *songs = [NSMutableArray array];
    
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    NSArray<MPMediaItem *> *items = [query items];
    
    if (items.count > 0) {
        for (MPMediaItem *item in items) {
            TrackItem *t = [[TrackItem alloc] init];
            t.title = [item valueForProperty:MPMediaItemPropertyTitle] ?: @"Sin Título";
            t.artist = [item valueForProperty:MPMediaItemPropertyArtist] ?: @"Artista Desconocido";
            t.album = [item valueForProperty:MPMediaItemPropertyAlbumTitle] ?: @"Álbum Desconocido";
            t.assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
            t.mediaItem = item;
            
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            if (artwork) {
                t.artwork = [artwork imageWithSize:CGSizeMake(300, 300)];
            }
            [songs addObject:t];
        }
    } else {
        // Fallback demo items if media library is empty
        songs = [self getDemoTracks];
    }
    
    return songs;
}

- (NSMutableArray<TrackItem *> *)getDemoTracks {
    NSMutableArray<TrackItem *> *demos = [NSMutableArray array];
    
    NSArray *demoTitles = @[@"Over the Horizon", @"Classic Symphony", @"Midnight Drive", @"Retro Beats"];
    NSArray *demoArtists = @[@"Samsung/Apple", @"Mozart", @"Synthwave Boy", @"80s Revival"];
    NSArray *demoAlbums = @[@"Ringtones", @"Classical Gold", @"Night City", @"Retro Hits"];
    
    for (NSUInteger i = 0; i < demoTitles.count; i++) {
        TrackItem *t = [[TrackItem alloc] init];
        t.title = demoTitles[i];
        t.artist = demoArtists[i];
        t.album = demoAlbums[i];
        [demos addObject:t];
    }
    return demos;
}

- (NSArray<NSString *> *)getAllArtists {
    MPMediaQuery *query = [MPMediaQuery artistsQuery];
    NSMutableArray *artists = [NSMutableArray array];
    for (MPMediaItemCollection *collection in query.collections) {
        NSString *name = [collection.representativeItem valueForProperty:MPMediaItemPropertyArtist];
        if (name) [artists addObject:name];
    }
    if (artists.count == 0) {
        return @[@"Apple", @"Mozart", @"Synthwave Boy", @"80s Revival"];
    }
    return artists;
}

- (NSArray<NSString *> *)getAllAlbums {
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    NSMutableArray *albums = [NSMutableArray array];
    for (MPMediaItemCollection *collection in query.collections) {
        NSString *title = [collection.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        if (title) [albums addObject:title];
    }
    if (albums.count == 0) {
        return @[@"Ringtones", @"Classical Gold", @"Night City", @"Retro Hits"];
    }
    return albums;
}

- (NSArray<TrackItem *> *)getSongsForArtist:(NSString *)artist {
    NSArray<TrackItem *> *all = [self getAllSongs];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"artist == %@", artist];
    return [all filteredArrayUsingPredicate:pred];
}

- (NSArray<TrackItem *> *)getSongsForAlbum:(NSString *)album {
    NSArray<TrackItem *> *all = [self getAllSongs];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"album == %@", album];
    return [all filteredArrayUsingPredicate:pred];
}

#pragma mark - Playback Controls

- (void)playTrackAtIndex:(NSInteger)index fromList:(NSArray<TrackItem *> *)trackList {
    if (index < 0 || index >= trackList.count) return;
    
    _currentPlaylist = trackList;
    _currentIndex = index;
    TrackItem *track = _currentPlaylist[_currentIndex];
    
    if (track.assetURL) {
        NSError *error = nil;
        if (_audioPlayer) {
            [_audioPlayer stop];
            _audioPlayer = nil;
        }
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:track.assetURL error:&error];
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
    
    [self startTimer];
    
    if ([self.delegate respondsToSelector:@selector(musicPlayerTrackDidChange:)]) {
        [self.delegate musicPlayerTrackDidChange:track];
    }
    if ([self.delegate respondsToSelector:@selector(musicPlayerStateDidChangeIsPlaying:)]) {
        [self.delegate musicPlayerStateDidChangeIsPlaying:YES];
    }
}

- (void)togglePlayPause {
    if (!_audioPlayer) {
        if (_currentPlaylist.count > 0 && _currentIndex >= 0) {
            [self playTrackAtIndex:_currentIndex fromList:_currentPlaylist];
        }
        return;
    }
    
    if (_audioPlayer.isPlaying) {
        [_audioPlayer pause];
        [self stopTimer];
    } else {
        [_audioPlayer play];
        [self startTimer];
    }
    
    if ([self.delegate respondsToSelector:@selector(musicPlayerStateDidChangeIsPlaying:)]) {
        [self.delegate musicPlayerStateDidChangeIsPlaying:_audioPlayer.isPlaying];
    }
}

- (void)nextTrack {
    if (_currentPlaylist.count == 0) return;
    NSInteger nextIdx = (_currentIndex + 1) % _currentPlaylist.count;
    [self playTrackAtIndex:nextIdx fromList:_currentPlaylist];
}

- (void)previousTrack {
    if (_currentPlaylist.count == 0) return;
    NSInteger prevIdx = (_currentIndex - 1 + _currentPlaylist.count) % _currentPlaylist.count;
    [self playTrackAtIndex:prevIdx fromList:_currentPlaylist];
}

- (void)seekToProgress:(float)percentage {
    if (_audioPlayer && _audioPlayer.duration > 0) {
        _audioPlayer.currentTime = _audioPlayer.duration * percentage;
    }
}

- (void)setVolume:(float)volume {
    if (_audioPlayer) {
        _audioPlayer.volume = volume;
    }
}

- (BOOL)isPlaying {
    return _audioPlayer ? _audioPlayer.isPlaying : NO;
}

- (TrackItem *)currentTrack {
    if (_currentIndex >= 0 && _currentIndex < _currentPlaylist.count) {
        return _currentPlaylist[_currentIndex];
    }
    return nil;
}

- (NSTimeInterval)currentTime {
    return _audioPlayer ? _audioPlayer.currentTime : 0;
}

- (NSTimeInterval)duration {
    return _audioPlayer ? _audioPlayer.duration : 0;
}

#pragma mark - Timer

- (void)startTimer {
    [self stopTimer];
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_progressTimer) {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}

- (void)timerTick {
    if ([self.delegate respondsToSelector:@selector(musicPlayerProgressDidChangeTime:duration:)]) {
        [self.delegate musicPlayerProgressDidChangeTime:self.currentTime duration:self.duration];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self nextTrack];
}

@end
