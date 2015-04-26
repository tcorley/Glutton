//
//  SettingsViewController.m
//  Glutton
//
//  Created by Tyler Corley on 4/23/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "SettingsViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}
- (IBAction)closeSettings:(id)sender {
    //maybe save everything at this point?
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addYelpName:(id)sender {
    //later, verify that they have inputed their user id
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Enter Yelp User ID"
                                message:@"I need your ID so that I can check to see when you post reviews. To get it, login to Yelp, go to your account page and retrieve your user ID from the URL. i.e.- for \"http://www.yelp.com/user_details?userid=vig233jnj4j46\", your user id would be \"vig233jnj4j46\""
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *go = [UIAlertAction
                         actionWithTitle:@"Okay"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             UITextField *userid = alert.textFields.firstObject;
                             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                             manager.responseSerializer = [AFJSONResponseSerializer serializer];
                             [manager GET:[NSString stringWithFormat:@"http://tcorley.info:5000/user/%@", userid.text] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 NSLog(@"%@", responseObject);
                                 [self notifyWithResult:@"Success" andMessage:[NSString stringWithFormat:@"Thanks, %@", [responseObject objectForKey:@"name" ]]];
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 [self notifyWithResult:@"Whoops💩" andMessage:@"Couldn't find that user id. Check to make sure that you entered it correctly!"];
                             }];
                             [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                             name:UITextFieldTextDidChangeNotification
                                                                           object:nil];
                         }];
    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:@"Maybe some other time"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Yelp UserID", @"UserIDPlaceholder");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(alertTextFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textField];
    }];
    [alert addAction:go];
    [alert addAction:no];
    
    go.enabled = NO;
    
    //set variable to check in NSUserDefaults
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *userid = alertController.textFields.firstObject;
        UIAlertAction *go = alertController.actions.firstObject;
        go.enabled = userid.text.length > 20;
    }
}

- (void)notifyWithResult:(NSString *)result andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:result message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
