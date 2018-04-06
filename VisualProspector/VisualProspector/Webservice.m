//
//  Webservice.m
//  VisualProspector
//
//  Created by apple on 02/10/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "Webservice.h"

@implementation Webservice
@synthesize manager;
@synthesize session;

#pragma mark - Singleton instance
+ (id)sharedManager {
    static Webservice *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:@""]];
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}
#pragma mark - end

#pragma mark - AFNetworking method
//Request with parameters
- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
//    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        responseObject=(id)[NullValueChecker checkArrayForNullValue:[responseObject mutableCopy]];
        success(responseObject);
    } failure:^(NSURLSessionDataTask * task, NSError * _Nonnull error) {
        NSLog(@"error.localizedDescription %@ %ld",error.localizedDescription, (long)error.code);
        [appDelegate stopIndicator];
        [self parseHeaderData:task error:error path:path parameters:parameters onSuccess:success onFailure:failure];
        
    }];
}

//Post with video
- (void)postImage:(NSString *)path filePath:(NSString *)filePath parameters:(NSDictionary *)parameters  success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
//    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager.securityPolicy setValidatesDomainName:NO];
    NSData *videoData = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
    [manager POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:videoData name:@"attachment_file" fileName:[filePath lastPathComponent] mimeType:@"video/*"];
        [formData appendPartWithFormData:videoData name:@"attachment_file"];
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error.localizedDescription %@ %ld",error.localizedDescription, (long)error.code);
        [appDelegate stopIndicator];
        [self parseHeaderData:task error:error path:path parameters:parameters onSuccess:success onFailure:failure];
    }];
}

- (void)get:(NSString *)path authentication:(NSString *)authentication parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self.manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"application/x-www-form-urlencoded", @"text/csv", nil]];
    
    if (![authentication isEqualToString:@""]) {
        //[UserDefaultManager getValue:@"Authorization"]
        [manager.requestSerializer setValue:authentication forHTTPHeaderField:@"Authorization"];
    }
    
    [manager GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        responseObject=(id)[NullValueChecker checkArrayForNullValue:[responseObject mutableCopy]];
        success(responseObject);
    }
         failure:^(NSURLSessionDataTask * task, NSError * _Nonnull error) {
             NSLog(@"error.localizedDescription %@ %ld",error.localizedDescription, (long)error.code);
             [appDelegate stopIndicator];
             [self parseHeaderData:task error:error path:path parameters:parameters onSuccess:success onFailure:failure];
         }];
}

- (void)downloadStatusFIle:(NSString *)path authentication:(NSString *)authentication parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager1 = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:path];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setValue:authentication forHTTPHeaderField:@"Authorization"];
    NSURLSessionDownloadTask *downloadTask = [manager1 downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        DLog(@"%@",[response suggestedFilename]);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [[documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]] path];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:NULL];
        }
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        // Do operation after download is complete
        DLog(@"%@",[filePath absoluteString]);
        if (!error) {
//            [appDelegate clearAllFilesFromTempDirectory];
            NSData *data = [NSData dataWithContentsOfURL:filePath];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            NSLocale *locale = [[NSLocale alloc]
//                                initWithLocaleIdentifier:@"en_US"];
//            [dateFormatter setLocale:locale];
//            [dateFormatter setDateFormat:@"dd_MM_YYYY"];
//            [data writeToFile:[NSString stringWithFormat:@"%@",[appDelegate csvFileLinkInCacheDirectory:[dateFormatter stringFromDate:[NSDate date]]]] atomically:true];
//            [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success([self loadAndParseMMSWithStringData:newStr hasHeaderFields:true]);
        }
        else {
            [appDelegate stopIndicator];
            if (error.code == -1009) {
                [UserDefaultManager showErrorAlert:@"Alert" message:@"Internet connection error. Please try again later." closeButtonTitle:@"OK"];
            }
            else if (error.code == -1001) {
                [UserDefaultManager showErrorAlert:@"Alert" message:@"Request timeout, please try again later." closeButtonTitle:@"OK"];
            }
            else {
                [UserDefaultManager showErrorAlert:@"Alert" message:@"Something went wrong, please try again later." closeButtonTitle:@"OK"];
            }
            failure(error);
        }
        
    }];
    [downloadTask resume];
}

- (void)downloadFIle:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager1 = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager1 downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [[documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]] path];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:NULL];
        }
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        // Do operation after download is complete
        DLog(@"%@",[filePath absoluteString]);
        if (!error) {
            [appDelegate clearAllFilesFromTempDirectory];
            NSData *data = [NSData dataWithContentsOfURL:filePath];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"dd_MM_YYYY"];
            [data writeToFile:[NSString stringWithFormat:@"%@",[appDelegate csvFileLinkInCacheDirectory:[dateFormatter stringFromDate:[NSDate date]]]] atomically:true];
            [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success([self loadAndParseWithStringData:newStr hasHeaderFields:true]);
        }
        else {
            [appDelegate stopIndicator];
            if (error.code == -1009) {
                [UserDefaultManager showErrorAlert:@"Alert" message:@"Internet connection error. Please try again later." closeButtonTitle:@"OK"];
            }
            else if (error.code == -1001) {
                [UserDefaultManager showErrorAlert:@"Alert" message:@"Request timeout, please try again later." closeButtonTitle:@"OK"];
            }
            else {
                [UserDefaultManager showErrorAlert:@"Alert" message:@"Something went wrong, please try again later." closeButtonTitle:@"OK"];
            }
            failure(error);
        }
        
    }];
    [downloadTask resume];
}

- (NSMutableArray *)loadAndParseWithStringData:(NSString*)stringData hasHeaderFields:(BOOL)hasHeaderFields {
    NSMutableArray *responseArray=[NSMutableArray new];
    NSMutableArray *gcRawData = [[[stringData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@"\n"] mutableCopy];
    NSArray *allKeys=[NSMutableArray new];
    if (gcRawData.count>0) {
        NSString *tempString=[[gcRawData objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (hasHeaderFields) {
            allKeys=[tempString componentsSeparatedByString:@","];
            [gcRawData removeObjectAtIndex:0];
        }
        for (NSString *csvString in gcRawData) {
            NSString *tempCSVString=[csvString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (![tempCSVString isEqualToString:@""]) {
                NSArray *tempArray=[tempCSVString componentsSeparatedByString:@","];
                NSMutableDictionary *tempDict=[NSMutableDictionary new];
                BOOL flag=false;
                int index=-1;
                int blankStringIndex=0;
                for (int i=0; i<tempArray.count; i++) {
                    NSLog(@"%@",tempArray[i]);
                    if ([tempArray[i] containsString:@"\""]&&!flag) {
                        flag=true;
                        index=index+1;
                        [tempDict setObject:[tempArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                    }
                    else if ([tempArray[i] containsString:@"\""]&&flag) {
                        flag=false;
                        NSString *temp=[tempDict objectForKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                        [tempDict setObject:[NSString stringWithFormat:@"%@,%@",temp,[tempArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""]] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                    }
                    else if (![tempArray[i] containsString:@"\""]&&flag) {
                        NSString *temp=[tempDict objectForKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                        [tempDict setObject:[NSString stringWithFormat:@"%@,%@",temp,[tempArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""]] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                    }
                    else {
                        index=index+1;
                        [tempDict setObject:[tempArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                    }
                    
                    if ([[tempArray[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
                        blankStringIndex=blankStringIndex+1;
                    }
                }
                if (blankStringIndex!=tempArray.count) {
                    [responseArray addObject:tempDict];
                }
            }
        }
    }
    return responseArray;
}

//CSV parser work properly for both CSV parser (I think so)
- (NSMutableArray *)loadAndParseMMSWithStringData:(NSString*)stringData hasHeaderFields:(BOOL)hasHeaderFields {
    NSMutableArray *responseArray=[NSMutableArray new];
    NSMutableArray *gcRawData = [[[stringData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@"\n"] mutableCopy];
    NSArray *allKeys=[NSMutableArray new];
    if (gcRawData.count>0) {
        NSString *tempString=[[gcRawData objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (hasHeaderFields) {
            allKeys=[tempString componentsSeparatedByString:@","];
            [gcRawData removeObjectAtIndex:0];
        }
        NSString *combinedData=[gcRawData componentsJoinedByString:@"\n"];
        NSArray *combinedStringArray=[combinedData componentsSeparatedByString:@","];
        BOOL flag=false;
        int index=-1;
        int blankStringIndex=-1;
        NSMutableDictionary *tempDict=[NSMutableDictionary new];
        for (int i=0; i<combinedStringArray.count; i++) {
            if ([combinedStringArray[i] containsString:@"\""]&&!flag) {
                flag=true;
                index=index+1;
                if ([[combinedStringArray[index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
                    blankStringIndex=blankStringIndex+1;
                }
                if ([[combinedStringArray[i] componentsSeparatedByString:@"\""] count]>2) {
                    flag=false;
                }
                
                //Use for last column of current row
                if (index==allKeys.count-1) {
                    NSMutableArray *tempA=[[[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] componentsSeparatedByString:@"\n"] mutableCopy];
                    NSString *tempString=[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    NSString *nextTempString=@"";
                    if (tempA.count>1) {
                        nextTempString=[tempA lastObject];
                        [tempA removeLastObject];
                        tempString=[tempA componentsJoinedByString:@"\n"];
                    }
                    [tempDict setObject:tempString forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                    if (![nextTempString isEqualToString:@""]) {
                        [responseArray addObject:tempDict];
                        tempDict=[NSMutableDictionary new];
                        index=0;
                        blankStringIndex=-1;
                        if ([[nextTempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
                            blankStringIndex=blankStringIndex+1;
                        }
                        [tempDict setObject:[nextTempString stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                        continue;
                    }
                }
                else {
                    [tempDict setObject:[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                }
                
                [tempDict setObject:[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
            }
            else if ([combinedStringArray[i] containsString:@"\""]&&flag) {
                flag=false;
                NSString *temp=[tempDict objectForKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                [tempDict setObject:[NSString stringWithFormat:@"%@,%@",temp,[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""]] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
            }
            else if (![combinedStringArray[i] containsString:@"\""]&&flag) {
                NSString *temp=[tempDict objectForKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                [tempDict setObject:[NSString stringWithFormat:@"%@,%@",temp,[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""]] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
            }
            else {
                index=index+1;
                if ([[combinedStringArray[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
                    blankStringIndex=blankStringIndex+1;
                }
                if (index==allKeys.count-1) {
                    NSMutableArray *tempA=[[[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] componentsSeparatedByString:@"\n"] mutableCopy];
                    NSString *tempString=[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    NSString *nextTempString=@"";
                    if (tempA.count>1) {
                        nextTempString=[tempA lastObject];
                        [tempA removeLastObject];
                        tempString=[tempA componentsJoinedByString:@"\n"];
                    }
                    [tempDict setObject:tempString forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                    if (![nextTempString isEqualToString:@""]) {
                        [responseArray addObject:tempDict];
                        tempDict=[NSMutableDictionary new];
                        index=0;
                        blankStringIndex=-1;
                        if ([[nextTempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
                            blankStringIndex=blankStringIndex+1;
                        }
                        [tempDict setObject:[nextTempString stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                        continue;
                    }
                }
                else {
                    [tempDict setObject:[combinedStringArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:(hasHeaderFields?(index>(allKeys.count-1)?[NSString stringWithFormat:@"%d",index]:allKeys[index]):[NSString stringWithFormat:@"%d",index])];
                }
            }
            
            if (index==allKeys.count-1) {
                if (blankStringIndex!=index) {
                    [responseArray addObject:tempDict];
                }
                blankStringIndex=-1;
                tempDict=[NSMutableDictionary new];
                index=-1;
            }
        }
    }
    return responseArray;
}

- (void)parseHeaderData:(NSURLSessionDataTask *)task error:(NSError *)error  path:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    if (error.code == -1009) {
        [self showRetryAlertMessage:@"Internet connection error. Please try again later." path:path parameters:parameters success:success failure:failure error:error];
    }
    else if (error.code == -1001) {
        [self showRetryAlertMessage:@"Request timeout, please try again later." path:path parameters:parameters success:success failure:failure error:error];
    }
    else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = [response statusCode];
        if ((int)statusCode==200 && error) {
            [UserDefaultManager showErrorAlert:@"Alert" message:@"Something went wrong, please try again later." closeButtonTitle:@"OK"];
            failure(error);
        }
        else {
            NSMutableDictionary* json = [[NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error] mutableCopy];
            NSLog(@"json %@",json);
            NSLog(@"error %ld",(long)error.code);
            
            [json setObject:[NSNumber numberWithInteger:statusCode] forKey:@"status"];
            [self isStatusOK:json];
            NSLog(@"error %ld",(long)statusCode);
            failure(error);
        }
    }
}

//Check response success
- (BOOL)isStatusOK:(id)responseObject {
    NSNumber *number = responseObject[@"status"];
    NSString *msg;
    switch (number.integerValue) {
        case 400: {
            msg = responseObject[@"message"];
            [UserDefaultManager showErrorAlert:@"Alert" message:msg closeButtonTitle:@"OK"];
            return NO;
        }
        case 200:
            return YES;
            break;
            break;
        default: {
            [UserDefaultManager showErrorAlert:@"Alert" message:@"Something went wrong, please try again later." closeButtonTitle:@"OK"];
        }
            return NO;
            break;
    }
}
#pragma mark - end

#pragma mark - Retry webservice
- (void)showRetryAlertMessage:(NSString *)message path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure error:(NSError *)error {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"OK" actionBlock:^(void) {
        failure(error);
//        self.success=success;
//        self.failure=failure;
//        self.retryPath=path;
//        self.retryParameters=parameters;
//        [appDelegate showIndicator];
//        [self performSelector:@selector(retryWebservice) withObject:nil afterDelay:.1];
    }];
    [alert addButton:@"Cancel" actionBlock:^(void) {
        failure(error);
    }];
    [alert showWarning:nil title:@"Alert" subTitle:message closeButtonTitle:nil duration:0.0f];
}

- (void)retryWebservice {
//    [self get:self.retryPath parameters:self.retryParameters onSuccess:self.success onFailure:self.failure];
}
#pragma mark - end

//Post image method for services
- (void)postVideo:(NSString *)path filePath:(NSString *)filePath parm:(NSDictionary *)parm onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
// the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"attachment_file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:path];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:90];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in parm) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parm objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *videoData = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
    if (videoData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant,[filePath lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: video/mp4\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:videoData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSData *companylogoData = [appDelegate listionDataFromCacheDirectory];
    if (companylogoData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"logo",@"companylogo.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:companylogoData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil) {
            
            
            //                CNLog(@"Http header response -----> %@",response);
            //                CNLog(@"Response in string -----> %@",responseString);
            //
            //                NSMutableDictionary *responseData=(NSMutableDictionary *)[CNNullHandler checkDictionaryForNullValue:[[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:nil] mutableCopy]];
            //
            //                if ((nil==responseData) || [responseData isKindOfClass:[NSNull class]] || responseData == (id)[NSNull null] || responseData == NULL) {
            //
            //                    NSDictionary *userInfo = @{
            //                                               NSLocalizedDescriptionKey: NSLocalizedString(responseString, nil),
            //                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"", nil),
            //                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
            //                                               };
            //                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
            //                                                         code:-57
            //                                                     userInfo:userInfo];
            //                    failure(error);
            //                }
            //                else {
            //
            //                    success([responseData mutableCopy]);
            //                }
            id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
             NSString *responseString1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                success(responseString1);
            
        }
        else {
            int errorCode=-57;
            NSString *responseString=@"Something went wrong, please try again later.";
            if (error.code == -1009) {
                errorCode=(int)error.code;
                responseString=@"Internet connection error. Please try again later.";
            }
            else if (error.code == -1001) {
                errorCode=(int)error.code;
                responseString=@"Request timeout, please try again later.";
            }
            [appDelegate stopIndicator];
            [UserDefaultManager showErrorAlert:@"Failure" message:responseString closeButtonTitle:@"OK"];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(responseString, nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
                                       };
            error = [NSError errorWithDomain:NSURLErrorDomain
                                        code:errorCode
                                    userInfo:userInfo];
            failure(error);
        }
    }];
    [task resume];
}

- (NSData *)isCompanyLogoBlank {
//    NSData *data1 = UIImagePNGRepresentation([UIImage imageNamed:@"placeholder.png"]);
    UIImageView *temp=[[UIImageView alloc] init];
    NSData *data2 = UIImagePNGRepresentation(temp.image);
    
    if ([[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"isLogoExist"] boolValue]) {
        [UserDefaultManager downloadImages:temp imageUrl:[NSString stringWithFormat:@"http://parkproject.asia/visualprospector/assets/img/company_logo/%@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyLogo"]]];
//        [UserDefaultManager downloadImages:[NSString stringWithFormat:@"http://parkproject.asia/visualprospector/assets/img/company_logo/%@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyLogo"]]];
    }
    else {
        [UserDefaultManager downloadImages:temp imageUrl:@""];
    }
    UIImage *temp1=[UIImage imageWithData:data2];
//    if (nil==data2 || [data1 isEqual:data2]) {
//        return nil;
//    }
    return data2;
}

- (void)postFormDataServics:(NSString *)path parm:(NSDictionary *)parm onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:path];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in parm) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parm objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil) {
            
            //                NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //                CNLog(@"Http header response -----> %@",response);
            //                CNLog(@"Response in string -----> %@",responseString);
            //
            //                NSMutableDictionary *responseData=(NSMutableDictionary *)[CNNullHandler checkDictionaryForNullValue:[[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:nil] mutableCopy]];
            //
            //                if ((nil==responseData) || [responseData isKindOfClass:[NSNull class]] || responseData == (id)[NSNull null] || responseData == NULL) {
            //
            //                    NSDictionary *userInfo = @{
            //                                               NSLocalizedDescriptionKey: NSLocalizedString(responseString, nil),
            //                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"", nil),
            //                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
            //                                               };
            //                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
            //                                                         code:-57
            //                                                     userInfo:userInfo];
            //                    failure(error);
            //                }
            //                else {
            //
            //                    success([responseData mutableCopy]);
            //                }
            id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            success(value);
        }
        else {
            int errorCode=-57;
            NSString *responseString=@"Something went wrong, please try again later.";
            if (error.code == -1009) {
                errorCode=(int)error.code;
                responseString=@"Internet connection error. Please try again later.";
            }
            else if (error.code == -1001) {
                errorCode=(int)error.code;
                responseString=@"Request timeout, please try again later.";
            }
            [appDelegate stopIndicator];
            [UserDefaultManager showErrorAlert:@"Failure" message:responseString closeButtonTitle:@"OK"];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(responseString, nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
                                       };
            error = [NSError errorWithDomain:NSURLErrorDomain
                                        code:errorCode
                                    userInfo:userInfo];
            failure(error);
        }
    }];
    [task resume];
}

//Post image method for services
- (void)postImageWithJson:(NSString *)path filePath:(NSString *)filePath parm:(NSDictionary *)parm onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"attachment_file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:path];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in parm) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parm objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    DLog(@"%@",[filePath lastPathComponent]);
    NSData *companylogoData = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
//    UIImage *i=[UIImage imageWithData:companylogoData];
    if (companylogoData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"company_logo",[filePath lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:companylogoData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil) {
            
            //                NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //                CNLog(@"Http header response -----> %@",response);
            //                CNLog(@"Response in string -----> %@",responseString);
            //
            //                NSMutableDictionary *responseData=(NSMutableDictionary *)[CNNullHandler checkDictionaryForNullValue:[[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:nil] mutableCopy]];
            //
            //                if ((nil==responseData) || [responseData isKindOfClass:[NSNull class]] || responseData == (id)[NSNull null] || responseData == NULL) {
            //
            //                    NSDictionary *userInfo = @{
            //                                               NSLocalizedDescriptionKey: NSLocalizedString(responseString, nil),
            //                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"", nil),
            //                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
            //                                               };
            //                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
            //                                                         code:-57
            //                                                     userInfo:userInfo];
            //                    failure(error);
            //                }
            //                else {
            //
            //                    success([responseData mutableCopy]);
            //                }
            id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            success(value);
        }
        else {
            int errorCode=-57;
            NSString *responseString=@"Something went wrong, please try again later.";
            if (error.code == -1009) {
                errorCode=(int)error.code;
                responseString=@"Internet connection error. Please try again later.";
            }
            else if (error.code == -1001) {
                errorCode=(int)error.code;
                responseString=@"Request timeout, please try again later.";
            }
            [appDelegate stopIndicator];
            [UserDefaultManager showErrorAlert:@"Failure" message:responseString closeButtonTitle:@"OK"];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(responseString, nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
                                       };
            error = [NSError errorWithDomain:NSURLErrorDomain
                                        code:errorCode
                                    userInfo:userInfo];
            failure(error);
        }
    }];
    [task resume];
}
@end
