//
//  GBACheatViewController.m
//  GBA4iOS
//
//  Created by Will Stafford on 1/30/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import "GBACheatViewController.h"

@interface GBACheatViewController ()

@end

@implementation GBACheatViewController
@synthesize romPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *navBarTint = [UIColor colorWithRed:5.0/255 green:2.0/255 blue:21.0/255 alpha:.69];
    self.navigationController.navigationBar.tintColor = navBarTint;
    self.title = @"Cheats";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newCheat:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    romName = [GBACheatIOFramework romNameForRomAtPath:romPath];
    NSString *gameCheatFolder = [[GBACheatIOFramework cheatPathForRomName:romName] stringByDeletingLastPathComponent];
    NSString *cheatFolder = [gameCheatFolder stringByDeletingLastPathComponent];
    
    bool cheatFolderExists = [[NSFileManager defaultManager] fileExistsAtPath:cheatFolder];
    bool gameCheatFolderExists = [[NSFileManager defaultManager] fileExistsAtPath:gameCheatFolder];
    
    if (!cheatFolderExists) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cheatFolder withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
            return;
        }
    }
    
    if (!gameCheatFolderExists) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:gameCheatFolder withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
            return;
        }
    }
    
    cheats = [NSMutableArray new];
    
    if ([GBACheatIOFramework cheatsExistForRomWithName:romName]) {
        cheats = [GBACheatIOFramework cheatsForRomName:romName].mutableCopy;
    }
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        rotateAlert = [[UIAlertView alloc] initWithTitle:@"Rotate Device" message:@"Please rotate your device to portrait." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [rotateAlert show];
    }
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

- (void)viewWillAppear:(BOOL)animated {
    if ([GBACheatIOFramework cheatsExistForRomWithName:romName]) {
        cheats = [GBACheatIOFramework cheatsForRomName:romName].mutableCopy;
    }
    [tableView reloadData];
}

- (void)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)newCheat:(id)sender {
    newCheatController = [[GBACheatEditorViewController alloc] initNewCheat:romPath];
    [self.navigationController pushViewController:newCheatController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)enabledSwitchPressed:(id)sender {
    int index = ((UIView *) sender).tag; // Fixes issue where you could not disable any cheats except for the first one.
    ((GBACheat *) cheats[index]).enabled = ((UISwitch *) sender).isOn;
    [GBACheatIOFramework replaceCheatAtIndex:index withCheat:cheats[index] forRomWithName:romName];
}

// TABLE VIEW STUFF

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cheats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    GBACheat *cheat = cheats[indexPath.row];
    cell.textLabel.text = cheat.name;
    
    UISwitch *enabledSwitch = [UISwitch new];
    enabledSwitch.frame = CGRectMake(cell.frame.size.width-enabledSwitch.frame.size.width-5, cell.frame.size.height/2-enabledSwitch.frame.size.height/2, enabledSwitch.frame.size.width, enabledSwitch.frame.size.height);
    [enabledSwitch setOn:cheat.enabled];
    enabledSwitch.tag = indexPath.row;
    [enabledSwitch addTarget:self action:@selector(enabledSwitchPressed:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:enabledSwitch];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    cheatEditorController = [[GBACheatEditorViewController alloc] initExistingCheat:romPath cheatIndex:indexPath.row];
    [self.navigationController pushViewController:cheatEditorController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [cheats removeObjectAtIndex:indexPath.row];
        [GBACheatIOFramework removeCheatAtIndex:indexPath.row forRomWithName:romName];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
