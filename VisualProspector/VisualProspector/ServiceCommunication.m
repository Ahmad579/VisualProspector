//
//  ServiceCommunication.m
//  VisualProspector
//
//  Created by apple on 02/10/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ServiceCommunication.h"
static NSString *base=@"http://parkproject.asia/visualprospector/index.php/api/webservice/";

static NSString *kCSVFileURL=@"http://parkproject.asia/visualprospector/index.php/api/webservice/get_user_csv";
static NSString *kSendEmail=@"http://parkproject.asia/visualprospector/index.php/api/webservice/send_mail";
static NSString *kSendMMS=@"http://parkproject.asia/visualprospector/index.php/api/webservice/send_mms";
static NSString *kEmailStatus=@"https://api.mailgun.net/v3/parkproject.asia/events?tags=goForsys";

static NSString *kCheckUser=@"check_user";
static NSString *kCheckPassword=@"check_password";
static NSString *kSaveProfile=@"save_profile";
static NSString *kForgotPassword=@"forgot_password";
static NSString *kGetUserProfile=@"get_user_profile";
static NSString *kGetUserCSV=@"get_user_csv";
static NSString *kUpdateProfile=@"update_profile";
static NSString *kChangePassword=@"change_password";

//Note: Add Tag name at last.
//Method Type: GET
//Content Header: Add Content Header
//(Key,Value) : ("Authorization","Basic YXBpOmtleS0yNTEzZDUzNGU4NTJkZDUwZDY1NjcwYTk0NDFjYzYwZQ==")
//Response:
//1.) Get the Array with name of "items" and Parase it reverse like from array length to 0.
//2.) Match the if Event is not equal to accepted, then get recipient, event, message.headers.subject
//3.) Check subject is not equal to null then, check our stored email_id.euqals to recipient && stored subject.equals to subject
//4.) If above statement is TRUE then update our Status with event and update this also in our Local DB


static NSString *kMMSStatus=@"https://api.twilio.com/2010-04-01/Accounts/ACd79cadf3f6ea9304a68f705b0dc2faf6/SMS/Messages.csv?DateSent=2017-11-08&PageSize=1000";
//Note: Add Current Date from which you take the Status.
//Method Type: GET
//Content Header: Add Content Header
//(Key,Value) : ("Authorization","Basic QUNkNzljYWRmM2Y2ZWE5MzA0YTY4ZjcwNWIwZGMyZmFmNjo1ODE0NzQ0Y2YxZTVmNTcxMjNiOTRjZmJkZTNlZTIzZQ==")
//
//Response:
//You will get CSV File for the day, and update all values as per CSV File and your requirement


@implementation ServiceCommunication

#pragma mark - Shared instance
+ (instancetype)sharedUser{
    static ServiceCommunication *serviceObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceObj = [[[self class] alloc] init];
    });
    return serviceObj;
}
#pragma mark - end

//CSV file download
- (void)csvFileDownloadService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
     [super downloadFIle:modelData.csvLink parameters:nil onSuccess:success onFailure:failure];
}

//Create MMS service
- (void)createMMSService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSMutableArray *tempArray=[NSMutableArray new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    
    for (DataModel *tempModel in modelData.multipleUserInfo) {
        [tempArray addObject:@{
                               @"first_name":tempModel.firstName,
                               @"last_name":tempModel.lastName,
                               @"email_id":tempModel.emailId,
                               @"phone":tempModel.phoneNo,
                               @"date":datestr,
                               @"status":@"PENDING"
                               }];
    }
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:[tempArray copy] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    
    NSData *jsonData3 = [NSJSONSerialization dataWithJSONObject:[modelData.mmsUrlLink copy] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString1 = [[NSString alloc] initWithData:jsonData3 encoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = @{@"user_data"    : jsonString,
                                 @"content_desc" : modelData.servicedescription,
                                 @"ref_array"    : jsonString1
                                 };
    DLog(@"review request %@",parameters);
    [super postVideo:kSendMMS filePath:modelData.selectedFilePath parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        if ([[NSString stringWithFormat:@"%@",response] containsString:@"blacklist rule"]) {
            success(@"blacklist rule");
        }
        else {
            success(@"dilivered");
        }
    } onFailure:failure];
}

//Create mail service
- (void)createMailService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSMutableArray *tempArray=[NSMutableArray new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    
    for (DataModel *tempModel in modelData.multipleUserInfo) {
        [tempArray addObject:@{
                               @"first_name":tempModel.firstName,
                               @"last_name":tempModel.lastName,
                               @"email_id":tempModel.emailId,
                               @"phone":tempModel.phoneNo,
                               @"date":datestr,
                               @"status":@"PENDING"
                               }];
    }
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:[tempArray copy] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    
    NSData *jsonData3 = [NSJSONSerialization dataWithJSONObject:[modelData.mmsUrlLink copy] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString1 = [[NSString alloc] initWithData:jsonData3 encoding:NSUTF8StringEncoding];
    NSDictionary *parameters = @{@"user_data": jsonString,
                                 @"content_desc": modelData.servicedescription,
                                 @"subject": modelData.serviceSubject,
                                 @"tag": modelData.serviceEmailTag,
                                 @"address":modelData.mmsAddress,
                                 @"ref_array":jsonString1
                                 };
    DLog(@"review request %@",parameters);
    [super postVideo:kSendEmail filePath:modelData.selectedFilePath parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(@"dilivered");
    } onFailure:failure];
}

//Fetch MMS status
- (void)fetchMMSStatusService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    [super downloadStatusFIle:[NSString stringWithFormat:@"https://api.twilio.com/2010-04-01/Accounts/ACd79cadf3f6ea9304a68f705b0dc2faf6/SMS/Messages.csv?DateSent=%@&PageSize=1000",[dateFormatter stringFromDate:[NSDate date]]] authentication:@"Basic QUNkNzljYWRmM2Y2ZWE5MzA0YTY4ZjcwNWIwZGMyZmFmNjo1ODE0NzQ0Y2YxZTVmNTcxMjNiOTRjZmJkZTNlZTIzZQ==" parameters:nil onSuccess:success onFailure:failure];
}

- (void)fetchMMSStatusServiceViaDate:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    [super downloadStatusFIle:[NSString stringWithFormat:@"https://api.twilio.com/2010-04-01/Accounts/ACd79cadf3f6ea9304a68f705b0dc2faf6/SMS/Messages.csv?DateSent=%@&PageSize=1000",modelData.date] authentication:@"Basic QUNkNzljYWRmM2Y2ZWE5MzA0YTY4ZjcwNWIwZGMyZmFmNjo1ODE0NzQ0Y2YxZTVmNTcxMjNiOTRjZmJkZTNlZTIzZQ==" parameters:nil onSuccess:success onFailure:failure];
}

- (void)fetchMailStatusService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    [super get:[NSString stringWithFormat:@"https://api.mailgun.net/v3/parkproject.asia/events?tags=%@",modelData.serviceEmailTag] authentication:@"Basic YXBpOmtleS0yNTEzZDUzNGU4NTJkZDUwZDY1NjcwYTk0NDFjYzYwZQ==" parameters:nil onSuccess:success onFailure:failure];
}

- (void)checkMailUserStatusService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    [super get:[NSString stringWithFormat:@"https://api.mailgun.net/v3/parkproject.asia/events?recipient=%@&limit=1",modelData.emailId] authentication:@"Basic YXBpOmtleS0yNTEzZDUzNGU4NTJkZDUwZDY1NjcwYTk0NDFjYzYwZQ==" parameters:nil onSuccess:success onFailure:failure];
}

//Login user service
- (void)loginUserService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"username": modelData.userNameModel
                                 };
    DLog(@"review request %@",parameters);
    [super postFormDataServics:[NSString stringWithFormat:@"%@%@",base,kCheckUser] parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

//Forgot password service
- (void)forgotPasswordService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"email_id": modelData.emailId
                                 };
    DLog(@"review request %@",parameters);
    [super postFormDataServics:[NSString stringWithFormat:@"%@%@",base,kForgotPassword] parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

//Password user service
- (void)passwordUserService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"password": modelData.passwordModel,
                                 @"user_id": modelData.userId
                                 };
    DLog(@"review request %@",parameters);
    [super postFormDataServics:[NSString stringWithFormat:@"%@%@",base,kCheckPassword] parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

- (void)saveProfileService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"user_id": [UserDefaultManager getValue:@"userId"],
                                 @"first_name": modelData.firstName,
                                 @"last_name": modelData.lastName,
                                 @"company_name": modelData.companyName,
                                 @"email_id": modelData.emailId,
                                 @"password": modelData.passwordModel
                                 };
    DLog(@"review request %@",parameters);
    [super postImageWithJson:[NSString stringWithFormat:@"%@%@",base,kSaveProfile] filePath:modelData.selectedFilePath parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

- (void)updateProfileService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"user_id": [UserDefaultManager getValue:@"userId"],
                                 @"first_name": modelData.firstName,
                                 @"last_name": modelData.lastName,
                                 @"company_name": modelData.companyName,
                                 @"email_id": modelData.emailId
                                 };
    DLog(@"review request %@",parameters);
    [super postImageWithJson:[NSString stringWithFormat:@"%@%@",base,kUpdateProfile] filePath:modelData.selectedFilePath parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

- (void)getProfileService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"user_id": [UserDefaultManager getValue:@"userId"]
                                 };
    DLog(@"review request %@",parameters);
    [super postFormDataServics:[NSString stringWithFormat:@"%@%@",base,kGetUserProfile] parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

//Fetch CSV file url
- (void)fetchCSVFileUrlService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"user_id": [UserDefaultManager getValue:@"userId"]
                                 };
    DLog(@"review request %@",parameters);
    [super postFormDataServics:[NSString stringWithFormat:@"%@%@",base,kGetUserCSV] parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

//Fetch user profile
- (void)userProfileService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"user_id": [UserDefaultManager getValue:@"userId"]
                                 };
    DLog(@"review request %@",parameters);
    [super postFormDataServics:[NSString stringWithFormat:@"%@%@",base,kGetUserProfile] parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}

//Change password
- (void)changePasswordService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"user_id": [UserDefaultManager getValue:@"userId"],
                                 @"old_password": modelData.oldpasswordModel,
                                 @"new_password": modelData.passwordModel
                                 };
    DLog(@"review request %@",parameters);
    [super postFormDataServics:[NSString stringWithFormat:@"%@%@",base,kChangePassword] parm:parameters onSuccess:^(id response) {
        DLog(@"%@",response);
        success(response);
    } onFailure:failure];
}
@end
