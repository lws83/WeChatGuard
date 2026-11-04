#import <Foundation/Foundation.h>
#import "WeChatGuardPowerManager.h"

__attribute__((constructor))
static void WeChatGuardPowerInitialize(void) {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[WeChatGuard] Diagnostic entry loaded");

            // 暂时不启动状态管理器
            // 暂时不创建悬浮窗口
            // 暂时不安装 WeChatGuardPanel
        });
    }
}
