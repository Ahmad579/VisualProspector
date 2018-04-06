//
//  DataModel.m
//  VisualProspector
//
//  Created by apple on 20/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel
#pragma mark - Shared instance
+ (instancetype)sharedUser {
    
    static DataModel *modelObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelObj = [[[self class] alloc] init];
    });
    return modelObj;
}
#pragma mark - end

- (id)copyWithZone:(NSZone *)zone {
    DataModel *another = [[DataModel alloc] init];
    another.mmsLink= [self.mmsLink copyWithZone: zone];
    another.mmsUrlName= [self.mmsUrlName copyWithZone: zone];
    another.multipleUserInfo= [self.multipleUserInfo copyWithZone: zone];
    another.firstName= [self.firstName copyWithZone: zone];
    another.lastName= [self.lastName copyWithZone: zone];
    another.emailId= [self.emailId copyWithZone: zone];
    another.phoneNo= [self.phoneNo copyWithZone: zone];
    another.date= [self.date copyWithZone: zone];
    another.status= [self.status copyWithZone: zone];
    another.servicedescription= [self.servicedescription copyWithZone: zone];
    another.selectedFilePath= [self.selectedFilePath copyWithZone: zone];
    another.serviceEmailTag= [self.serviceEmailTag copyWithZone: zone];
    another.serviceSubject= [self.serviceSubject copyWithZone: zone];
    another.userNameModel= [self.userNameModel copyWithZone: zone];
    another.passwordModel= [self.passwordModel copyWithZone: zone];
    another.userId= [self.userId copyWithZone: zone];
    another.companyName= [self.companyName copyWithZone: zone];
    another.csvLink= [self.csvLink copyWithZone: zone];
    another.oldpasswordModel= [self.oldpasswordModel copyWithZone: zone];
    another.confirmpasswordModel= [self.confirmpasswordModel copyWithZone: zone];
    another.selectedLogoPath= [self.selectedLogoPath copyWithZone: zone];
    another.mmsUrlLink= [self.mmsUrlLink copyWithZone: zone];
    another.mmsAddress= [self.mmsAddress copyWithZone: zone];
    
    return another;
}
#pragma mark - end

#pragma mark - CSV file download
- (void)csvFileDownloadOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] csvFileDownloadService:self onSuccess:^(DataModel *userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Create MMS service
- (void)createMMSOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] createMMSService:self onSuccess:^(DataModel *userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Create Mail service
- (void)createMailOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] createMailService:self onSuccess:^(DataModel *userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Fetch MMS status
- (void)fetchMMSStatusOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] fetchMMSStatusService:self onSuccess:^(id userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}

- (void)fetchMMSStatusServiceViaDteOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] fetchMMSStatusServiceViaDate:self onSuccess:^(id userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Fetch mail status
- (void)fetchMailStatusOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] fetchMailStatusService:self onSuccess:^(id userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Check mail user status
- (void)checkMailUserStatusOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] checkMailUserStatusService:self onSuccess:^(id userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Login user service
- (void)loginUserOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] loginUserService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Login Error" message:@"Invalid credentials, please try again!!!" closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                if ([userData[@"is_register"] intValue]==0) {
                    self.isRegistered=0;
                    [UserDefaultManager setValue:[NSNumber numberWithBool:false] key:@"isRegister"];
                }
                else {
                    self.isRegistered=1;
                    [UserDefaultManager setValue:[NSNumber numberWithBool:true] key:@"isRegister"];
                }
                self.userId=userData[@"user_id"];
                [UserDefaultManager setValue:userData[@"user_id"] key:@"userId"];
                success (self);
            }
            
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Password user service
- (void)passwordUserOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] passwordUserService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Login Error" message:@"Invalid credentials, please try again!!!" closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                success (self);
            }
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Save profile service
- (void)saveProfileService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] saveProfileService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Alert" message:@"Something went wrong, please try again!!!" closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                [UserDefaultManager setValue:[NSNumber numberWithBool:true] key:@"isRegister"];
                [UserDefaultManager setValue:[self.selectedFilePath lastPathComponent] key:@"profileImage"];
                success (self);
            }
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Update profile service
- (void)updateProfileService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] updateProfileService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Alert" message:userData[@"msg"] closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                success (self);
            }
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Forgot password service
- (void)forgotPasswordService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] forgotPasswordService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Alert" message:userData[@"msg"] closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                [UserDefaultManager setValue:[NSNumber numberWithBool:true] key:@"isRegister"];
                [UserDefaultManager setValue:[self.selectedFilePath lastPathComponent] key:@"profileImage"];
                success (self);
            }
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Fetch CSV file url
- (void)fetchCSVFileUrlOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] fetchCSVFileUrlService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Alert" message:userData[@"msg"] closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                self.csvLink=userData[@"file"];
                success (self);
            }
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Fetch user profile
- (void)fetchUserProfileOnSuccess:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] userProfileService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Alert" message:userData[@"msg"] closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                NSMutableDictionary *profileData=[NSMutableDictionary new];
                [profileData setObject:[[userData objectForKey:@"data"] objectForKey:@"first_name"] forKey:@"firstName"];
                [profileData setObject:[[userData objectForKey:@"data"] objectForKey:@"last_name"] forKey:@"lastName"];
                [profileData setObject:[[userData objectForKey:@"data"] objectForKey:@"username"] forKey:@"userName"];
                [profileData setObject:[[userData objectForKey:@"data"] objectForKey:@"email"] forKey:@"emailId"];
                [profileData setObject:[[userData objectForKey:@"data"] objectForKey:@"company_name"] forKey:@"companyName"];
                if ([[[userData objectForKey:@"data"] objectForKey:@"company_logo"] isEqualToString:@"0"]) {
                    [profileData setObject:[NSNumber numberWithBool:false] forKey:@"isLogoExist"];
                }
                else {
                    [profileData setObject:[NSNumber numberWithBool:true] forKey:@"isLogoExist"];
                    [profileData setObject:[[userData objectForKey:@"data"] objectForKey:@"company_logo"] forKey:@"companyLogo"];
                    
                }
                [UserDefaultManager setValue:[profileData mutableCopy] key:@"ProfileData"];
                success (self);
            }
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Change password
- (void)changePasswordService:(void (^)(DataModel*))success onfailure:(void (^)(NSError *))failure {
    [[ServiceCommunication sharedManager] changePasswordService:self onSuccess:^(id userData) {
        if (success) {
            if ([userData[@"status"] intValue]==0) {
                [UserDefaultManager showErrorAlert:@"Alert" message:userData[@"msg"] closeButtonTitle:@"OK"];
                failure(nil);
            }else {
                success (self);
            }
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end
@end
