#import <UIKit/UIKit.h>
#import <CaptainHook/CaptainHook.h>

#define YAHOO_ID @"com.apple.attributionweeapp.bundle"

@interface WAWeatherCollectionFooterViewCell {
	UIButton *_theWeatherChannelButton;
	UIButton *_yahooButton;
}
@property(retain, nonatomic) UIButton *theWeatherChannelButton;
@property(retain, nonatomic) UIButton *yahooButton;
- (void)_yahooLogoTapped:(id)tapped;
- (void)_twcLogoTapped:(id)tapped;
- (WAWeatherCollectionFooterViewCell *)initWithFrame:(CGRect)frame;
@end

@interface WATouchButton : UIButton
@end

@interface TabController {
	WATouchButton *_yahooButton;
}
@property(retain, nonatomic) WATouchButton *yahooButton;
- (void)yahooButtonPressed;
- (TabController *)initWithFrame:(CGRect)frame withScrollIndicator:(BOOL)scrollIndicator;
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
- (StocksStatusView *)initWithStocksView:(id)stocksView;
- (void)_viewStockButtonPressed;
- (void)_infoButtonPressed;
@end


//Notfication Center
%hook SBWidgetViewControllerHost

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

//Weather app
%hook WAWeatherCollectionFooterViewCell

- (WAWeatherCollectionFooterViewCell *)initWithFrame:(CGRect)frame {
    WAWeatherCollectionFooterViewCell *cell = %orig(frame);

    cell.theWeatherChannelButton.hidden = YES;
    cell.yahooButton.hidden = YES;
    
    return cell;
}

-(void)_yahooLogoTapped:(id)tapped {
    return;
}

-(void)_twcLogoTapped:(id)tapped {
    return;
}

%end

%hook TabController

- (TabController *)initWithFrame:(CGRect)frame withScrollIndicator:(BOOL)scrollIndicator {
    TabController *ctrl = %orig(frame, scrollIndicator);

    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    
    if (bundleIdentifier && [bundleIdentifier isEqualToString:@"com.apple.weather"]) {
        ctrl.yahooButton.hidden = YES;
    }

    return ctrl;
}

- (void)yahooButtonPressed {
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    
    if (bundleIdentifier && [bundleIdentifier isEqualToString:@"com.apple.weather"]) {
        return;
    }

    %orig;
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

    UIButton *infoButton = CHIvar(view, _infoButton, UIButton *);
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_viewStockButtonPressed)];
    [infoButton addGestureRecognizer:longPress];
    [longPress release];
    
    UIButton *viewButton = CHIvar(view, _viewStockButton, UIButton *);
    viewButton.hidden = YES;
    
    return view;
}

%end
