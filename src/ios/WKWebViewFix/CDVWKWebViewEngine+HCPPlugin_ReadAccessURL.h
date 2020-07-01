//
//  CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.h
//
//  Created by Nikolay Demyankov on 04.04.16.
//

#import <Cordova/CDVAvailability.h>

#if defined __has_include && __has_include ("CDVWKWebViewEngine.h")
    #import "CDVWKWebViewEngine.h"
    #define FOUND_WK_WEB_VIEW 1
    @interface CDVWKWebViewEngine (HCPPlugin_ReadAccessURL)
#else
    #if CORDOVA_VERSION_MIN_REQUIRED >= __CORDOVA_6_1_0
        #define FOUND_WK_WEB_VIEW 1
        #import "../../../../CordovaLib/Classes/Private/Plugins/CDVWebViewEngine/CDVWebViewEngine.h"
        @interface CDVWebViewEngine (HCPPlugin_ReadAccessURL)
    #else
        #warning CANNOT FIND ANY WebViewEngine Include
    #endif
#endif

#if FOUND_WK_WEB_VIEW==1

- (id)loadRequest:(NSURLRequest*)request;

@end

#endif
