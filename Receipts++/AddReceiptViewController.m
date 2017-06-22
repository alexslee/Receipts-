//
//  AddReceiptViewController.m
//  Receipts++
//
//  Created by Alex Lee on 2017-06-21.
//  Copyright © 2017 Alex Lee. All rights reserved.
//

#import "AddReceiptViewController.h"

@interface AddReceiptViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *headerBackgroundView;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UITextField *amountField;

@property (weak, nonatomic) IBOutlet UITextField *descriptionField;

@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) NSMutableSet *checkedTags;

@end

@implementation AddReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.categoryTableView.delegate = self;
    self.categoryTableView.dataSource = self;
    self.categoryTableView.scrollEnabled = NO;
    self.checkedTags = [[NSMutableSet alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)cancelAdd:(UIButton *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)confirmAdd:(UIButton *)sender {
    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:self.managedObjectContext];
//
//    NSManagedObject *managedObject = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
//    [managedObject setValue:[NSNumber numberWithFloat:[self.amountField.text floatValue]] forKey:@"amount"];
//    
//    [managedObject setValue:self.descriptionField.text forKey:@"note"];

    Receipt *receipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:self.managedObjectContext];
    
    [receipt setValue:[NSNumber numberWithFloat:[self.amountField.text floatValue]] forKey:@"amount"];
    
    [receipt setValue:self.descriptionField.text forKey:@"note"];
    
    //NSSet *tagSet = [NSSet setWithArray:self.checkedTags];
    [receipt setTags:self.checkedTags];
    for (Tag *tag in self.checkedTags) {
        NSSet *existing = tag.receipts;
        NSMutableSet *replacement = [NSMutableSet setWithSet:existing];
        [replacement addObject:receipt];
        tag.receipts = replacement;
    }
    [receipt setTimeStamp:self.datePicker.date];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCategoryCell"];
    cell.textLabel.text = [self.tags objectAtIndex:indexPath.row].tagName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    UITableViewCellAccessoryType accessory = cell.accessoryType;
    cell.accessoryType = (accessory == UITableViewCellAccessoryCheckmark) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
//    cell.accessoryView.backgroundColor = [UIColor whiteColor];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        [self.checkedTags removeObject:[self.tags objectAtIndex:indexPath.row]];
    } else {
        [self.checkedTags addObject:[self.tags objectAtIndex:indexPath.row]];
    }
}

@end
