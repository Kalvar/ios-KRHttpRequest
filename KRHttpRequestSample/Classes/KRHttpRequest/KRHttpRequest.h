//
//  KRHttpRequest.h
//  V0.5.1 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013 - 2014年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KRHttpRequestCompletionHandler)(BOOL finished, NSData *responseData);
typedef void (^KRHttpRequestDecodeCompletion)(BOOL finished, id jsonResponses);
typedef void (^KRHttpRequestErrorHandler)(BOOL finished, NSData *responseData);

//UIImage
extern const NSString *KRHttpRequestUploadInfoImageFile;
//UIImage Name
extern const NSString *KRHttpRequestUploadInfoImageName;
//UIImage Uploaded-Receive-Name
extern const NSString *KRHttpRequestUploadInfoImageParamName;

@interface KRHttpRequest : NSObject
{
    NSURL *requestURL;
    NSString *requestMethod;
    NSDictionary *postParams;
    CGFloat timeoutInterval;
    NSData *responseData;
    NSString *responseString;
    id responseInfo;
}

@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) NSString *requestMethod;
@property (nonatomic, strong) NSDictionary *postParams;
@property (nonatomic, assign) CGFloat timeoutInterval;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) id responseInfo;
@property (nonatomic, copy) KRHttpRequestCompletionHandler completionHandler;
@property (nonatomic, copy) KRHttpRequestDecodeCompletion decodeCompletion;
@property (nonatomic, copy) KRHttpRequestErrorHandler errorHandler;

+(KRHttpRequest *)sharedManager;

#pragma --mark Setters
-(void)setCompletionHandler:(KRHttpRequestCompletionHandler)_theCompletionHandler;
-(void)setDecodeCompletion:(KRHttpRequestDecodeCompletion)_theDecodeCompletion;
-(void)setErrorHandler:(KRHttpRequestErrorHandler)_theErrorHandler;

#pragma --mark Request Methods
-(void)sendPostURL:(NSURL *)_url params:(NSDictionary *)_params imageInfo:(NSDictionary *)_imageInfo completion:(KRHttpRequestCompletionHandler)_completion;
-(void)sendPostURL:(NSURL *)_url params:(NSDictionary *)_params completion:(KRHttpRequestCompletionHandler)_completion;
-(void)sendPostURL:(NSURL *)_url params:(NSDictionary *)_params decodeCompletion:(KRHttpRequestDecodeCompletion)_completion;

-(void)sendGetURL:(NSURL *)_url params:(NSDictionary *)_params completion:(KRHttpRequestCompletionHandler)_completion;
-(void)sendGetURL:(NSURL *)_url params:(NSDictionary *)_params decodeCompletion:(KRHttpRequestDecodeCompletion)_completion;

#pragma --mark Uploader Methods
-(NSDictionary *)buildImageInfoWithImage:(UIImage *)_image imageName:(NSString *)_imageName paramName:(NSString *)_paramName;
-(void)uploadSyncImageInfo:(NSDictionary *)_imageInfo toURL:(NSURL *)_url completion:(KRHttpRequestCompletionHandler)_completion;
-(void)uploadAsyncImageInfo:(NSDictionary *)_imageInfo toURL:(NSURL *)_url completion:(KRHttpRequestCompletionHandler)_completion;

#pragma --mark Parse Methods
-(id)parse;
-(id)parseData:(NSData *)_theResponseData;
-(NSDictionary *)parseToDictionary;
-(NSString *)praseToStringWithData:(NSData *)_theResponseData;
-(NSString *)parseToString;

#pragma --mark Getters
-(id)responseInfo;

@end
