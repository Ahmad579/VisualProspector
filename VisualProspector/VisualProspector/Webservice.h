//
//  Webservice.h
//  VisualProspector
//
//  Created by apple on 02/10/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface Webservice : NSObject

@property(nonatomic,retain) AFHTTPSessionManager *manager;
@property (readwrite, nonatomic, copy) id success;
@property (readwrite, nonatomic, copy) id failure;
@property (strong, nonatomic) NSString *retryPath;
@property (strong, nonatomic) NSDictionary *retryParameters;
@property(nonatomic,retain) NSURLSession *session;

//Singleton instance
+ (id)sharedManager;
//Request with parameters
- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)get:(NSString *)path authentication:(NSString *)authentication parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)downloadFIle:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Post with video
- (void)postImage:(NSString *)path filePath:(NSString *)filePath parameters:(NSDictionary *)parameters  success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//Check response success
- (BOOL)isStatusOK:(id)responseObject;
- (void)postVideo:(NSString *)path filePath:(NSString *)filePath parm:(NSDictionary *)parm onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)downloadStatusFIle:(NSString *)path authentication:(NSString *)authentication parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)postFormDataServics:(NSString *)path parm:(NSDictionary *)parm onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)postImageWithJson:(NSString *)path filePath:(NSString *)filePath parm:(NSDictionary *)parm onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
@end
