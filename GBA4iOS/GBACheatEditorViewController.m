//
//  GBACheatViewController.m
//  GBA4iOS
//
//  Created by Will Stafford on 1/29/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import "GBACheatEditorViewController.h"

@interface GBACheatEditorViewController ()

@end

@implementation GBACheatEditorViewController
@synthesize romPath, isNew, cheatIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initNewCheat:(NSString *)romPath1 {
    self = [super init];
    rawCode = @"";
    isNew = true;
    romPath = romPath1;
    romName = [[romPath lastPathComponent] stringByDeletingPathExtension];
    v3 = true;
    return self;
}

- (id)initExistingCheat:(NSString *)romPath1 cheatIndex:(int)cheatIndex1 {
    self = [super init];
    isNew = false;
    romPath = romPath1;
    romName = [[romPath lastPathComponent] stringByDeletingPathExtension];
    cheatIndex = cheatIndex1;
    existingCheat = [GBACheatIOFramework cheatsForRomName:romName][cheatIndex];
    v3 = existingCheat.v3;
    return self;
}

- (void)setupBaseView {
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    saveButton.enabled = [self shouldSave];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    cheatTitleField.delegate = self;
    if (isNew) {
        self.title = @"New Cheat";
    } else {
        self.title = @"Edit Cheat";
        rawCode = [self getHexString:existingCheat.code];
        codeInputView.text = existingCheat.code;
        cheatTitleField.text = existingCheat.name;
        [versionController setSelectedSegmentIndex:v3 ? 0 : 1];
    }
    
    UIColor *borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.view.backgroundColor = codeInputView.backgroundColor;
    codeInputView.layer.masksToBounds = true;
    codeInputView.layer.borderColor = borderColor.CGColor;
    codeInputView.layer.borderWidth = 3.0f;
    codeInputView.layer.cornerRadius = 5.0f;
    codeInputView.delegate = self;
    
    cheatTitleField.layer.masksToBounds = true;
    cheatTitleField.layer.borderColor = borderColor.CGColor;
    cheatTitleField.layer.borderWidth = 3.0f;
    cheatTitleField.layer.cornerRadius = 5.0f;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        rotateAlert = [[UIAlertView alloc] initWithTitle:@"Rotate Device" message:@"Please rotate your device to portrait." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [rotateAlert show];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    origFrame = codeInputView.frame;
    [self setCodeInputViewFrame];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        [rotateAlert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait && ![rotateAlert isVisible]) {
        rotateAlert = [[UIAlertView alloc] initWithTitle:@"Rotate Device" message:@"Please rotate your device to portrait." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [rotateAlert show];
    }
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        codeInputView.frame = CGRectMake(codeInputView.frame.origin.x, codeInputView.frame.origin.y, codeInputView.frame.size.width, codeInputView.frame.size.height-keyboardFrameBeginRect.size.height);
    }];
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        codeInputView.frame = CGRectMake(codeInputView.frame.origin.x, codeInputView.frame.origin.y, codeInputView.frame.size.width, codeInputView.frame.size.height+keyboardFrameBeginRect.size.height);
    }];
}

- (void)updateCodeInput {
    if (codeInputView.text.length == 0) {
        return;
    }
    [self textView:codeInputView shouldChangeTextInRange:NSMakeRange(codeInputView.selectedRange.location, 0) replacementText:@""];
}

- (void)setCodeInputViewFrame {
    if (v3) {
        codeLength = 8;
        codeSegments = 2;
        [self updateCodeInput];
        codeInputView.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y, origFrame.size.width, codeInputView.frame.size.height);
        return;
    } else { // v1
        codeLength = 12;
        codeSegments = 1;
    }
    
    [self updateCodeInput];
    
    NSMutableString *line = [NSMutableString new];
    int charCount = codeLength*codeSegments+(codeSegments-1);
    for (int x = 0; x < charCount+(codeSegments*2); x++) {
        [line appendString:@"#"];
    }
    
    CGSize size = [line sizeWithFont:codeInputView.font];
    CGPoint center = codeInputView.center;
    CGPoint origin = CGPointMake(center.x-(size.width/2), codeInputView.frame.origin.y);
    [codeInputView setFrame:CGRectMake(origin.x, origin.y, size.width, codeInputView.frame.size.height)];
}

- (void)save {
    GBACheat *cheat = [GBACheat cheatWithName:cheatTitleField.text code:codeInputView.text enabled:(!existingCheat || existingCheat.enabled) isV3:v3];
    
    if (isNew) {
        [GBACheatIOFramework addCheat:cheat toRomWithName:romName];
    } else {
        [GBACheatIOFramework replaceCheatAtIndex:cheatIndex withCheat:cheat forRomWithName:romName];
    }
}

- (bool)shouldSave {
    return rawCode.length > 0 && cheatTitleField.text.length > 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBaseView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)save:(id)sender {
    [self save];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeType:(UISegmentedControl *)sender {
    v3 = [[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] rangeOfString:@"v3"].location != NSNotFound;
    [self setCodeInputViewFrame];
}

- (bool)isHexCharacter:(char)character {
    NSString *hex = @"0123456789ABCDEF";
    bool flag = false;
    for (int z = 0; z < hex.length; z++) {
        if ([hex characterAtIndex:z] == character) {
            flag = true;
            break;
        }
    }
    
    return flag;
}

- (NSString *)getHexString:(NSString *)string {
    NSString *hexString = @"";
    
    for (int x = 0; x < string.length; x++) {
        char cCharacter = [string characterAtIndex:x];
        switch (cCharacter) {
            case 'a':
                cCharacter = 'A';
                break;
                
            case 'b':
                cCharacter = 'B';
                break;
                
            case 'c':
                cCharacter = 'C';
                break;
                
            case 'd':
                cCharacter = 'D';
                break;
                
            case 'e':
                cCharacter = 'E';
                break;
                
            case 'f':
                cCharacter = 'F';
                break;
                
            default:
                break;
        }
        
        NSString *character = [NSString stringWithFormat:@"%c", cCharacter];
        
        bool flag = [self isHexCharacter:cCharacter];
        
        if (flag) {
            hexString = [hexString stringByAppendingString:character];
        }
    }
    
    return hexString;
}

- (void)codeInputViewDidReturn {
    
}

// The following code will fuck you in the brain. But dat shit works.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView != codeInputView) {
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [codeInputView resignFirstResponder];
    }
    
    NSMutableAttributedString *styledString = nil;
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    [para setLineBreakMode:NSLineBreakByClipping];
    UIFont *font = [UIFont fontWithName:@"Courier" size:18.0f];
    
    NSRange selRng;
    NSRange oldSelRng = textView.selectedRange;
    if ([self getHexString:text].length > 0) {
        selRng = NSMakeRange(range.location+text.length, 0);
    } else if (range.location != textView.selectedRange.location) {
        selRng = NSMakeRange(range.location, 0);
    } else {
        selRng = NSMakeRange(textView.selectedRange.location, 0);
    }
    
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    saveButton.enabled = newText.length > 0 && cheatTitleField.text.length > 0; // Fixes save button being disabled.
    if (newText.length == 0) {
        return YES;
    }
    
    rawCode = [self getHexString:newText];
    
    if (rawCode.length < codeLength) {
        styledString = [[NSMutableAttributedString alloc] initWithString:rawCode];
        [styledString beginEditing];
        [styledString addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, styledString.length)];
        [styledString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, styledString.length)];
        [styledString endEditing];
        
        textView.attributedText = styledString;
        textView.selectedRange = selRng;
        return NO;
    }
    
    newText = @"";
    
    for (int x = 0; x < rawCode.length; x++) {
        newText = [newText stringByAppendingFormat:@"%c", [rawCode characterAtIndex:x]];
        if ((x+1)%(codeLength*codeSegments) == 0 && x != 0 && x != rawCode.length-1) {
            newText = [newText stringByAppendingString:@"\n"];
        } else if ((x+1)%codeLength == 0 && x != 0 && x != rawCode.length-1) {
            newText = [newText stringByAppendingString:@" "];
        }
    }
    
    bool flag = ((newText.length != 0 && text.length == 1 && [self getHexString:text].length > 0 && newText.length > oldSelRng.location) && ([newText characterAtIndex:oldSelRng.location] == ' ' || [newText characterAtIndex:oldSelRng.location] == '\n'));
    
    if (flag) {
        // Basically: if it wasn't a backspace, and the next character was a space or newline...
        selRng = NSMakeRange(selRng.location+1, selRng.length);
    }
    
    styledString = [[NSMutableAttributedString alloc] initWithString:newText];
    [styledString beginEditing];
    [styledString addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, styledString.length)];
    [styledString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, styledString.length)];
    [styledString endEditing];
    
    textView.attributedText = styledString;
    textView.selectedRange = selRng;
    return NO;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (textView != codeInputView) {
        return;
    }
    
    if (textView.text.length == 0) {
        return;
    }
    
    if (textView.selectedRange.length > 0 || textView.selectedRange.location-1 > textView.selectedRange.location) {
        return;
    }
    if ([textView.text characterAtIndex:textView.selectedRange.location-1] == ' ') {
        textView.selectedRange = NSMakeRange(textView.selectedRange.location-1, textView.selectedRange.length);
    } else if ([textView.text characterAtIndex:textView.selectedRange.location-1] == '\n') {
        textView.selectedRange = NSMakeRange(textView.selectedRange.location-1, textView.selectedRange.length);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    saveButton.enabled = [self shouldSave];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
