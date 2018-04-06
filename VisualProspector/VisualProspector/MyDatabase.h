//
//  MyDatabase.h
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface MyDatabase : NSObject
+ (NSString *)getDBPath;
+ (void)checkDataBaseExistence;
+ (bool)checkRecordDuplecasy:(NSString *)lat longitude:(NSString *)longitude;
+ (void)insertIntoMainDatabase:(const char *)query tempArray:(NSArray *)tempArray;
+ (NSArray *)getDataFromTable:(const char *)query;
+ (void)deleteRecord:(const char *)query;
+ (BOOL)updateMainDatabase:(const char *)query index:(int)index;
@end
