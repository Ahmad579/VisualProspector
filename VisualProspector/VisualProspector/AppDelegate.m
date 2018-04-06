//google drive: https://www.innofied.com/google-drive-integration-in-ios-apps/
//
//  AppDelegate.m
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "MMMaterialDesignSpinner.h"
#import "MyDatabase.h"

@interface AppDelegate () {
    UIView *loaderView;
    UIImageView *spinnerBackground;
}
@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;
@end

@implementation AppDelegate
@synthesize spinnerView;
@synthesize selectedMenu,isProfileFetched;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setNavigationBar];
    isProfileFetched=false;
    selectedMenu=2;
    [self createAllCacheFolders];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (nil==[UserDefaultManager getValue:@"UDID"]) {
        NSUUID *uuid = [NSUUID UUID];
        NSString *uuidString = uuid.UUIDString;
        [UserDefaultManager setValue:uuidString key:@"UDID"];
    }
    [appDelegate saveDataInCacheDirectory:[UIImage imageNamed:@"placeholder.png"]];
    NSMutableDictionary *profileData=[NSMutableDictionary new];
    [profileData setObject:@"" forKey:@"firstName"];
    [profileData setObject:@"" forKey:@"lastName"];
    [profileData setObject:@"" forKey:@"userName"];
    [profileData setObject:@"" forKey:@"emailId"];
    [profileData setObject:@"" forKey:@"companyName"];
    [profileData setObject:[NSNumber numberWithBool:false] forKey:@"isLogoExist"];
    [UserDefaultManager setValue:[profileData mutableCopy] key:@"ProfileData"];
    
    if (nil!=[UserDefaultManager getValue:@"isRegister"]&&[[UserDefaultManager getValue:@"isRegister"] boolValue]==true) {
        [[UIApplication sharedApplication] setStatusBarHidden:false];//Unhide status bar
        [appDelegate showStatusBarData];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:objReveal];
        [self.window setBackgroundColor:[UIColor whiteColor]];
        [self.window makeKeyAndVisible];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:true];//Unhide status bar
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setNavigationBar {
//    for (NSString *familyName in [UIFont familyNames]){
//        NSLog(@"Family name: %@", familyName);
//        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
//            NSLog(@"--Font name: %@", fontName);
//        }
//    }
    [[UINavigationBar appearance] setBarTintColor:navigationColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont helveticaNeueMediumWithSize:18],NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

#pragma mark - Global indicator
//Show indicator
- (void)showIndicator {
    spinnerBackground=[[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 50, 50)];
    spinnerBackground.backgroundColor=[UIColor whiteColor];
    spinnerBackground.layer.cornerRadius=25.0f;
    spinnerBackground.clipsToBounds=true;
    spinnerBackground.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    loaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
    loaderView.backgroundColor=[UIColor colorWithRed:63.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:0.3];
    [loaderView addSubview:spinnerBackground];
    spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    spinnerView.tintColor = navigationColor;
    spinnerView.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    spinnerView.lineWidth=3.0f;
    [self.window addSubview:loaderView];
    [self.window addSubview:spinnerView];
    [spinnerView startAnimating];
}

//Stop indicator
- (void)stopIndicator {
    [loaderView removeFromSuperview];
    [spinnerView removeFromSuperview];
    [spinnerView stopAnimating];
}
#pragma mark - end

#pragma mark - Cache directory handler
- (void)createAllCacheFolders {
    [self createCacheDirectory:@"Profile"];
    [self createCacheDirectory:@"Videos"];
    [self createCacheDirectory:@"CSV"];
    [self removeLastSevenDaysJson:mailJsonPath];
    [self removeLastSevenDaysJson:mmsJsonPath];
    [self createCacheDirectory:databasePath];
    [self createCopyOfDatabaseIfNeeded];
    if (![self checkFileIsExist]) {
        [self deleteTableData];
    }
}

- (void)createNewCSVEntriesJsonData:(NSMutableArray *)jsonData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:databasePath];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CSVOtherInfo_%@.json",[UserDefaultManager getValue:@"userId"]]];
    if (![fileManager fileExistsAtPath:filePath]) {
        [[NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil] writeToFile:filePath atomically:NO];
    }
    else {
        NSMutableArray *tempArray=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil];
        [tempArray addObjectsFromArray:jsonData];
        [[NSJSONSerialization  dataWithJSONObject:tempArray options:0 error:nil] writeToFile:filePath atomically:NO];
    }
}

- (void)UpdateNewCSVEntriesJsonDataInCacheDirectoryJsonData:(NSDictionary *)jsonData {
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:databasePath];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CSVOtherInfo_%@.json",[UserDefaultManager getValue:@"userId"]]];
    NSMutableArray *fetchArray=[[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    for (int i=0; i<fetchArray.count; i++) {
        NSDictionary *temp=[fetchArray objectAtIndex:i];
        if ([temp[@"id"] isEqualToString:jsonData[@"id"]]) {
            [fetchArray replaceObjectAtIndex:i withObject:jsonData];
            break;
        }
    }
    [[NSJSONSerialization dataWithJSONObject:fetchArray options:0 error:nil] writeToFile:filePath atomically:NO];
}

- (void)deleteAllNewCSVEntriesJsonDataInCacheDirectoryJsonData {
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:databasePath];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CSVOtherInfo_%@.json",[UserDefaultManager getValue:@"userId"]]];
    [[NSJSONSerialization dataWithJSONObject:[NSMutableArray new] options:0 error:nil] writeToFile:filePath atomically:NO];
}

- (NSMutableArray *)fetchNewCSVEntriesJsonDataInCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:databasePath];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CSVOtherInfo_%@.json",[UserDefaultManager getValue:@"userId"]]];
    NSMutableArray *fetchArray=[NSMutableArray new];
    if (![fileManager fileExistsAtPath:filePath]) {
        return [fetchArray mutableCopy];
    }
    else {
        return [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    }
}

- (void)deleteNewCSVEntriesJsonDataInCacheDirectory:(NSDictionary *)jsonData {
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:databasePath];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CSVOtherInfo_%@.json",[UserDefaultManager getValue:@"userId"]]];
    NSMutableArray *fetchArray=[[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    for (NSDictionary *temp in fetchArray) {
        if ([temp[@"id"] isEqualToString:jsonData[@"id"]]) {
            [fetchArray removeObject:temp];
            break;
        }
    }
    [[NSJSONSerialization dataWithJSONObject:fetchArray options:0 error:nil] writeToFile:filePath atomically:NO];
}

- (void)removeLastSevenDaysJson:(NSString *)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    if ([fileManager fileExistsAtPath:folderPath]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if ([folderName isEqualToString:@"CSVDatabase/MailJson"]) {
            [dateFormatter setDateFormat:@"'MailJson_'dd_MM_YYYY"];
        }
        else {
            [dateFormatter setDateFormat:@"'MMSJson_'dd_MM_YYYY"];
        }
        NSMutableArray *filePaths=[[fileManager subpathsOfDirectoryAtPath:folderPath error:nil] mutableCopy];
        if (filePaths.count>0) {
            NSDate *todayDate = [NSDate date];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            
            for (int i=0; i<7; i++) {
                [dateComponents setDay:-i];
                NSDate *lastDates = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:todayDate options:0];
                NSString * datestr = [NSString stringWithFormat:@"%@.json",[dateFormatter stringFromDate:lastDates]];
                if ([filePaths containsObject:datestr]) {
                    [filePaths removeObject:datestr];
                }
            }
            
            for (NSString *tempPath in filePaths) {
                [fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:tempPath] error:NULL];
            }
        }
    }
    else {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (BOOL)checkFileIsExist {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"dd_MM_YYYY"];
    return [self checkCSVFileIsExist:[NSString stringWithFormat:@"%@_%@.csv",[dateFormatter stringFromDate:[NSDate date]],[UserDefaultManager getValue:@"userId"]] folderName:@"CSV"];
}

- (NSString *)applicationCacheDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (void)createCacheDirectory:(NSString *)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}



- (NSString *)profilesaveDataInCacheDirectory:(UIImage *)tempImage {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"Profile"];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *locale = [[NSLocale alloc]
//                        initWithLocaleIdentifier:@"en_US"];
//    [dateFormatter setLocale:locale];
//    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
//    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *filePath = [imagesPath stringByAppendingPathComponent:@"profile.jpg"];
    NSData * imageData = UIImageJPEGRepresentation(tempImage, 0.5);
    [imageData writeToFile:filePath atomically:YES];
    return filePath;
}

- (NSString *)saveDataInCacheDirectory:(UIImage *)tempImage {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"Profile"];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *locale = [[NSLocale alloc]
//                        initWithLocaleIdentifier:@"en_US"];
//    [dateFormatter setLocale:locale];
//    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
//    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *filePath = [imagesPath stringByAppendingPathComponent:@"profile.jpg"];
    NSData * imageData = UIImageJPEGRepresentation(tempImage, 1.0);
    [imageData writeToFile:filePath atomically:YES];
    return filePath;
}

- (NSString *)saveVideoDataInCacheDirectory:(NSData *)videoData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"dd-MM-YY hh:mm:ss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    DLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
    
    NSString *filePath = [imagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",datestr]];
    [videoData writeToFile:filePath atomically:YES];
    return filePath;
}

- (NSArray *)getVideoPaths {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    return [fileManager subpathsOfDirectoryAtPath:basePath error:nil];
}

- (NSData *)listionDataFromCacheDirectory {
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"Profile"];
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:@"profile.jpg"];
    NSError* error = nil;
    return [NSData dataWithContentsOfFile:fileAtPath options:0 error:&error];
}

- (NSNumber *)listionVideoDataSizeFromCacheDirectory:(NSString *)path {
    NSData *temp=[NSData dataWithContentsOfFile:path options:0 error:nil];
    return [NSNumber numberWithFloat:((float)temp.length/1024.0/1024.0)];
}

- (void)deleteFileFromCacheDirectory:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    [fileManager removeItemAtPath:[basePath stringByAppendingPathComponent:fileName] error:NULL];
}

- (void)renameFileFromCacheDirectory:(NSString *)fromFileName toFileName:(NSString *)toFileName {
    NSError * err = NULL;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    [fileManager moveItemAtPath:[basePath stringByAppendingPathComponent:fromFileName] toPath:[basePath stringByAppendingPathComponent:toFileName] error:&err];
}

- (NSString *)csvFileLinkInCacheDirectory:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"CSV"];
    if (![fileManager fileExistsAtPath:filePath]) {
        
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.csv",fileName,[UserDefaultManager getValue:@"userId"]]];
    return filePath;
}

- (void)clearAllFilesFromTempDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"CSV"];
    NSArray *folderFilesName=[fileManager contentsOfDirectoryAtPath:filePath error:nil];
    if (folderFilesName.count!=0) {
        for (NSString *path in folderFilesName) {
            DLog(@"%@",[filePath stringByAppendingPathComponent:path]);
            NSError *error=nil;
            [fileManager removeItemAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[filePath stringByAppendingPathComponent:path]]] error:&error];
            DLog(@"%@",error);
        }
    }
}

- (BOOL)checkCSVFileIsExist:(NSString *)fileName folderName:(NSString *)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    if (![fileManager fileExistsAtPath:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]]]) {
        return false;
    }
    return true;
}

- (void)saveJsonDataInCacheDirectory:(NSString *)folderName jsonData:(NSMutableArray *)jsonData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    if ([folderName isEqualToString:@"CSVDatabase/MailJson"]) {
        [dateFormatter setDateFormat:@"'MailJson_'dd_MM_YYYY"];
    }
    else {
        [dateFormatter setDateFormat:@"'MMSJson_'dd_MM_YYYY"];
    }
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",datestr]];
        if (![fileManager fileExistsAtPath:filePath]) {
            [[NSJSONSerialization  dataWithJSONObject:jsonData options:0 error:nil] writeToFile:filePath atomically:NO];
        }
        else {
            NSMutableArray *tempArray=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil];
            [tempArray addObjectsFromArray:jsonData];
            [[NSJSONSerialization  dataWithJSONObject:tempArray options:0 error:nil] writeToFile:filePath atomically:NO];
        }
}

- (void)UpdateJsonDataInCacheDirectory:(NSString *)folderName jsonData:(NSMutableArray *)jsonData {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    if ([folderName isEqualToString:@"CSVDatabase/MailJson"]) {
        [dateFormatter setDateFormat:@"'MailJson_'dd_MM_YYYY"];
    }
    else {
        [dateFormatter setDateFormat:@"'MMSJson_'dd_MM_YYYY"];
    }
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",datestr]];
 [[NSJSONSerialization  dataWithJSONObject:jsonData options:0 error:nil] writeToFile:filePath atomically:NO];
   
}

- (NSMutableArray *)fetchJsonDataInCacheDirectory:(NSString *)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    if ([folderName isEqualToString:@"CSVDatabase/MailJson"]) {
        [dateFormatter setDateFormat:@"'MailJson_'dd_MM_YYYY"];
    }
    else {
        [dateFormatter setDateFormat:@"'MMSJson_'dd_MM_YYYY"];
    }
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",datestr]];
    NSMutableArray *fetchArray=[NSMutableArray new];
    if (![fileManager fileExistsAtPath:filePath]) {
        return fetchArray;
    }
    else {
        return [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    }
}

- (NSMutableArray *)fetchJsonDataInCacheDirectoryWithName:(NSString *)folderName dateStr:(NSString *)dateStr {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    if ([folderName isEqualToString:@"CSVDatabase/MailJson"]) {
        dateStr=[NSString stringWithFormat:@"MailJson_%@",dateStr];
    }
    else {
        dateStr=[NSString stringWithFormat:@"MMSJson_%@",dateStr];
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",dateStr]];
    NSMutableArray *fetchArray=[NSMutableArray new];
    if (![fileManager fileExistsAtPath:filePath]) {
        return fetchArray;
    }
    else {
        return [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    }
}

- (void)deleteJsonMMSEntry:(NSString *)uniqueId {
    NSMutableArray *savedJsonData=[[appDelegate fetchJsonDataInCacheDirectory:mmsJsonPath] mutableCopy];
    for (NSDictionary *tempDict in savedJsonData) {
        if ([tempDict[@"DateTime"] isEqualToString:uniqueId]) {
            [savedJsonData removeObject:tempDict];
            break;
        }
    }
    [self UpdateJsonDataInCacheDirectory:mmsJsonPath jsonData:[savedJsonData mutableCopy]];
}

- (NSMutableArray *)fetchJsonDataLastSevenDaysInCacheDirectory:(NSString *)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    if ([folderName isEqualToString:@"CSVDatabase/MailJson"]) {
        [dateFormatter setDateFormat:@"'MailJson_'dd_MM_YYYY"];
    }
    else {
        [dateFormatter setDateFormat:@"'MMSJson_'dd_MM_YYYY"];
    }
    
    NSMutableArray *filePaths=[[fileManager subpathsOfDirectoryAtPath:folderPath error:nil] mutableCopy];
    if (filePaths.count>0) {
        NSDate *todayDate = [NSDate date];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        NSMutableArray *fetchArray=[NSMutableArray new];
        for (int i=0; i<7; i++) {
            [dateComponents setDay:-i];
            NSDate *lastDates = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:todayDate options:0];
            NSString * datestr = [NSString stringWithFormat:@"%@.json",[dateFormatter stringFromDate:lastDates]];
            if ([filePaths containsObject:datestr]) {
                NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",datestr]];
                
                if (![fileManager fileExistsAtPath:filePath]) {
                    continue;
                }
                else {
                    fetchArray=[[fetchArray arrayByAddingObjectsFromArray:[[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath options:0 error:nil] options:NSJSONReadingMutableContainers error:nil] copy]] mutableCopy];
                }
            }
            DLog(@"todayDate: %@", datestr);
        }
        return fetchArray;
    }
    else {
        return [NSMutableArray new];
    }
}
#pragma mark - end

- (BOOL)checkVideoFileIsExist:(NSString *)filePath {
    NSString *basePath = [[appDelegate applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",basePath,filePath]]) {
        return false;
    }
    else {
        return true;
    }
}

#pragma mark - Database handler
// Function to Create a writable copy of the bundled default database in the application Documents directory.
- (void)createCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *appDBPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/visualProspertor.sqlite",databasePath]];
    success = [fileManager fileExistsAtPath:appDBPath];
    if (success) {
        return;
    }
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath1 = [mainBundle pathForResource:@"visualProspertor" ofType:@"sqlite"];
    success = [fileManager copyItemAtPath:filePath1 toPath:appDBPath error:&error];
    NSAssert(success, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
}

- (void)deleteTableData {
    [MyDatabase deleteRecord:[@"delete from MainCSV" UTF8String]];
    [self deleteAllNewCSVEntriesJsonDataInCacheDirectoryJsonData];
}

- (void)deleteTableData:(int)index {
    [MyDatabase deleteRecord:[[NSString stringWithFormat:@"delete from MainCSV where id=%d",index] UTF8String]];
}

- (void)insertDataInMainDatabase:(NSArray*)dataArray {
    NSString *temp=[NSString stringWithFormat:@"insert into MainCSV values(?,?,?,?,?,?)"];
    [MyDatabase insertIntoMainDatabase:[temp UTF8String] tempArray:dataArray];
}

- (void)updateDataInMainDatabase:(NSDictionary*)tempDict {
    NSString *temp=[NSString stringWithFormat:@"UPDATE MainCSV set firstName = '%@', lastName = '%@', emailId = '%@', mobileNumber = '%@', address = '%@' WHERE id = ?",tempDict[@"firstName"],tempDict[@"lastName"],tempDict[@"emailId"],tempDict[@"mobileNumber"],tempDict[@"address"]];
    [MyDatabase updateMainDatabase:[temp UTF8String] index:[tempDict[@"id"] intValue]];
}

- (NSArray *)fetchAllCSVData {
    NSString *query=[NSString stringWithFormat:@"SELECT * FROM MainCSV "];
    NSArray *gpsInfo =[MyDatabase getDataFromTable:[query UTF8String]];
    return [gpsInfo copy];
}
#pragma mark - end

#pragma mark - Show/Hide statusbar
- (void)hideStatusBarData {
    NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    UIView *statusBar;
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }
    statusBar.alpha = 0.0f;
}

- (void)showStatusBarData {
    NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    UIView *statusBar;
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }
    statusBar.alpha = 1.0f;
}
#pragma mark - end
@end
