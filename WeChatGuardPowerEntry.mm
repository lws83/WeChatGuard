#import <Foundation/Foundation.h>
#import "WeChatGuardPowerManager.h"
#import "WeChatGuardPanel.h"

__attribute__((constructor))
static void WeChatGuardPowerInitialize(void) {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[WeChatGuardPowerManager sharedManager] start];

            [WeChatGuardPanel install];

            NSLog(@"[WeChatGuard] Initialized successfully");
        });
    }
}
