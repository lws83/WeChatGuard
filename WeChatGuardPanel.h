#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeChatGuardPanel : NSObject

/// Install the floating WeChatGuard button.
+ (void)install;

/// Show the control panel.
+ (void)showPanel;

/// Hide the control panel.
+ (void)hidePanel;

@end

NS_ASSUME_NONNULL_END
