//
//  ServiceCommunication.h
//  VisualProspector
//
//  Created by apple on 02/10/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Webservice.h"
#import "DataModel.h"
@class DataModel;

@interface ServiceCommunication : Webservice
//Singleton method
+ (instancetype)sharedUser;
//CSV file download
- (void)csvFileDownloadService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Fetch CSV file url
- (void)fetchCSVFileUrlService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Create MMS service
- (void)createMMSService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)createMailService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Fetch MMS status
- (void)fetchMMSStatusService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)fetchMailStatusService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)fetchMMSStatusServiceViaDate:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Login user service
- (void)loginUserService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Password user service
- (void)passwordUserService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)saveProfileService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Forgot password service
- (void)forgotPasswordService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Fetch user profile
- (void)userProfileService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)updateProfileService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Change password
- (void)changePasswordService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)checkMailUserStatusService:(DataModel *)modelData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
@end

