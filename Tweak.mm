#import <UIKit/UIKit.h>
#import <CaptainHook/CaptainHook.h>

#define YAHOO_ID @"com.apple.attributionweeapp.bundle"

@interface WATouchButton : UIButton
@end

@interface WAWeatherCollectionFooterViewCell {
	UIButton *_theWeatherChannelButton; //iOS 7 & 8
	UIButton *_yahooButton; //iOS 7
    WATouchButton* _addButton; //iOS 8
}
@property(retain, nonatomic) UIButton *theWeatherChannelButton; //iOS 7 & 8
@property(retain, nonatomic) UIButton *yahooButton; //iOS 7
@property(retain, nonatomic) WATouchButton* addButton; //iOS 8
- (void)_yahooLogoTapped:(id)tapped; //iOS 7
- (void)_twcLogoTapped:(id)tapped; //iOS 7 & 8
- (WAWeatherCollectionFooterViewCell *)initWithFrame:(CGRect)frame;
@end

@interface TabController {
	WATouchButton *_yahooButton; //iOS 7
    WATouchButton* _infoButton; //iOS 8
    WATouchButton* _twcButton; //iOS 8
}
@property(retain, nonatomic) WATouchButton *yahooButton; //iOS 7
@property(retain, nonatomic) WATouchButton* twcButton; //iOS 8
@property(retain, nonatomic) WATouchButton* infoButton; //iOS 8
- (void)yahooButtonPressed; //iOS 7
- (TabController *)initWithFrame:(CGRect)frame withScrollIndicator:(BOOL)scrollIndicator; //iOS 7
- (TabController *)init; //iOS 8
- (void)twcButtonPressed; //iOS 8
- (void)infoButtonPressed; //iOS 8
- (void)loadView; //iOS 8
@end

@interface StocksBacksideView : UIView {
	UIButton *_logoView;
}
- (StocksBacksideView *)initWithFrame:(CGRect)frame;
- (void)_logoClicked;
@end

@interface StocksStatusView : UIView {
	UIButton *_infoButton;
	UIButton *_viewStockButton;
}
- (StocksStatusView *)initWithStocksView:(id)stocksView; //iOS 7
- (void)_viewStockButtonPressed;
- (void)_infoButtonPressed;
- (StocksStatusView *)initWithFrame:(CGRect)frame; //iOS 8
@end

@interface FullScreenWorldClockCollectionController : UIViewController {
    UIButton* _yahooButton; //iOS 7
    UIButton *_twcButton; //iOS 8
}
@property(readonly, assign, nonatomic) UIButton* yahooButton; //iOS 7
@property(readonly, nonatomic) UIButton *twcButton; //iOS 8
- (void)yahooButtonPressed; //iOS 7
- (void)twcButtonPressed; //iOS 8
- (void)viewDidLayoutSubviews;
- (void)setShowingInfo:(BOOL)show;
@end

@interface WeatherAttributionView : UIView {
    UIButton* _twcButton;
    UIButton* _yahooButton; //iOS 7
}
@property(retain, nonatomic) UIButton* yahooButton; //iOS 7
@property(retain, nonatomic) UIButton* twcButton;
- (void)_yahooLogoTapped; //iOS 7
- (void)_twcLogoTapped;
- (WeatherAttributionView *)initWithFrame:(CGRect)frame;
@end

@interface WorldClockMapView : UIView {
    UIButton* _yahooButton; //iOS 7
    UIButton *_twcButton; //iOS 8
}
- (void)yahooButtonPressed;  //iOS 7
- (void)twcButtonPressed; //iOS 8
- (WorldClockMapView *)initWithFrame:(CGRect)frame;
@end

//Notfication Center
%group SB_HOOK
%hook SBWidgetViewControllerHost //iOS 7 only

+ (BOOL)canLoadWidgetWithIdentifier:(NSString *)identifier forWidgetIdiom:(int)widgetIdiom bundlePath:(NSString *)path {
    if ([identifier isEqualToString:YAHOO_ID])
        return NO;
    else
        return %orig(identifier, widgetIdiom, path);
}

+ (SBWidgetViewControllerHost *)widgetViewControllerWithIdentifier:(NSString *)identifier forWidgetIdiom:(int)widgetIdiom bundlePath:(NSString *)path {
    if ([identifier isEqualToString:YAHOO_ID])
        return nil;
    else
        return %orig(identifier, widgetIdiom, path);
}

- (SBWidgetViewControllerHost *)initWithWidgetIdentifier:(NSString *)widgetIdentifier forWidgetIdiom:(int)widgetIdiom bundlePath:(NSString *)path {
    if ([widgetIdentifier isEqualToString:YAHOO_ID])
        return nil;
    else
        return %orig(widgetIdentifier, widgetIdiom, path);
}

%end

%hook SBAttributionWrapperViewController //iOS 8 only

+ (SBAttributionWrapperViewController *)_newAttributionViewController {
    return nil;
}

%end

%end

//Weather app
%group WEATHER_HOOK

%hook WAWeatherCollectionFooterViewCell

- (WAWeatherCollectionFooterViewCell *)initWithFrame:(CGRect)frame {
    WAWeatherCollectionFooterViewCell *cell = %orig(frame);

    cell.theWeatherChannelButton.hidden = YES;
    if (kCFCoreFoundationVersionNumber < 1140.10)
        cell.yahooButton.hidden = YES;

    return cell;
}

- (void)_yahooLogoTapped:(id)tapped {
    return;
}

- (void)_twcLogoTapped:(id)tapped {
    return;
}

%end

%hook TabController

- (TabController *)initWithFrame:(CGRect)frame withScrollIndicator:(BOOL)scrollIndicator {
    TabController *ctrl = %orig(frame, scrollIndicator);

    if (kCFCoreFoundationVersionNumber < 1140.10)
        ctrl.yahooButton.hidden = YES;

    return ctrl;
}

- (void)yahooButtonPressed {
    %orig;
}

- (void)loadView {
    %orig;

    if (kCFCoreFoundationVersionNumber >= 1140.10) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(twcButtonPressed)];
        [self.infoButton addGestureRecognizer:longPress];
        [longPress release];
        self.twcButton.hidden = YES;
    }
}

%end

%end

//Stocks app
%group STOCKS_HOOK

%hook StocksBacksideView

- (StocksBacksideView *)initWithFrame:(CGRect)frame {
    StocksBacksideView *view = %orig(frame);

    UIButton *logoButton = CHIvar(view, _logoView, UIButton *);
    logoButton.hidden = YES;

    return view;
}

- (void)_logoClicked {
    return;
}

%end

%hook StocksStatusView

- (StocksStatusView *)initWithStocksView:(id)stocksView {
    StocksStatusView *view = %orig(stocksView);

    if (kCFCoreFoundationVersionNumber < 1140.10) {
        //iOS 7
        UIButton *infoButton = CHIvar(view, _infoButton, UIButton *);
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:view action:@selector(_viewStockButtonPressed)];
        [infoButton addGestureRecognizer:longPress];
        [longPress release];

        UIButton *viewButton = CHIvar(view, _viewStockButton, UIButton *);
        viewButton.hidden = YES;
    }

    return view;
}

- (StocksStatusView *)initWithFrame:(CGRect)frame {
    StocksStatusView *view = %orig(frame);

    if (kCFCoreFoundationVersionNumber >= 1140.10) {
        //iOS 8
        UIButton *infoButton = CHIvar(view, _infoButton, UIButton *);
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:view action:@selector(_viewStockButtonPressed)];
        [infoButton addGestureRecognizer:longPress];
        [longPress release];

        UIButton *viewButton = CHIvar(view, _viewStockButton, UIButton *);
        viewButton.hidden = YES;
    }

    return view;
}

%end

%end

//Clock app
%group CLOCK_HOOK

%hook FullScreenWorldClockCollectionController

- (void)yahooButtonPressed {
    return;
}

- (void)twcButtonPressed {
    return;
}

- (void)viewDidLayoutSubviews {
    %orig;
    if (kCFCoreFoundationVersionNumber < 1140.10)
        self.yahooButton.hidden = YES;
    else
        self.twcButton.hidden = YES;
}

- (void)setShowingInfo:(BOOL)show {
    %orig(show);
    if (show) {
        if (kCFCoreFoundationVersionNumber < 1140.10)
            self.yahooButton.hidden = YES;
        else
            self.twcButton.hidden = YES;
    }
}

%end

%hook WeatherAttributionView

- (WeatherAttributionView *)initWithFrame:(CGRect)frame {
    WeatherAttributionView *view = %orig(frame);
    if (kCFCoreFoundationVersionNumber < 1140.10)
        view.yahooButton.hidden = YES;
    view.twcButton.hidden = YES;
    return view;
}

- (void)_yahooLogoTapped {
    return;
}

- (void)_twcLogoTapped {
    return;
}

%end

%hook WorldClockMapView

- (WorldClockMapView *)initWithFrame:(CGRect)frame {
    WorldClockMapView *view = %orig(frame);
    UIButton *logoButton = nil;
    if (kCFCoreFoundationVersionNumber < 1140.10)
        logoButton = CHIvar(view, _yahooButton, UIButton *);
    else
        logoButton = CHIvar(view, _twcButton, UIButton *);
    if (logoButton)
        logoButton.hidden = YES;
    return view;
}

- (void)yahooButtonPressed {
    return;
}

- (void)twcButtonPressed {
    return;
}

%end

%end

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    if ([bundleIdentifier length] > 0) {
        if ([bundleIdentifier isEqualToString:@"com.apple.springboard"])
            %init(SB_HOOK);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [bundleIdentifier isEqualToString:@"com.apple.mobiletimer"])
            %init(CLOCK_HOOK);
        if ([bundleIdentifier isEqualToString:@"com.apple.stocks"])
            %init(STOCKS_HOOK);
        if ([bundleIdentifier isEqualToString:@"com.apple.weather"])
            %init(WEATHER_HOOK);
    }

    [pool release];
}
