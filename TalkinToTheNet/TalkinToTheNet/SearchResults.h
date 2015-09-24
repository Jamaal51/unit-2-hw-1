//
//  SearchResults.h
//  TalkinToTheNet
//
//  Created by Jamaal Sedayao on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResults : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *location;
@property (nonatomic) NSString *streetAddressSnippet;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lng;
@property (nonatomic) NSArray *fullAddress;

@end
