//
//  KRHttpRequest.m
//  V0.5 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRHttpRequest.h"

const NSString *KRHttpRequestUploadInfoImageFile      = @"image";
const NSString *KRHttpRequestUploadInfoImageName      = @"image_name";
const NSString *KRHttpRequestUploadInfoImageParamName = @"param_name";

@interface KRHttpRequest ()

@end

@interface KRHttpRequest (fixPrivate)

-(void)_initWithVars;
-(void)_syncUploadImage:(UIImage *)_image imageName:(NSString *)_imageName paramName:(NSString *)_paramName toURL:(NSURL *)_url;

@end

@implementation KRHttpRequest (fixPrivate)

-(void)_initWithVars
{
    self.requestURL         = nil;
    self.requestMethod      = @"GET";
    self.postParams         = nil;
    self.timeoutInterval    = 30.0f;
    self.responseData       = nil;
    self.responseString     = @"";
    self.completionHandler  = nil;
    self.errorHandler       = nil;
}

-(void)_syncUploadImage:(UIImage *)_image imageName:(NSString *)_imageName paramName:(NSString *)_paramName toURL:(NSURL *)_url
{
    if( !_image )
    {
        self.responseData   = nil;
        self.responseString = nil;
        return;
    }
    //To convert your image file to raw.
    NSData *imageData = UIImagePNGRepresentation( _image );
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:_url];
    [request setHTTPMethod:@"POST"];
    //Boundary and Header.
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    //Your uploading file.
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    /*
     * Declares the PHP received $_FILES variables.
     *   -> $_FILES['_varName']['name']   = _sample.png
     *   -> $_FILES['param_name']['name'] = image_name
     *
     * Sample :
     *   serverReceivedName = @"myVarName";
     *   imageFileName      = @"myImage.png";
     *   => $_FILES['myVarName']['name'] = 'myImage.png'
     */
    NSString *_contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
                                     _paramName ,
                                     _imageName];
    [bodyData appendData:[_contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[NSData dataWithData:imageData]];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:bodyData];
    NSError *_error;
    self.responseData   = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&_error];
    self.responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    request = nil;
}

@end

@implementation KRHttpRequest

@synthesize requestURL;
@synthesize requestMethod;
@synthesize postParams;
@synthesize timeoutInterval;
@synthesize responseData   = _responseData;
@synthesize responseString = _responseString;
@synthesize responseInfo   = _responseInfo;
@synthesize completionHandler;
@synthesize errorHandler;


+(KRHttpRequest *)sharedManager
{
    static dispatch_once_t pred;
    static KRHttpRequest *_singleton = nil;
    dispatch_once(&pred, ^{
        _singleton = [[KRHttpRequest alloc] init];
        [_singleton _initWithVars];
    });
    return _singleton;
}

-(id)init
{
    self = [super init];
    if( self )
    {
        [self _initWithVars];
    }
    return self;
}

#pragma --mark Request Methods
-(void)sendPostURL:(NSURL *)_url params:(NSDictionary *)_params imageInfo:(NSDictionary *)_imageInfo completion:(KRHttpRequestCompletionHandler)_completion
{
    if( !_url )
    {
        if( _completion )
        {
            _completion(NO, nil);
        }
        return;
    }
    NSMutableString *_paramsString = nil;
    if( _params )
    {
        _paramsString = [[NSMutableString alloc] initWithString:@""];
        __block NSInteger _index = 0;
        [_params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if( _index > 0 )
             {
                 [_paramsString appendString:@"&"];
             }
             [_paramsString appendFormat:@"%@=%@", key, obj];
             ++_index;
         }];
    }
    if( !self.timeoutInterval )
    {
        self.timeoutInterval = 30.0f;
    }
    NSMutableURLRequest *_theRequest = [NSMutableURLRequest requestWithURL:_url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:self.timeoutInterval];
    [_theRequest setHTTPMethod:@"POST"];
    NSMutableData *_postData = [NSMutableData data];
    if( _paramsString )
    {
        [_postData appendData:[_paramsString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    }
    //There an Uploading Image
    if( _imageInfo )
    {
        UIImage *_image    = [_imageInfo objectForKey:KRHttpRequestUploadInfoImageFile];
        NSData *_imageData = UIImagePNGRepresentation(_image);
        if( [_imageData length] > 0 )
        {
            //Boundary and Header.
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [_theRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
            //Uploading file.
            [_postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            /*
             * Declares the PHP received $_FILES variables.
             *   -> $_FILES['_varName']['name']   = _sample.png
             *   -> $_FILES['param_name']['name'] = image_name
             *
             * Sample :
             *   serverReceivedName = @"myVarName";
             *   imageFileName      = @"myImage.png";
             *   => $_FILES['myVarName']['name'] = 'myImage.png'
             */
            NSString *_serverReceivedName = [_imageInfo objectForKey:KRHttpRequestUploadInfoImageParamName];
            NSString *_imageFileName      = [_imageInfo objectForKey:KRHttpRequestUploadInfoImageName];
            NSString *_contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
                                             _serverReceivedName,
                                             _imageFileName];
            [_postData appendData:[_contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
            [_postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [_postData appendData:[NSData dataWithData:_imageData]];
            [_postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }       
    }
    [_theRequest setHTTPBody:_postData];
    _responseData   = [NSURLConnection sendSynchronousRequest:_theRequest returningResponse:nil error:nil];
    _responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    _theRequest = nil;
    if( _completion )
    {
        _completion(YES, _responseData);
    }
}

-(void)sendPostURL:(NSURL *)_url params:(NSDictionary *)_params completion:(KRHttpRequestCompletionHandler)_completion
{
    if( !_url )
    {
        if( _completion )
        {
            _completion(NO, nil);
        }
        return;
    }
    NSMutableString *_paramsString = nil;
    if( _params )
    {
        _paramsString = [[NSMutableString alloc] initWithString:@""];
        __block NSInteger _index = 0;
        [_params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            if( _index > 0 )
            {
                [_paramsString appendString:@"&"];
            }
            [_paramsString appendFormat:@"%@=%@", key, obj];
            ++_index;
        }];
    }
    NSData *_postData = [_paramsString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    if( !self.timeoutInterval )
    {
        self.timeoutInterval = 30.0f;
    }
    NSMutableURLRequest *_theRequest = [NSMutableURLRequest requestWithURL:_url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:self.timeoutInterval];
    [_theRequest setHTTPMethod:@"POST"];
    [_theRequest setHTTPBody:_postData];
    _responseData   = [NSURLConnection sendSynchronousRequest:_theRequest returningResponse:nil error:nil];
    _responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    _theRequest = nil;
    if( _completion )
    {
        _completion(YES, _responseData);
    }
}

-(void)sendGetURL:(NSURL *)_url params:(NSDictionary *)_params completion:(KRHttpRequestCompletionHandler)_completion
{
    if( !_url )
    {
        if( _completion )
        {
            _completion(NO, nil);
        }
        return;
    }
    NSMutableString *_paramsString = nil;
    if( _params )
    {
        _paramsString = [[NSMutableString alloc] initWithString:@""];
        [_params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             NSString *_encodeString = [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
             [_paramsString appendFormat:@"%@=%@", key, _encodeString];
             if( !stop )
             {
                 [_paramsString appendString:@"&"];
             }
         }];
    }
    if( !self.timeoutInterval )
    {
        self.timeoutInterval = 30.0f;
    }
    if( _paramsString )
    {
        NSString *_combineURL = [NSString stringWithFormat:@"%@?%@", _url, _paramsString];
        _url = [NSURL URLWithString:_combineURL];
    }
    NSMutableURLRequest *_theRequest = [NSMutableURLRequest requestWithURL:_url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:self.timeoutInterval];
    [_theRequest setHTTPMethod:@"GET"];
    _responseData   = [NSURLConnection sendSynchronousRequest:_theRequest returningResponse:nil error:nil];
    _responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    _theRequest = nil;
    if( _completion )
    {
        _completion(YES, _responseData);
    }
}

#pragma --mark Uploader Methods
-(NSDictionary *)buildImageInfoWithImage:(UIImage *)_image imageName:(NSString *)_imageName paramName:(NSString *)_paramName
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            _image,     KRHttpRequestUploadInfoImageFile,
            _imageName, KRHttpRequestUploadInfoImageName,
            _paramName, KRHttpRequestUploadInfoImageParamName,
            nil];
}

-(void)uploadSyncImageInfo:(NSDictionary *)_imageInfo toURL:(NSURL *)_url completion:(KRHttpRequestCompletionHandler)_completion
{
    if( !_imageInfo )
    {
        if( _completion )
        {
            _completion(NO, nil);
        }
        return;
    }
    [self _syncUploadImage:[_imageInfo objectForKey:KRHttpRequestUploadInfoImageFile]
                 imageName:[_imageInfo objectForKey:KRHttpRequestUploadInfoImageParamName]
                 paramName:[_imageInfo objectForKey:KRHttpRequestUploadInfoImageName]
                     toURL:_url];
    if( _completion )
    {
        _completion(YES, _responseData);
    }
}

-(void)uploadAsyncImageInfo:(NSDictionary *)_imageInfo toURL:(NSURL *)_url completion:(KRHttpRequestCompletionHandler)_completion
{
    dispatch_queue_t queue = dispatch_queue_create("_startAsyncUploadImageInfoQueue", NULL);
    dispatch_async(queue, ^(void) {
        [self _syncUploadImage:[_imageInfo objectForKey:KRHttpRequestUploadInfoImageFile]
                     imageName:[_imageInfo objectForKey:KRHttpRequestUploadInfoImageParamName]
                     paramName:[_imageInfo objectForKey:KRHttpRequestUploadInfoImageName]
                         toURL:_url];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if( _completion )
            {
                _completion(YES, _responseData);
            }
        });
    });
}

#pragma --mark Parse Methods
-(NSDictionary *)parseDictionaryWithReceivedData:(NSData *)_theResponseData
{
    if( !_theResponseData )
    {
        return nil;
    }
    return (NSDictionary *)[NSJSONSerialization JSONObjectWithData:_theResponseData
                                                           options:0
                                                             error:nil];
}

-(NSDictionary *)parseDictionaryWithCurrentReceivedData
{
   return [self parseDictionaryWithReceivedData:_responseData];
}

-(NSString *)praseStringWithReceivedData:(NSData *)_theResponseData
{
    return [[NSString alloc] initWithData:_theResponseData encoding:NSUTF8StringEncoding];
}

-(NSString *)parseStringWithCurrentReceivedData
{
    return [self praseStringWithReceivedData:_responseData];
}

#pragma --mark Getters
-(id)responseInfo
{
    id _userInfo = nil;
    if( _responseData )
    {
        _userInfo = [NSJSONSerialization JSONObjectWithData:_responseData
                                                    options:0
                                                      error:nil];
    }
    return _userInfo;
}

@end
