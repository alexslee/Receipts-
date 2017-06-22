//
//  ViewController.m
//  Receipts++
//
//  Created by Alex Lee on 2017-06-21.
//  Copyright © 2017 Alex Lee. All rights reserved.
//

#import "ViewController.h"
#import "Receipts__+CoreDataModel.h"
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray<Tag *> *tags;
@property (strong, nonatomic) NSMutableArray *receipts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController
@synthesize fetchedResultsController = _fetchedResultsController;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    //self.receipts = [[NSMutableArray alloc] init];
    //[self configureTags];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self grabTags];
    if ([self.tags count] == 0) {
        [self createTags];
    }
    [self grabReceipts];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addReceiptPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"addReceiptSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addReceiptSegue"]) {
        AddReceiptViewController *controller = (AddReceiptViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.tags = self.tags;
    }
}

#pragma mark - tags

-(void)grabTags {
    NSError *error = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext]];
    
    self.tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"goofed it: %@",error.localizedDescription);
        return;
    }
}

-(void)createTags {
    NSError *error = nil;

    Tag *firstTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
    firstTag.tagName = @"Business";
    
    Tag *secondTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
    secondTag.tagName = @"Family";
    
    Tag *thirdTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
    thirdTag.tagName = @"Personal";
    
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"goofed it: %@",error.localizedDescription);
        return;
    }
    //now that we have them created, grab them for use in the program
    [self grabTags];
}


//- (void)configureTags {
//    NSError *error = nil;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag"
//                                              inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    self.tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    
//    if (error || [self.tags count] == 0) {
//        Tag *firstTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
//        firstTag.tagName = @"Business";
//        Tag *secondTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
//        secondTag.tagName = @"Family";
//        Tag *thirdTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
//        thirdTag.tagName = @"Personal";
//        self.tags = [[NSArray alloc] initWithObjects: firstTag, secondTag, thirdTag, nil];
//    }
//}

#pragma mark - receipts

-(void)grabReceipts {
    NSMutableArray *results = [[NSMutableArray alloc]init];
    for (Tag *tag in self.tags) {
        [results addObject:[tag.receipts allObjects]];
    }
    self.receipts = [results copy];
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tags count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Tag *tag = self.tags[section];
    NSString *label = tag.tagName;
    return label;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.receipts[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReceiptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Receipt *receipt = [[self.receipts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];//[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.amountLabel.text = [NSString stringWithFormat:@"%.2lf",receipt.amount];
    cell.noteLabel.text = receipt.note;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithRed:52.0/255.0 green:188.0/255.0 blue:152.0/255.0 alpha:1.0];
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

//#pragma mark - Fetched results controller
//
//- (NSFetchedResultsController<Receipt *> *)fetchedResultsController {
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    NSFetchRequest<Receipt *> *fetchRequest = Receipt.fetchRequest;
//    
//    // Set the batch size to a suitable number.
//    [fetchRequest setFetchBatchSize:20];
//    
//    // Edit the sort key as appropriate.
//    //NSSortDescriptor *tagSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tags" ascending:YES];
//    NSSortDescriptor *noteSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"note" ascending:YES];
//    [fetchRequest setSortDescriptors:@[noteSortDescriptor]];
//    
//    // Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//    NSFetchedResultsController<Receipt *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"tags" cacheName:@"Master"];
//    
//    aFetchedResultsController.delegate = self;
//    
//    NSError *error = nil;
//    if (![aFetchedResultsController performFetch:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
//        abort();
//    }
//    
//    _fetchedResultsController = aFetchedResultsController;
//    return _fetchedResultsController;
//}
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        default:
//            return;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath {
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withReceipt:anObject];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withReceipt:anObject];
//            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}
//
//- (void)configureCell:(UITableViewCell *)cell withReceipt:(Receipt *)receipt {
//    cell.textLabel.text = receipt.note;
//}

@end
