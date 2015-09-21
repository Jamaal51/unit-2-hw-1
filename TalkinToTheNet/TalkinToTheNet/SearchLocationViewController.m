//
//  SearchLocationViewController.m
//  TalkinToTheNet
///Users/jsedayao/c4q/unit-2/week-2/unit-2-hw-1/TalkinToTheNet/TalkinToTheNet/SearchLocationViewController.m
//  Created by Jamaal Sedayao on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "APIManager.h"
#import "SearchResults.h"

@interface SearchLocationViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *searchResults;

@end

@implementation SearchLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchTextField.delegate = self;
    
}

#pragma mark API method

- (void) makeNewFourSquareAPIRequestWithSearchTerm:(NSString *)searchTerm
                                     callbackBlock:(void(^)())block{
    
    //1.searchTerm - comes from our parameter
    //2. url (media=music, term=searchTerm)
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=QSKOZ40KOU52BNTD0VMXIXHAKOCN0JPI1L4HUCLJXLCCCJ2X&client_secret=HBVWRR33ZVW44AUW21RYONHBPYR5KVMN000JQVV4F1HEWAMN&v=20150919&ll=40.7,-74&query=%@",searchTerm];
    
    //
    //https://api.foursquare.com/v2/venues/search
    //    ?client_id=CLIENT_ID
    //    &client_secret=CLIENT_SECRET
    //    &v=20150919
    //    &ll=40.7,-74
    //    &query=sushi
    
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSLog(@"%@", encodedString);
    
    NSURL *url = [NSURL URLWithString:encodedString];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if  (data!=nil){
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:nil];
            //  NSLog(@"%@",json);
            
            NSArray *venues = [[json objectForKey:@"response"] objectForKey:@"venues"];
            
            // NSLog(@"%@",venues);
            
            self.searchResults = [[NSMutableArray alloc]init];
            
            for (NSDictionary *venue in venues){
                
                NSString *venueName = [venue objectForKey:@"name"];
                NSString *venueURL = [venue objectForKey:@"url"];
                NSDictionary *venueLoc = [venue objectForKey:@"location"];
                
                NSString *address = [venueLoc valueForKey:@"address"];
                NSString *city = [venueLoc valueForKey:@"city"];
                
                if (address == nil){
                    address = @"";
                }
                if (city == nil){
                    city = @"";
                }
                
                SearchResults *resultsObject = [[SearchResults alloc]init];
                
                resultsObject.name = venueName;
                resultsObject.url = venueURL;
                
                resultsObject.location = [NSString stringWithFormat:@"%@ %@",address,city];
                
                [self.searchResults addObject:resultsObject];
                
            }
            block();
        }
    }];
    
}

#pragma mark text field delegate

//processes return button
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //dismisses the keyboard
    [self.view endEditing:YES];
    
    //make an API request
    [self makeNewFourSquareAPIRequestWithSearchTerm:textField.text
                                      callbackBlock:^{
                                          [self.tableView reloadData];
                                      }];
    
    return YES;
}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    SearchResults *currentResult = self.searchResults[indexPath.row];
    
    cell.textLabel.text = currentResult.name;
    cell.detailTextLabel.text = currentResult.location;
    
    return cell;
}



@end
