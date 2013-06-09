//
//  GBACheatViewController.h
//  GBA4iOS
//
//  Created by Will Stafford on 1/30/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBACheatEditorViewController.h" // So apparently Xcode won't import my types into headers...? FML

@interface GBACheatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UIViewController *newCheatController;
    UIViewController *cheatEditorController;
    NSString *romPath;
    NSString *romName;
    NSMutableArray *cheats;
    IBOutlet UITableView *tableView;
    UIAlertView *rotateAlert;
}

@property (nonatomic, retain) NSString *romPath;

@end
