// Tweak.m — плавающее визуальное меню (без функций)
#import <UIKit/UIKit.h>

#define MENU_W     260.0
#define MENU_HEAD  44.0
#define MENU_FULL  320.0
#define PAGE_Y     52.0

#define COL_BG     [UIColor colorWithRed:0.078 green:0.086 blue:0.110 alpha:0.95]
#define COL_INK    [UIColor colorWithRed:0.078 green:0.086 blue:0.110 alpha:1.0]
#define COL_ACCENT [UIColor colorWithRed:0.949 green:0.702 blue:0.239 alpha:1.0]
#define COL_TEXT   [UIColor colorWithWhite:0.93 alpha:1.0]
#define COL_LINE   [UIColor colorWithWhite:1.0 alpha:0.10]

@interface XMMenuView : UIView
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UIButton *collapseBtn;
@property (nonatomic, strong) NSArray<UIView *> *pages;
@property (nonatomic, assign) BOOL collapsed;
@end

@implementation XMMenuView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(30, 100, MENU_W, MENU_FULL)];
    if (!self) return nil;

    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    self.backgroundColor = COL_BG;
    self.layer.cornerRadius = 18;
    self.layer.borderWidth = 1;
    self.layer.borderColor = COL_LINE.CGColor;
    self.clipsToBounds = YES;

    // Шапка: за неё меню перетаскивается
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MENU_W - 50, MENU_HEAD)];
    [self addSubview:head];
    [head addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)]];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, MENU_W - 70, MENU_HEAD)];
    title.text = @"Меню";
    title.textColor = COL_TEXT;
    title.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [head addSubview:title];

    // Кнопка свернуть / развернуть
    self.collapseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.collapseBtn.frame = CGRectMake(MENU_W - 50, 0, 44, MENU_HEAD);
    self.collapseBtn.tintColor = COL_TEXT;
    [self.collapseBtn setImage:[UIImage systemImageNamed:@"chevron.up"] forState:UIControlStateNormal];
    [self.collapseBtn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.collapseBtn];

    // Линия между шапкой и содержимым
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, MENU_HEAD, MENU_W, 0.5)];
    line.backgroundColor = COL_LINE;
    [self addSubview:line];

    // Содержимое
    self.content = [[UIView alloc] initWithFrame:CGRectMake(0, MENU_HEAD, MENU_W, MENU_FULL - MENU_HEAD)];
    [self addSubview:self.content];

    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"Главная", @"Визуал", @"Прочее"]];
    seg.frame = CGRectMake(12, 10, MENU_W - 24, 32);
    seg.selectedSegmentIndex = 0;
    seg.selectedSegmentTintColor = COL_ACCENT;
    [seg setTitleTextAttributes:@{NSForegroundColorAttributeName: COL_TEXT,
                                  NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightMedium]}
                       forState:UIControlStateNormal];
    [seg setTitleTextAttributes:@{NSForegroundColorAttributeName: COL_INK,
                                  NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold]}
                       forState:UIControlStateSelected];
    [seg addTarget:self action:@selector(tab:) forControlEvents:UIControlEventValueChanged];
    [self.content addSubview:seg];

    self.pages = @[
        [self pageWithSwitches:@[@"Функция 1", @"Функция 2", @"Функция 3", @"Функция 4"] sliders:@[]],
        [self pageWithSwitches:@[@"Опция A", @"Опция B"] sliders:@[@"Параметр 1", @"Параметр 2"]],
        [self pageWithSwitches:@[@"Опция X"] sliders:@[@"Значение"]]
    ];
    for (UIView *p in self.pages) [self.content addSubview:p];
    [self tab:seg];

    return self;
}

- (UILabel *)label:(NSString *)text frame:(CGRect)f {
    UILabel *l = [[UILabel alloc] initWithFrame:f];
    l.text = text;
    l.textColor = COL_TEXT;
    l.font = [UIFont systemFontOfSize:15];
    return l;
}

- (UIView *)pageWithSwitches:(NSArray<NSString *> *)switches sliders:(NSArray<NSString *> *)sliders {
    UIView *page = [[UIView alloc] initWithFrame:CGRectMake(0, PAGE_Y, MENU_W, MENU_FULL - MENU_HEAD - PAGE_Y)];
    CGFloat y = 4;
    for (NSString *name in switches) {
        [page addSubview:[self label:name frame:CGRectMake(16, y, 160, 31)]];
        UISwitch *sw = [UISwitch new];
        sw.onTintColor = COL_ACCENT;
        sw.center = CGPointMake(MENU_W - 16 - sw.bounds.size.width / 2, y + 15.5);
        [page addSubview:sw];
        y += 44;
    }
    for (NSString *name in sliders) {
        [page addSubview:[self label:name frame:CGRectMake(16, y, 160, 20)]];
        UISlider *sl = [[UISlider alloc] initWithFrame:CGRectMake(16, y + 22, MENU_W - 32, 24)];
        sl.value = 0.5;
        sl.minimumTrackTintColor = COL_ACCENT;
        [page addSubview:sl];
        y += 56;
    }
    return page;
}

- (void)tab:(UISegmentedControl *)s {
    for (NSUInteger i = 0; i < self.pages.count; i++) {
        self.pages[i].hidden = (i != (NSUInteger)s.selectedSegmentIndex);
    }
}

- (void)toggle {
    self.collapsed = !self.collapsed;
    [self.collapseBtn setImage:[UIImage systemImageNamed:(self.collapsed ? @"chevron.down" : @"chevron.up")]
                      forState:UIControlStateNormal];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect f = self.frame;
        f.size.height = self.collapsed ? MENU_HEAD : MENU_FULL;
        self.frame = f;
        self.content.alpha = self.collapsed ? 0 : 1;
    }];
}

- (void)drag:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self.superview];
    self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
    [g setTranslation:CGPointZero inView:self.superview];
}

@end

// ---- Запуск: меню появляется через пару секунд после старта приложения ----

static UIWindow *FindWindow(void) {
    UIApplication *app = UIApplication.sharedApplication;
    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *w in ((UIWindowScene *)scene).windows) {
            if (w.isKeyWindow) return w;
        }
    }
    return app.windows.firstObject;
}

static void ShowMenu(void) {
    UIWindow *w = FindWindow();
    if (!w) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{ ShowMenu(); });
        return;
    }
    [w addSubview:[XMMenuView new]];
}

__attribute__((constructor))
static void MenuEntry(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{ ShowMenu(); });
}
