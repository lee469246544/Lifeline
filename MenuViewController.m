//
//  MenuViewController.m
//  Lifeline
//
//  Created by 1 on 15/10/6.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        fileManager = [FileManager manager];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollView = [UIScrollView new];
    scrollView.backgroundColor = [UIColor iOS7pinkColor];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.offset(0);
        make.bottom.offset(0);
        make.right.offset(0);
    }];
    
    UIView *container = [UIView new];
    container.tag = 1;
    [scrollView addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
        make.bottom.offset(0);
    }];
    if (fileManager.parserState != 2) {
        [fileManager addObserver:self forKeyPath:@"parserState" options:NSKeyValueObservingOptionNew context:nil];
    }else{
        [self startLaunch:@"launch"];
    }

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (fileManager.parserState != 2 ) {
        return;
    }
    [self startLaunch:@"launch"];
    [fileManager removeObserver:self forKeyPath:@"parserState"];
}
- (void)startLaunch:(NSString *)eventHeader{
    self.currentIndex ++;
    
    if (eventHeader) {
        NSString *predicateString = [NSString stringWithFormat:@"eventHeader like '%@'",eventHeader];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        
        NSArray *launchs = [fileManager.events filteredArrayUsingPredicate:predicate];
        
        
        self.currentEvent = launchs[0];
        self.currentIndex = 0;
    }
    

    
    Event *event = self.currentEvent.eventDes[self.currentIndex];
    NSLog(@"%@ %d",self.currentEvent.eventHeader,event.type);
    if (event.type == 0) {
        [self showMessage:event.content];
        if (self.currentIndex < self.currentEvent.eventDes.count-1){
            [self performSelector:@selector(startLaunch:) withObject:nil afterDelay:0.5];
        }
    }else if (event.type == 3){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"回复消息" message:nil delegate:self cancelButtonTitle:event.value otherButtonTitles:event.value1, nil];
        [alertView show];
    
    }else if ( event.type == 5){
        [self startLaunch:event.content];
    }else if ( event.type == 6){
        [self showMessage:[NSString stringWithFormat:@"等待 %@",event.key]];
        [self performSelector:@selector(startLaunch:) withObject:event.value afterDelay:2];
    }else if (event.type == 4){
        if (self.currentIndex < self.currentEvent.eventDes.count-1)
        {
            [self startLaunch:nil];
        }
    }else if (event.type == 1){
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:event.value forKey:event.key];
        if (event.value1) {
            [userDefaults setObject:event.value1 forKey:event.key1];
        }
        [userDefaults synchronize];
        if (self.currentIndex < self.currentEvent.eventDes.count-1)
        {
            [self startLaunch:nil];
        }
    }



}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Event *event = self.currentEvent.eventDes[self.currentIndex];
    NSString *key = nil;
    if (buttonIndex == 0) {
        key = event.key;
        [self showMessage:event.value];
    }else{
        [self showMessage:event.value1];
        key =event.key1;
    }

    
    [self performSelector:@selector(startLaunch:) withObject:key afterDelay:0.5];

    
}

- (void)showMessage:(NSString *)message{

    CGSize size = CGSizeMake(200.0f, NSIntegerMax);
    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:17]};
    
    CGRect rect = [message boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dict context:nil];

    float height = rect.size.height+20.0f;
    

    UIView *container = [scrollView viewWithTag:1];
    UILabel *label = [UILabel new];
    label.text = message;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor blackColor];
    [container addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.offset(scrollView.contentSize.height);
        make.height.offset(height);
        make.width.offset (200);
        make.centerX.equalTo(scrollView.mas_centerX);

    }];

    float o = scrollView.contentSize.height - scrollView.frame.size.height+height;
    if (o<=0) {
        o=0;
    }
    
    [scrollView setContentOffset:CGPointMake(0, o) animated:YES];
    
    [container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(scrollView.contentSize.height+height);
        
    }];
    
}
@end
