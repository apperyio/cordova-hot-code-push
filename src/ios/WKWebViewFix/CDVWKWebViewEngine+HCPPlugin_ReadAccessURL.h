//
//  CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.h
//
//  Created by Nikolay Demyankov on 04.04.16.
//

#if WK_WEB_VIEW_ONLY==1

#import <Cordova/CDVAvailability.h>

#if defined __has_include && __has_include ("CDVWKWebViewEngine.h")
    #import "CDVWKWebViewEngine.h"
@interface CDVWKWebViewEngine (HCPPlugin_ReadAccessURL)
#else
#if CORDOVA_VERSION_MIN_REQUIRED >= __CORDOVA_6_1_0
    #import "../../../../CordovaLib/Classes/Private/Plugins/CDVWebViewEngine/CDVWebViewEngine.h"
@interface CDVWebViewEngine (HCPPlugin_ReadAccessURL)
#else
#error CANNOT FIND ANY WebViewEngine Include
#endif
#endif

- (id)loadRequest:(NSURLRequest*)request;

@end

#endif
