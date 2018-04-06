//
//  DataModel.h
//  VisualProspector
//
//  Created by apple on 20/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceCommunication.h"

@interface DataModel : NSObject
//Create mms message objects
@property (strong, nonatomic) NSString *mmsUrlName;
@property (strong, nonatomic) NSString *mmsLink;
@property (strong, nonatomic) NSMutableArray *multipleUserInfo;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *emailId;
@property (strong, nonatomic) NSString *phoneNo;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *servicedescription;
@property (strong, nonatomic) NSMutableArray *mmsUrlLink;
@property (strong, nonatomic) NSString *mmsAddress;
@property (strong, nonatomic) NSString *selectedFilePath;
@property (strong, nonatomic) NSString *selectedLogoPath;
@property (strong, nonatomic) NSString *serviceEmailTag;
@property (strong, nonatomic) NSString *serviceSubject;
@property (strong, nonatomic) NSString *userNameModel;
@property (strong, nonatomic) NSString *passwordModel;
@property (strong, nonatomic) NSString *oldpasswordModel;
@property (strong, nonatomic) NSString *confirmpasswordModel;
@property (strong, nonatomic) NSString *userId;
@property (assign, nonatomic) int isRegistered;
@property (strong, nonatomic) NSString *csvLink;

+ (instancetype)sharedUser;

- (void)csvFileDownloadOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
- (void)fetchCSVFileUrlOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
- (void)createMMSOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
- (void)createMailOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
//Fetch MMS status
- (void)fetchMMSStatusOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
- (void)fetchMailStatusOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
- (void)fetchMMSStatusServiceViaDteOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
//Login user service
- (void)loginUserOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
//Password user service
- (void)passwordUserOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
- (void)saveProfileService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
//Forgot password service
- (void)forgotPasswordService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
//Fetch user profile
- (void)fetchUserProfileOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
//Update profile service
- (void)updateProfileService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
//Change password
- (void)changePasswordService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure;
- (void)checkMailUserStatusOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
@end

