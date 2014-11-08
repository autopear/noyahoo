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

//Notfication Center
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

//Weather app
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

    if (kCFCoreFoundationVersionNumber < 1140.10) {
        NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;

        if (bundleIdentifier && [bundleIdentifier isEqualToString:@"com.apple.weather"])
            ctrl.yahooButton.hidden = YES;
    }

    return ctrl;
}

- (void)yahooButtonPressed {
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;

    if (bundleIdentifier && [bundleIdentifier isEqualToString:@"com.apple.weather"])
        return;

    %orig;
}

- (void)loadView {
    %orig;

    if (kCFCoreFoundationVersionNumber >= 1140.10) {
        NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
        if (bundleIdentifier && [bundleIdentifier isEqualToString:@"com.apple.weather"]) {

            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(twcButtonPressed)];
            [self.infoButton addGestureRecognizer:longPress];
            [longPress release];

            self.twcButton.hidden = YES;
        }
    }
}

%end

//Stocks app

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
