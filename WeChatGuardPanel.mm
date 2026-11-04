#import "WeChatGuardPanel.h"
#import "WeChatGuardPowerManager.h"

@interface WeChatGuardPanel ()

@property (nonatomic, strong) UIWindow *panelWindow;
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *backgroundLabel;
@property (nonatomic, strong) UILabel *batteryLabel;
@property (nonatomic, strong) UILabel *thermalLabel;
@property (nonatomic, strong) UISwitch *powerSwitch;
@property (nonatomic, assign) BOOL panelVisible;

@end

@implementation WeChatGuardPanel

+ (instancetype)sharedPanel {
    static WeChatGuardPanel *panel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        panel = [[WeChatGuardPanel alloc] init];
    });
    return panel;
}

+ (void)install {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedPanel] installUI];
    });
}

+ (void)showPanel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedPanel] showUI];
    });
}

+ (void)hidePanel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedPanel] hideUI];
    });
}

- (void)installUI {
    if (self.panelWindow) return;

    UIWindowScene *scene = nil;

    for (UIScene *item in
         UIApplication.sharedApplication.connectedScenes) {
        if (item.activationState ==
            UISceneActivationStateForegroundActive &&
            [item isKindOfClass:[UIWindowScene class]]) {
            scene = (UIWindowScene *)item;
            break;
        }
    }

    if (!scene) return;

    self.panelWindow =
        [[UIWindow alloc] initWithWindowScene:scene];

    self.panelWindow.frame = UIScreen.mainScreen.bounds;
    self.panelWindow.windowLevel = UIWindowLevelAlert - 1;
    self.panelWindow.backgroundColor = UIColor.clearColor;

    UIViewController *controller =
        [[UIViewController alloc] init];

    controller.view.backgroundColor = UIColor.clearColor;
    self.panelWindow.rootViewController = controller;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(
        UIScreen.mainScreen.bounds.size.width - 66,
        UIScreen.mainScreen.bounds.size.height * 0.55,
        52, 52
    );

    button.backgroundColor =
        [UIColor colorWithRed:0.12 green:0.43 blue:0.88 alpha:0.95];

    button.layer.cornerRadius = 26;
    button.layer.borderWidth = 1;
    button.layer.borderColor =
        UIColor.whiteColor.CGColor;

    [button setTitle:@"WG" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    button.titleLabel.font =
        [UIFont boldSystemFontOfSize:16];

    [button addTarget:self
               action:@selector(togglePanel)
     forControlEvents:UIControlEventTouchUpInside];

    [controller.view addSubview:button];
    self.floatingButton = button;

    UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(dragButton:)];

    [button addGestureRecognizer:pan];

    [self buildCard];

    self.panelWindow.hidden = NO;

    NSLog(@"[WeChatGuard] Floating button installed");
}

- (void)buildCard {
    UIView *card = [[UIView alloc]
                    initWithFrame:CGRectMake(0, 0, 280, 230)];

    card.backgroundColor =
        [UIColor colorWithWhite:0.10 alpha:0.97];

    card.layer.cornerRadius = 18;
    card.layer.borderWidth = 1;
    card.layer.borderColor =
        [UIColor colorWithWhite:1 alpha:0.2].CGColor;

    UILabel *title = [[UILabel alloc]
                      initWithFrame:CGRectMake(18, 14, 240, 30)];

    title.text = @"WeChatGuard";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:20];
    [card addSubview:title];

    self.powerSwitch = [[UISwitch alloc]
                        initWithFrame:CGRectMake(210, 55, 50, 30)];

    self.powerSwitch.on = YES;

    [self.powerSwitch addTarget:self
                         action:@selector(powerChanged:)
               forControlEvents:UIControlEventValueChanged];

    [card addSubview:self.powerSwitch];

    UILabel *powerTitle = [[UILabel alloc]
                           initWithFrame:CGRectMake(18, 55, 180, 30)];

    powerTitle.text = @"省电监测";
    powerTitle.textColor = UIColor.whiteColor;
    powerTitle.font = [UIFont systemFontOfSize:16];
    [card addSubview:powerTitle];

    self.backgroundLabel =
        [self makeLabelAtY:100 text:@"后台状态：检测中"];

    self.batteryLabel =
        [self makeLabelAtY:137 text:@"低电量模式：检测中"];

    self.thermalLabel =
        [self makeLabelAtY:174 text:@"设备热状态：检测中"];

    [card addSubview:self.backgroundLabel];
    [card addSubview:self.batteryLabel];
    [card addSubview:self.thermalLabel];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(238, 8, 32, 32);
    [close setTitle:@"×" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor
                forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:25];

    [close addTarget:self
              action:@selector(hideUI)
    forControlEvents:UIControlEventTouchUpInside];

    [card addSubview:close];

    self.cardView = card;
    card.hidden = YES;

    [self.panelWindow.rootViewController.view addSubview:card];
}

- (UILabel *)makeLabelAtY:(CGFloat)y text:(NSString *)text {
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectMake(18, y, 245, 26)];

    label.text = text;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:14];

    return label;
}

- (void)togglePanel {
    if (self.panelVisible) {
        [self hideUI];
    } else {
        [self showUI];
    }
}

- (void)showUI {
    if (!self.panelWindow) {
        [self installUI];
    }

    if (!self.panelWindow) return;

    self.panelVisible = YES;
    self.cardView.hidden = NO;

    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;

    CGFloat x = (width - 280) / 2;
    CGFloat y = (height - 230) / 2;

    self.cardView.frame = CGRectMake(x, y, 280, 230);

    [self refreshStatus];
}

- (void)hideUI {
    self.panelVisible = NO;
    self.cardView.hidden = YES;
}

- (void)dragButton:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;

    CGPoint offset = [gesture translationInView:view.superview];

    view.center = CGPointMake(
        view.center.x + offset.x,
        view.center.y + offset.y
    );

    [gesture setTranslation:CGPointZero
                   inView:view.superview];
}

- (void)powerChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [[WeChatGuardPowerManager sharedManager] start];
    } else {
        [[WeChatGuardPowerManager sharedManager] stop];
    }

    NSLog(@"[WeChatGuard] Power monitoring: %@",
          sender.isOn ? @"ON" : @"OFF");

    [self refreshStatus];
}

- (void)refreshStatus {
    WeChatGuardPowerManager *manager =
        [WeChatGuardPowerManager sharedManager];

    self.backgroundLabel.text =
        manager.isInBackground ?
        @"后台状态：后台" : @"后台状态：前台";

    self.batteryLabel.text =
        manager.isLowPowerMode ?
        @"低电量模式：已开启" : @"低电量模式：未开启";

    self.thermalLabel.text =
        manager.isThermalLimited ?
        @"设备热状态：较高" : @"设备热状态：正常";
}

@end
