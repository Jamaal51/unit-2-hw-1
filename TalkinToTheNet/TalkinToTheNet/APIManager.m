//
//  APIManager.m
//  LearnAPI
//
//  Created by Jamaal Sedayao on 9/20/15.
//  Copyright © 2015 Jamaal Sedayao. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

//takes a url, make an http request and pop back into the main thread

//create a class method - gives us ability to not have to call alloc init on it
+ (void) GETRequestWithURL:(NSURL*)URL
         completionHandler:(void(^)(NSData*data,NSURLResponse*response,NSError*error))
completionHandler  {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionHandler(data, response, error);
            
        });
    }];
    
    [task resume];
}



@end
