## Supports

KRHttpRequest supports ARC.

## How To Get Started

KRHttpRequest is using simple methods to do HTTP Request as easy quickly, it supports POST, GET, Upload Image.

``` objective-c
-(void)doPost
{
    dispatch_queue_t queue = dispatch_queue_create("_doPostQueue", NULL);
    dispatch_async(queue, ^(void) {
        __block KRHttpRequest *_krHttpRequest = [KRHttpRequest sharedManager];
        NSDictionary *_params = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"1",          @"id",
                                 @"Kalvar",     @"name",
                                 @"Apple Pie.", @"rows[]",
                                 @"Honest",     @"checks[0]",
                                 @"Happy",      @"checks[1]",
                                 nil];
        [_krHttpRequest sendPostURL:[NSURL URLWithString:@"http://sample.com/sweet.php"]
                             params:_params
                         completion:^(BOOL finished, NSData *responseData) {
                             dispatch_async(dispatch_get_main_queue(), ^(void) {
                                 if( finished )
                                 {
                                     NSString *_responseString = _krHttpRequest.responseString;
                                     NSDictionary *_userInfo   = _krHttpRequest.responseInfo;
                                     // ... Do Something.
                                 }
                             });
                         }];
    });
}

-(void)doGet
{
    __block KRHttpRequest *_krHttpRequest = [KRHttpRequest sharedManager];
    NSDictionary *_params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"1", @"id",
                             @"Hello, Open Source World.", @"message",
                             nil];
    [_krHttpRequest sendGetURL:[NSURL URLWithString:@"http://sample.com/happy.php"]
                        params:_params
                    completion:^(BOOL finished, NSData *responseData) {
                        if( finished )
                        {
                            NSString *_responseString = _krHttpRequest.responseString;
                            NSDictionary *_userInfo   = _krHttpRequest.responseInfo;
                            // ... Do Something.
                        }
                    }];
}

-(void)doPostAndUploadImage
{
    __block KRHttpRequest *_krHttpRequest = [KRHttpRequest sharedManager];
    NSDictionary *_params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"1",          @"id",
                             @"Kalvar",     @"name",
                             nil];
    NSDictionary *_imageInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIImage imageNamed:@"Default.png"], KRHttpRequestUploadInfoImageFile,
                                @"mySample.png",   KRHttpRequestUploadInfoImageName,
                                @"myImageVarName", KRHttpRequestUploadInfoImageParamName,
                                nil];
    [_krHttpRequest sendPostURL:[NSURL URLWithString:@"http://sample.com/upload.php"]
                         params:_params
                      imageInfo:_imageInfo
                     completion:^(BOOL finished, NSData *responseData) {
                         if( finished )
                         {
                             NSDictionary *_userInfo = _krHttpRequest.responseInfo;
                             //... Do Something.
                         }
                     }];
}

-(void)doUploadImage
{
    __block KRHttpRequest *_krHttpRequest = [KRHttpRequest sharedManager];
    NSDictionary *_imageInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIImage imageNamed:@"Default.png"], KRHttpRequestUploadInfoImageFile,
                                @"mySample.png",   KRHttpRequestUploadInfoImageName,
                                @"myImageVarName", KRHttpRequestUploadInfoImageParamName,
                                nil];
    [_krHttpRequest uploadAsyncImageInfo:_imageInfo
                                   toURL:[NSURL URLWithString:@"http://sample.com/upload.php"]
                              completion:^(BOOL finished, NSData *responseData) {
                                  if( finished )
                                  {
                                      NSDictionary *_userInfo = _krHttpRequest.responseInfo;
                                      //... Do Something.
                                  }
                              }];
}
```

## Version

KRHttpRequest now is V0.5 beta.

## License

KRHttpRequest is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.
