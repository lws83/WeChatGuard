#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeChatGuardPowerManager : NSObject

+ (instancetype)sharedManager;

/// 开启省电管理
- (void)start;

/// 停止省电管理
- (void)stop;

/// 当前是否处于后台
@property (nonatomic, assign, readonly, getter=isInBackground)
    BOOL inBackground;

/// 当前是否开启系统低电量模式
@property (nonatomic, assign, readonly, getter=isLowPowerMode)
    BOOL lowPowerMode;

/// 当前是否处于高热状态
@property (nonatomic, assign, readonly, getter=isThermalLimited)
    BOOL thermalLimited;

@end

NS_ASSUME_NONNULL_END
