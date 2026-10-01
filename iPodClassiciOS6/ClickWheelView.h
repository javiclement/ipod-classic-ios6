//
//  ClickWheelView.h
//  iPodClassiciOS6
//
//  Created for iPhone 4 iOS 6.x
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ClickWheelButtonType) {
    ClickWheelButtonTypeNone,
    ClickWheelButtonTypeMenu,
    ClickWheelButtonTypeNext,
    ClickWheelButtonTypePrevious,
    ClickWheelButtonTypePlayPause,
    ClickWheelButtonTypeCenterSelect
};

@protocol ClickWheelDelegate <NSObject>
@optional
- (void)clickWheelDidScrollClockwise;
- (void)clickWheelDidScrollCounterClockwise;
- (void)clickWheelDidPressButton:(ClickWheelButtonType)buttonType;
@end

@interface ClickWheelView : UIView

@property (nonatomic, weak) id<ClickWheelDelegate> delegate;

@end
