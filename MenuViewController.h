//
//  MenuViewController.h
//  Lifeline
//
//  Created by 1 on 15/10/6.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
{
    FileManager *fileManager;
    UIScrollView *scrollView;
    
}
@property (nonatomic,strong) EventModel *currentEvent;
@property (nonatomic,assign) int currentIndex;
@end
