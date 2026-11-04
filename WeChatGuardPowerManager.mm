#import "WeChatGuardPowerManager.h"
#import <UIKit/UIKit.h>
#import <os/lock.h>

@interface WeChatGuardPowerManager ()

@property (nonatomic, assign, readwrite, getter=isInBackground)
    BOOL inBackground;

@property (nonatomic, assign, readwrite, getter=isLowPowerMode)
    BOOL lowPowerMode;

@property (nonatomic, assign, readwrite, getter=isThermalLimited)
    BOOL thermalLimited;

@property (nonatomic, strong) dispatch_queue_t workQueue;
@property (nonatomic, assign) BOOL started;

@end

@implementation WeChatGuardPowerManager

+ (instancetype)sharedManager {
    static WeChatGuardPowerManager *manager;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        manager = [[WeChatGuardPowerManager alloc] init];
    });

    return manager;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _workQueue = dispatch_queue_create(
            "com.wechatguard.power",
            DISPATCH_QUEUE_SERIAL
        );

        _inBackground = NO;
        _lowPowerMode = NSProcessInfo.processInfo.lowPowerModeEnabled;
        _thermalLimited =
            NSProcessInfo.processInfo.thermalState >=
            NSProcessInfoThermalStateSerious;
    }

    return self;
}

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.started) {
            return;
        }

        self.started = YES;

        NSNotificationCenter *center =
            NSNotificationCenter.defaultCenter;

        [center addObserver:self
                   selector:@selector(onEnterBackground:)
                       name:UIApplicationDidEnterBackgroundNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(onEnterForeground:)
                       name:UIApplicationWillEnterForegroundNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(onBecomeActive:)
                       name:UIApplicationDidBecomeActiveNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(onLowPowerChanged:)
                       name:NSProcessInfoPowerStateDidChangeNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(onThermalChanged:)
                       name:NSProcessInfoThermalStateDidChangeNotification
                     object:nil];

        self.lowPowerMode =
            NSProcessInfo.processInfo.lowPowerModeEnabled;

        self.thermalLimited =
            NSProcessInfo.processInfo.thermalState >=
            NSProcessInfoThermalStateSerious;

        NSLog(@"[WeChatGuard] Power manager started");
    });
}

- (void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.started) {
            return;
        }

        [[NSNotificationCenter defaultCenter]
            removeObserver:self];

        self.started = NO;

        NSLog(@"[WeChatGuard] Power manager stopped");
    });
}

#pragma mark - Application Lifecycle

- (void)onEnterBackground:(NSNotification *)notification {
    self.inBackground = YES;

    NSLog(@"[WeChatGuard] Background: low activity mode");

    // 停止本模块自己的非必要工作。
    // 不执行高频轮询，不创建后台保活循环。
}

- (void)onEnterForeground:(NSNotification *)notification {
    NSLog(@"[WeChatGuard] Will enter foreground");
}

- (void)onBecomeActive:(NSNotification *)notification {
    self.inBackground = NO;

    NSLog(@"[WeChatGuard] Active: normal activity mode");
}

#pragma mark - Power State

- (void)onLowPowerChanged:(NSNotification *)notification {
    self.lowPowerMode =
        NSProcessInfo.processInfo.lowPowerModeEnabled;

    NSLog(@"[WeChatGuard] Low power mode: %@",
          self.lowPowerMode ? @"ON" : @"OFF");
}

#pragma mark - Thermal State

- (void)onThermalChanged:(NSNotification *)notification {
    NSProcessInfoThermalState state =
        NSProcessInfo.processInfo.thermalState;

    self.thermalLimited =
        state >= NSProcessInfoThermalStateSerious;

    NSLog(@"[WeChatGuard] Thermal state: %ld",
          (long)state);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
        removeObserver:self];
}

@end
