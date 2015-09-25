//
//  NSString+NSString_Sanitize.m
//  TalkinToTheNet
//
//  Created by Jamaal Sedayao on 9/24/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "NSString+NSString_Sanitize.h"

@implementation NSString (NSString_Sanitize)

#pragma sanitize html string

// http://stackoverflow.com/questions/277055/remove-html-tags-from-an-nsstring-on-the-iphone

-(NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}


@end
