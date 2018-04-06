//
//  MyDatabase.m
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.

#import "MyDatabase.h"
//#import "DataHolderClass.h"
static NSString *databaseName=@"visualProspertor.sqlite";
static sqlite3 *database = nil;
@implementation MyDatabase

#pragma mark - Check Database existence
+ (NSString *)getDBPath {
    // Database filename can have extension db/sqlite.
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //    NSString *appDBPath = [documentsDirectory stringByAppendingPathComponent:@"brindleyBeachDB.sqlite"];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",databasePath,databaseName]];
}

+ (void)checkDataBaseExistence {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    BOOL success=[fileManager fileExistsAtPath:[self getDBPath]];
    if(!success) {
        NSString *defaultDBPath=[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:databaseName];
        success=[fileManager copyItemAtPath:defaultDBPath  toPath:[self getDBPath] error:&error];
        if(!success) {
            NSAssert1(0,@"failed to create database with message '%@'.",[error localizedDescription]);
        }
    }
}
#pragma mark - end

#pragma mark - Insert query
+ (void)insertIntoMainDatabase:(const char *)query tempArray:(NSArray *)tempArray {
    sqlite3_stmt *dataRows=nil;
    if(sqlite3_open([[self getDBPath] UTF8String],&database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, query, -1, &dataRows, NULL)!=SQLITE_OK) {
            NSAssert1(0,@"error while preparing  %s",sqlite3_errmsg(database));
        }
        int x=0;
        for (NSDictionary *tempDict in tempArray) {
//            sqlite3_bind_int(dataRows, 1, x);
            NSString *phoneNo=tempDict[@"phonenum1"];
            if ((nil!=tempDict[@"phonenum1"])&&![tempDict[@"phonenum1"] isEqualToString:@""]&&![tempDict[@"phonenum1"] containsString:@"+"]) {
                phoneNo=[NSString stringWithFormat:@"+1%@",tempDict[@"phonenum1"]];
            }
            sqlite3_bind_text(dataRows, 2, [tempDict[@"firstname"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(dataRows, 3, [tempDict[@"lastname"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(dataRows, 4, [tempDict[@"email"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(dataRows, 5, [phoneNo UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(dataRows, 6, [tempDict[@"propaddr"] UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(dataRows) == SQLITE_DONE) {
                if (x == (tempArray.count - 1))
                    sqlite3_finalize(dataRows);
                else
                    sqlite3_reset(dataRows);
            }
            else {
                NSLog(@"row insertion error");
            }
            x+=1;
        }
        sqlite3_close(database);
        database=nil;
    }
    else {
        sqlite3_close(database);
        database=nil;
    }
}

+ (BOOL)updateMainDatabase:(const char *)query index:(int)index {
    BOOL success = false;
    sqlite3_stmt *statement = NULL;
//    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open([[self getDBPath] UTF8String],&database) == SQLITE_OK) {
        
//            NSLog(@"Exitsing data, Update Please");
//            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE EMPLOYEES set name = '%@', department = '%@', age = '%@' WHERE id = ?",
//                                   employee.name,
//                                   employee.department,
//                                   [NSString stringWithFormat:@"%d", employee.age]];
//
//            const char *update_stmt = [updateSQL UTF8String];
            sqlite3_prepare_v2(database, query, -1, &statement, NULL);
            sqlite3_bind_int(statement, 1, index);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                success = true;
            }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
        database=nil;
    }
    
    return success;
}

#pragma mark - end
+ (bool)checkRecordDuplecasy:(NSString *)lat longitude:(NSString *)longitude {
    NSInteger lastRowId = sqlite3_last_insert_rowid((__bridge sqlite3 *)(databaseName));
    NSLog(@"lastRowId is %ld",(long)lastRowId);
    NSArray *tmpAry=[MyDatabase getDataFromTable:[[NSString stringWithFormat:@"SELECT * FROM MainCSV WHERE ROWID = %ld",lastRowId] UTF8String]];
    NSLog(@"ary is %@",tmpAry);
    return true;
}

#pragma mark - Delete query
+ (void)deleteRecord:(const char *)query {
    sqlite3_stmt *dataRows=nil;
    if(sqlite3_open([[self getDBPath] UTF8String],&database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, query, -1, &dataRows, NULL)!=SQLITE_OK) {
            char *err;
            err=(char *) sqlite3_errmsg(database);
            if (err)
                sqlite3_free(err);
        }
        if (SQLITE_DONE!=sqlite3_step(dataRows)) {
            char *err;
            err=(char *) sqlite3_errmsg(database);
            if (err)
                sqlite3_free(err);
        }
        sqlite3_reset(dataRows);
        sqlite3_close(database);
        database=nil;
    }
}
#pragma mark - end

#pragma mark - Products fetch method
+ (NSArray *)getDataFromTable:(const char *)query {
    NSMutableArray *array=[[NSMutableArray alloc]init];
    if(sqlite3_open([[self getDBPath] UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, query , -1, &statement, nil)==SQLITE_OK) {
            while(sqlite3_step(statement)==SQLITE_ROW) {
//                employee.employeeID = sqlite3_column_int(statement, 0);
//                employee.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
//                employee.department = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
//                employee.age = sqlite3_column_int(statement, 3);
                
                NSMutableDictionary * dataDict = [NSMutableDictionary new];
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,0)] forKey:@"id"];
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,1)] forKey:@"firstName"];
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,2)] forKey:@"lastName"];
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,3)] forKey:@"emailId"];
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,4)] forKey:@"mobileNumber"];
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,5)] forKey:@"address"];
                [dataDict setObject:[NSNumber numberWithBool:false] forKey:@"isChecked"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"status"];
                [array addObject:dataDict];
            }
        }
    }
    NSLog(@"array length in DBCls is =%lu",(unsigned long)[array count]);
    return [array copy];
}
#pragma mark - end
@end
