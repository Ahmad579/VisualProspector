//
//  AppDelegate.h
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign) int selectedMenu;
@property (nonatomic,assign) BOOL isProfileFetched;

- (void)showIndicator;
- (void)stopIndicator;
- (void)deleteJsonMMSEntry:(NSString *)uniqueId;
- (NSString *)saveDataInCacheDirectory:(UIImage *)tempImage;
- (NSString *)profilesaveDataInCacheDirectory:(UIImage *)tempImage;
- (NSData *)listionDataFromCacheDirectory;
- (void)hideStatusBarData;
- (void)showStatusBarData;
- (NSString *)saveVideoDataInCacheDirectory:(NSData *)videoData;
- (NSArray *)getVideoPaths;
- (NSString *)applicationCacheDirectory;
- (NSNumber *)listionVideoDataSizeFromCacheDirectory:(NSString *)path;
- (void)deleteFileFromCacheDirectory:(NSString *)fileName;
- (void)renameFileFromCacheDirectory:(NSString *)fromFileName toFileName:(NSString *)toFileName;
- (NSString *)csvFileLinkInCacheDirectory:(NSString *)fileName;
- (BOOL)checkCSVFileIsExist:(NSString *)fileName folderName:(NSString *)folderName;
- (void)clearAllFilesFromTempDirectory;
- (void)deleteTableData;
- (BOOL)checkFileIsExist;
- (void)insertDataInMainDatabase:(NSArray*)dataArray;
- (NSArray *)fetchAllCSVData;
- (void)saveJsonDataInCacheDirectory:(NSString *)folderName jsonData:(NSMutableArray *)jsonData;
- (NSMutableArray *)fetchJsonDataInCacheDirectory:(NSString *)folderName;
- (NSMutableArray *)fetchJsonDataLastSevenDaysInCacheDirectory:(NSString *)folderName;
- (BOOL)checkVideoFileIsExist:(NSString *)filePath;
- (void)UpdateJsonDataInCacheDirectory:(NSString *)folderName jsonData:(NSMutableArray *)jsonData;
- (NSMutableArray *)fetchJsonDataInCacheDirectoryWithName:(NSString *)folderName dateStr:(NSString *)dateStr;
- (void)createNewCSVEntriesJsonData:(NSMutableArray *)jsonData;
- (void)UpdateNewCSVEntriesJsonDataInCacheDirectoryJsonData:(NSDictionary *)jsonData;
- (NSMutableArray *)fetchNewCSVEntriesJsonDataInCacheDirectory;
- (void)deleteTableData:(int)index;
- (void)updateDataInMainDatabase:(NSDictionary*)tempDict;
- (void)deleteNewCSVEntriesJsonDataInCacheDirectory:(NSDictionary *)jsonData;
@end

