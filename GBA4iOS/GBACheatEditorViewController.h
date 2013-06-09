//
//  GBACheatViewController.h
//  GBA4iOS
//
//  Created by Will Stafford on 1/29/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBAEmulatorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GBACheatIOFramework.h"

@interface GBACheatEditorViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
    IBOutlet UITextView *codeInputView;
    IBOutlet UITextField *cheatTitleField;
    IBOutlet UISegmentedControl *versionController;
    IBOutlet UIBarButtonItem *saveButton;
    UIAlertView *rotateAlert;
    CGRect origFrame;
    NSString *romPath;
    NSString *romName;
    int codeLength;
    int codeSegments;
    bool v3;
    
    NSString *rawCode;
    bool isNew;
    int cheatIndex;
    GBACheat *existingCheat;
}

@property (nonatomic, retain) NSString *romPath;
@property bool isNew;
@property int cheatIndex;

- (IBAction)save:(id)sender;
- (IBAction)changeType:(id)sender;
- (id)initNewCheat:(NSString *)romPath1;
- (id)initExistingCheat:(NSString *)romPath1 cheatIndex:(int)cheatIndex1;
@end
