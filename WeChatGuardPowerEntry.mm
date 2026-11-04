#import <Foundation/Foundation.h>
#import "WeChatGuardPowerManager.h"

__attribute__((constructor))
static void WeChatGuardPowerInitialize(void) {

    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[WeChatGuardPowerManager sharedManager] start];
        });
    }
}
