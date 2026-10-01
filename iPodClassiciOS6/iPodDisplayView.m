//
//  iPodDisplayView.m
//  iPodClassiciOS6
//

#import "iPodDisplayView.h"
#import <QuartzCore/QuartzCore.h>

@interface iPodDisplayView () {
    UIView *_statusBarView;
    UILabel *_titleLabel;
    UIImageView *_playIconView;
    
    // Menu Table
    UITableView *_menuTableView;
    NSArray<NSString *> *_currentItems;
    NSString *_headerTitle;
    
    // Now Playing Subview
    UIView *_nowPlayingView;
    UIImageView *_albumArtImageView;
    UILabel *_songTitleLabel;
    UILabel *_artistLabel;
    UILabel *_albumLabel;
    UIProgressView *_progressBar;
    UILabel *_elapsedTimeLabel;
    UILabel *_remainingTimeLabel;
}
@end

@implementation iPodDisplayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLCDDisplay];
    }
    return self;
}

- (void)setupLCDDisplay {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 3.0;
    self.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
    self.layer.cornerRadius = 6.0;
    self.clipsToBounds = YES;
    
    // 1. Status Bar (Top iPod Classic Header)
    _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 24)];
    _statusBarView.backgroundColor = [UIColor colorWithRed:0.85 green:0.88 blue:0.92 alpha:1.0];
    
    // Metallic top status bar gradient line
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 23, self.bounds.size.width, 1)];
    line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [_statusBarView addSubview:line];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 160, 24)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _titleLabel.textColor = [UIColor darkGrayColor];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"iPod";
    [_statusBarView addSubview:_titleLabel];
    
    [self addSubview:_statusBarView];
    
    // 2. Menu Table View (Middle)
    _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 24, self.bounds.size.width, self.bounds.size.height - 24) style:UITableViewStylePlain];
    _menuTableView.backgroundColor = [UIColor whiteColor];
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.rowHeight = 32.0;
    _menuTableView.scrollEnabled = NO; // Controlled purely via Click Wheel
    [self addSubview:_menuTableView];
    
    // 3. Now Playing View (Hidden by default)
    _nowPlayingView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, self.bounds.size.width, self.bounds.size.height - 24)];
    _nowPlayingView.backgroundColor = [UIColor colorWithRed:0.94 green:0.95 blue:0.97 alpha:1.0];
    _nowPlayingView.hidden = YES;
    
    _albumArtImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 100, 100)];
    _albumArtImageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _albumArtImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _albumArtImageView.layer.borderWidth = 1.0;
    _albumArtImageView.contentMode = UIViewContentModeScaleAspectFill;
    _albumArtImageView.clipsToBounds = YES;
    [_nowPlayingView addSubview:_albumArtImageView];
    
    _songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 16, self.bounds.size.width - 130, 20)];
    _songTitleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _songTitleLabel.textColor = [UIColor blackColor];
    _songTitleLabel.backgroundColor = [UIColor clearColor];
    [_nowPlayingView addSubview:_songTitleLabel];
    
    _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 38, self.bounds.size.width - 130, 18)];
    _artistLabel.font = [UIFont systemFontOfSize:12.0];
    _artistLabel.textColor = [UIColor darkGrayColor];
    _artistLabel.backgroundColor = [UIColor clearColor];
    [_nowPlayingView addSubview:_artistLabel];
    
    _albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 58, self.bounds.size.width - 130, 18)];
    _albumLabel.font = [UIFont systemFontOfSize:11.0];
    _albumLabel.textColor = [UIColor grayColor];
    _albumLabel.backgroundColor = [UIColor clearColor];
    [_nowPlayingView addSubview:_albumLabel];
    
    _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressBar.frame = CGRectMake(12, 130, self.bounds.size.width - 24, 8);
    [_nowPlayingView addSubview:_progressBar];
    
    _elapsedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 142, 60, 16)];
    _elapsedTimeLabel.font = [UIFont systemFontOfSize:10.0];
    _elapsedTimeLabel.textColor = [UIColor darkGrayColor];
    _elapsedTimeLabel.text = @"0:00";
    [_nowPlayingView addSubview:_elapsedTimeLabel];
    
    _remainingTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 72, 142, 60, 16)];
    _remainingTimeLabel.font = [UIFont systemFontOfSize:10.0];
    _remainingTimeLabel.textColor = [UIColor darkGrayColor];
    _remainingTimeLabel.textAlignment = NSTextAlignmentRight;
    _remainingTimeLabel.text = @"-0:00";
    [_nowPlayingView addSubview:_remainingTimeLabel];
    
    [self addSubview:_nowPlayingView];
}

- (void)setScreenState:(iPodScreenState)screenState {
    _screenState = screenState;
    if (screenState == iPodScreenStateNowPlaying) {
        _nowPlayingView.hidden = NO;
        _menuTableView.hidden = YES;
        _titleLabel.text = @"Reproduciendo";
    } else {
        _nowPlayingView.hidden = YES;
        _menuTableView.hidden = NO;
    }
}

- (void)updateMenuItems:(NSArray<NSString *> *)items title:(NSString *)title {
    _currentItems = items;
    _headerTitle = title;
    _titleLabel.text = title;
    _selectedIndex = 0;
}

- (void)moveSelectionDown {
    if (_currentItems.count == 0) return;
    _selectedIndex = (_selectedIndex + 1) % _currentItems.count;
}

- (void)moveSelectionUp {
    if (_currentItems.count == 0) return;
    _selectedIndex = (_selectedIndex - 1 + _currentItems.count) % _currentItems.count;
}

- (void)updateNowPlayingTrack:(TrackItem *)track isPlaying:(BOOL)isPlaying {
    if (!track) return;
    _songTitleLabel.text = track.title;
    _artistLabel.text = track.artist;
    _albumLabel.text = track.album;
    if (track.artwork) {
        _albumArtImageView.image = track.artwork;
    } else {
        _albumArtImageView.image = nil;
    }
}

- (void)updatePlaybackProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    if (duration <= 0) return;
    float progress = currentTime / duration;
    _progressBar.progress = progress;
    
    int curMin = (int)currentTime / 60;
    int curSec = (int)currentTime % 60;
    _elapsedTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", curMin, curSec];
    
    NSTimeInterval remain = duration - currentTime;
    int remMin = (int)remain / 60;
    int remSec = (int)remain % 60;
    _remainingTimeLabel.text = [NSString stringWithFormat:@"-%d:%02d", remMin, remSec];
}

@end
