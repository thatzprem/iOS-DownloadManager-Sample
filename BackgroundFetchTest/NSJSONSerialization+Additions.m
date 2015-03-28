//
//  NSJSONSerialization+Additions.m
//  JsonTest
//
//  Created by Prem kumar on 17/03/14.
//  Copyright (c) 2014 nexTip. All rights reserved.
//

#import "NSJSONSerialization+Additions.h"
#import "Constants.h"

@implementation NSJSONSerialization (Additions)

+(BOOL)isObjectEmpty:(id)object
{
    return object == nil || ([object respondsToSelector:@selector(length)] && [(NSData *)object length] == 0) || ([object respondsToSelector:@selector(count)] && [(NSArray *)object count] == 0);
}

#pragma mark Json Utils

+(BOOL)isValidJsonData:(NSData *)jsonData{
    
    BOOL result = FALSE;
    
    if ([self isObjectEmpty:jsonData]) {
        DLog(@"Received data parameter is empty.");
        
    }else{
        NSData *data = jsonData;
        result = [NSJSONSerialization isValidJSONObject:data];
    }
    return result;
}

+(BOOL)isValidJsonFromURL:(NSURL *)url{
    
    BOOL result = FALSE;
    
    if ([self isObjectEmpty:url]) {
        DLog(@"Received url parameter is nil.");
        
    }else{
        
        NSData *data = nil;
        NSError *error = nil;
        
        data = [NSData dataWithContentsOfURL:url];
        if (data != nil) {
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            result = [self isValidJsonData:jsonObj];
        }
    }
    return result;
}

+(NSData *)getJsonDataFromURL:(NSURL *)url{
    
    NSData *data = nil;
    NSError *error = nil;
    
    data = [NSData dataWithContentsOfURL:url];
    if (data != nil) {
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if ([jsonObj isKindOfClass:[NSData class]]) {
            data = jsonObj;
        }
    }
    return data;
}

+(NSString *)convertNSDataToJsonString:(NSData *)jsonData{
    
    NSString* jsonString = nil;
    
    if(jsonData){
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+(NSDictionary *)convertJsonStringToDictionary:(NSString *)jsonString
{
    NSString *stringToConvert = jsonString;
    
    if (![self isObjectEmpty:stringToConvert]) {
        
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSDictionary *convertedData = nil;
        
        convertedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (error != nil){
            DLog(@"Error converting jsonString to dictionary: %@", [error description]);
            convertedData = nil;
        }
        else if ([convertedData isKindOfClass:[NSDictionary class]]) {
            DLog(@"The converted data is of kind NSDictionary");
        }
        else if ([convertedData isKindOfClass:[NSArray class]]){
            DLog(@"The converted data is of kind NSArray");
            convertedData = nil;
        }
        else{
            DLog(@"The converted data is not NSDictionary/NSArray");
            convertedData = nil;
        }
        return convertedData;
    }
    else{
        DLog(@"The received jsonString is empty");
        return nil;
    }
}

+(JSON_TYPE)getJsonType:(NSString *)jsonString
{
    NSString *stringToConvert = jsonString;
    JSON_TYPE type = JSON_TYPE_NO_TYPE;
    
    if (![self isObjectEmpty:stringToConvert]) {
        
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        id convertedData = nil;
        
        convertedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (error != nil){
            DLog(@"Error converting jsonString to dictionary: %@", [error description]);
            convertedData = nil;
        }
        else if ([convertedData isKindOfClass:[NSDictionary class]]) {
            DLog(@"The converted data is of kind NSDictionary");
            type = JSON_TYPE_DICTIONARY;
        }
        else if ([convertedData isKindOfClass:[NSArray class]]){
            DLog(@"The converted data is of kind NSArray");
            type = JSON_TYPE_ARRAY;
        }
        else{
            DLog(@"The converted data is not NSDictionary/NSArray");
            convertedData = nil;
        }
    }
    else{
        DLog(@"The received jsonString is empty");
        type = JSON_TYPE_NO_TYPE;
    }
    return type;
}

@end
