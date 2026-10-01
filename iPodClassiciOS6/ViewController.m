//
//  ViewController.m
//  iPodClassiciOS6
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    
    // Disable web view bounce for native app feel
    if ([_webView respondsToSelector:@selector(scrollView)]) {
        _webView.scrollView.bounces = NO;
        _webView.scrollView.scrollEnabled = NO;
    }
    
    [self.view addSubview:_webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web_version"];
    if (!htmlPath) {
        htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    }
    
    if (htmlPath) {
        NSURL *url = [NSURL fileURLWithPath:htmlPath];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
