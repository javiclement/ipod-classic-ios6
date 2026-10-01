//
//  ClickWheelView.m
//  iPodClassiciOS6
//

#import "ClickWheelView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface ClickWheelView () {
    CGFloat _lastAngle;
    BOOL _isDraggingWheel;
    CGPoint _centerPoint;
    CGFloat _outerRadius;
    CGFloat _innerRadius;
    SystemSoundID _tickSoundID;
}
@end

@implementation ClickWheelView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = NO;
    self.userInteractionEnabled = YES;
    
    // Register system sound for tick sound (standard system click sound 1104 or custom sound)
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:@"/System/Library/Audio/UISounds/tock.caf"], &_tickSoundID);
    if (!_tickSoundID) {
        _tickSoundID = 1104; // Fallback system keyboard click
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _centerPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    _outerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0 - 5.0;
    _innerRadius = _outerRadius * 0.35;
}

- (void)playTickSound {
    if (_tickSoundID) {
        AudioServicesPlaySystemSound(_tickSoundID);
    }
}

#import <math.h>

- (CGFloat)angleForPoint:(CGPoint)point {
    CGFloat dx = point.x - _centerPoint.x;
    CGFloat dy = point.y - _centerPoint.y;
    CGFloat angle = atan2f(dy, dx); // Range -PI to PI
    if (angle < 0) {
        angle += 2.0 * M_PI;
    }
    return angle;
}

- (CGFloat)distanceFromCenter:(CGPoint)point {
    CGFloat dx = point.x - _centerPoint.x;
    CGFloat dy = point.y - _centerPoint.y;
    return sqrtf(dx * dx + dy * dy);
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGFloat dist = [self distanceFromCenter:location];
    
    if (dist <= _innerRadius) {
        // Pressed center button
        _isDraggingWheel = NO;
        [self playTickSound];
        if ([self.delegate respondsToSelector:@selector(clickWheelDidPressButton:)]) {
            [self.delegate clickWheelDidPressButton:ClickWheelButtonTypeCenterSelect];
        }
    } else if (dist <= _outerRadius) {
        // Touch on wheel area
        _isDraggingWheel = YES;
        _lastAngle = [self angleForPoint:location];
    } else {
        _isDraggingWheel = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_isDraggingWheel) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGFloat dist = [self distanceFromCenter:location];
    
    if (dist < _innerRadius || dist > _outerRadius + 20) {
        return;
    }
    
    CGFloat currentAngle = [self angleForPoint:location];
    CGFloat deltaAngle = currentAngle - _lastAngle;
    
    // Normalize delta across boundary (0 to 2*PI)
    if (deltaAngle > M_PI) {
        deltaAngle -= 2.0 * M_PI;
    } else if (deltaAngle < -M_PI) {
        deltaAngle += 2.0 * M_PI;
    }
    
    // Sensitivity threshold (~15 degrees = ~0.26 radians)
    CGFloat threshold = 0.22;
    
    if (fabs(deltaAngle) >= threshold) {
        if (deltaAngle > 0) {
            [self playTickSound];
            if ([self.delegate respondsToSelector:@selector(clickWheelDidScrollClockwise)]) {
                [self.delegate clickWheelDidScrollClockwise];
            }
        } else {
            [self playTickSound];
            if ([self.delegate respondsToSelector:@selector(clickWheelDidScrollCounterClockwise)]) {
                [self.delegate clickWheelDidScrollCounterClockwise];
            }
        }
        _lastAngle = currentAngle;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGFloat dist = [self distanceFromCenter:location];
    
    if (!_isDraggingWheel && dist > _innerRadius && dist <= _outerRadius) {
        // Detect discrete button click on MENU, PREV, NEXT, PLAY/PAUSE
        CGFloat angle = [self angleForPoint:location]; // 0 at Right (3 o'clock), PI/2 at Bottom, PI at Left, 3PI/2 at Top
        
        ClickWheelButtonType button = ClickWheelButtonTypeNone;
        
        if (angle >= 5.0 * M_PI_4 || angle < M_PI_4) {
            // Right quadrant: Next
            button = ClickWheelButtonTypeNext;
        } else if (angle >= M_PI_4 && angle < 3.0 * M_PI_4) {
            // Bottom quadrant: Play/Pause
            button = ClickWheelButtonTypePlayPause;
        } else if (angle >= 3.0 * M_PI_4 && angle < 5.0 * M_PI_4) {
            // Left quadrant: Previous
            button = ClickWheelButtonTypePrevious;
        } else {
            // Top quadrant: Menu
            button = ClickWheelButtonTypeMenu;
        }
        
        if (button != ClickWheelButtonTypeNone) {
            [self playTickSound];
            if ([self.delegate respondsToSelector:@selector(clickWheelDidPressButton:)]) {
                [self.delegate clickWheelDidPressButton:button];
            }
        }
    }
    
    _isDraggingWheel = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isDraggingWheel = NO;
}

#pragma mark - Custom Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Outer Wheel Circle (Light Gray / White Plastic with subtle gradient)
    CGRect outerBounds = CGRectMake(_centerPoint.x - _outerRadius, _centerPoint.y - _outerRadius, _outerRadius * 2, _outerRadius * 2);
    
    CGContextSetRGBFillColor(ctx, 0.92, 0.92, 0.94, 1.0);
    CGContextFillEllipseInRect(ctx, outerBounds);
    
    // Subtle border
    CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.78, 1.0);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextStrokeEllipseInRect(ctx, outerBounds);
    
    // Center Select Button Circle
    CGRect innerBounds = CGRectMake(_centerPoint.x - _innerRadius, _centerPoint.y - _innerRadius, _innerRadius * 2, _innerRadius * 2);
    CGContextSetRGBFillColor(ctx, 0.85, 0.85, 0.87, 1.0);
    CGContextFillEllipseInRect(ctx, innerBounds);
    CGContextSetRGBStrokeColor(ctx, 0.70, 0.70, 0.73, 1.0);
    CGContextSetLineWidth(ctx, 1.5);
    CGContextStrokeEllipseInRect(ctx, innerBounds);
    
    // Draw Text Labels on Wheel: MENU (Top), << (Left), >> (Right), ||> (Bottom)
    UIFont *labelFont = [UIFont boldSystemFontOfSize:14.0];
    UIColor *labelColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.42 alpha:1.0];
    
    NSDictionary *attr = @{NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelColor};
    
    // MENU (Top)
    NSString *menuText = @"MENU";
    CGSize menuSize = [menuText sizeWithFont:labelFont];
    [menuText drawAtPoint:CGPointMake(_centerPoint.x - menuSize.width / 2.0, _centerPoint.y - _outerRadius + 18.0) withFont:labelFont];
    
    // Next >> (Right)
    NSString *nextText = @"▶▶";
    CGSize nextSize = [nextText sizeWithFont:labelFont];
    [nextText drawAtPoint:CGPointMake(_centerPoint.x + _outerRadius - nextSize.width - 18.0, _centerPoint.y - nextSize.height / 2.0) withFont:labelFont];
    
    // Previous << (Left)
    NSString *prevText = @"◀◀";
    CGSize prevSize = [prevText sizeWithFont:labelFont];
    [prevText drawAtPoint:CGPointMake(_centerPoint.x - _outerRadius + 18.0, _centerPoint.y - prevSize.height / 2.0) withFont:labelFont];
    
    // Play/Pause ▶❚❚ (Bottom)
    NSString *playPauseText = @"▶❚❚";
    CGSize playSize = [playPauseText sizeWithFont:labelFont];
    [playPauseText drawAtPoint:CGPointMake(_centerPoint.x - playSize.width / 2.0, _centerPoint.y + _outerRadius - playSize.height - 18.0) withFont:labelFont];
}

@end
