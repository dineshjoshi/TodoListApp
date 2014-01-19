//
//  TableViewController.m
//  TodoListApp
//
//  Created by Dinesh Joshi on 1/18/14.
//  Copyright (c) 2014 Dinesh Joshi. All rights reserved.
//

#import "TableViewController.h"
#import "Cell.h"
#import <objc/runtime.h>


@interface TableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *todoListView;
@property (strong, nonatomic) IBOutlet UITableView *editButton;
@property (strong, nonatomic) IBOutlet UITableView *addButton;

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableArray *todoList;

- (void) storeTodoListToDisk;

@end

@implementation TableViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.todoList = [self.userDefaults objectForKey:@"TODOLIST"];
        if (!self.todoList) {
            self.todoList = [[NSMutableArray alloc] init];
            NSLog(@"initWithCoder: todoList was nil");
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    
    return self;
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }

    return self;
}

- (IBAction)onAddClick:(id)sender
{
    [self.todoList insertObject:@"" atIndex:0];
    [self.tableView reloadData];
    [self storeTodoListToDisk];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:path];
    Cell *todoCell = (Cell *) cell;
    
    [todoCell.todoText becomeFirstResponder];
}

- (IBAction)onEditClick:(id)sender
{
    if ([self.todoListView isEditing] == YES) {
        [self.todoListView setEditing:NO animated:YES];
        [self.view endEditing:YES];
        self.navigationItem.leftBarButtonItem.title = @"Edit";
    } else {
        [self.todoListView setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem.title = @"Done";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.todoList.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.todoList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
        [self storeTodoListToDisk];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.showsReorderControl=YES;
    
    Cell *todoCell = (Cell *)cell;
    todoCell.todoText.text = [self.todoList objectAtIndex:indexPath.row];
    objc_setAssociatedObject(todoCell.todoText, "INDEX_PATH", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC); // TODO: Use static variable for key
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger sourceRow = sourceIndexPath.row;
    NSUInteger destRow = destinationIndexPath.row;
    
    NSString *tempTodoText = [self.todoList objectAtIndex:sourceRow];
    
    [self.todoList removeObjectAtIndex:sourceRow];
    [self.todoList insertObject:tempTodoText atIndex:destRow];
    [tableView reloadData];
    [self storeTodoListToDisk];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Get the text from the text field and update the correct location
    // in the NSMutableArray data source
    NSIndexPath *cellPath = objc_getAssociatedObject(textField, "INDEX_PATH"); // TODO: Use static variable for key
    NSUInteger row = cellPath.row;
    [self.todoList setObject:textField.text atIndexedSubscript:row];
    [self.todoListView reloadData];
    [self storeTodoListToDisk];
}


- (void) storeTodoListToDisk {
    [self.userDefaults setObject:self.todoList forKey:@"TODOLIST"]; // TODO: Use static variable for key
    [self.userDefaults synchronize];
}

- (void)onAppTerminate:(NSNotification *)notification
{
    NSLog(@"onAppTerminate");
    [self storeTodoListToDisk];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}



@end











































