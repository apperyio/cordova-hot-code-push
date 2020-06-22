//
//  CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.m
//
//  Created by Nikolay Demyankov on 04.04.16.
//

#if WK_WEB_VIEW_ONLY==1

#import "CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.h"
#import <objc/message.h>
#import "HCPFilesStructure.h"

#define CDV_WKWEBVIEW_FILE_URL_LOAD_SELECTOR @"loadFileURL:allowingReadAccessToURL:"

@implementation CDVWKWebViewEngine (HCPPlugin_ReadAccessURL)

- (id)loadRequest:(NSURLRequest*)request
{
    if ([self canLoadRequest:request]) { // can load, differentiate between file urls and other schemes
        if (request.URL.fileURL) {
            NSObject *handler = [[((WKWebView*)self.engineWebView) configuration] urlSchemeHandlerForURLScheme:@"ionic"];
            if (handler) {
                NSURL* startURL = [NSURL URLWithString:((CDVViewController *)self.viewController).startPage];

                NSString* startFilePath = [self.commandDelegate pathForResource:[startURL path]];
                NSURL *localServerUrl = [NSURL URLWithString:[self performSelector:@selector(CDV_LOCAL_SERVER)]];
                NSURL *url = [localServerUrl URLByAppendingPathComponent:request.URL.path];
                if ([request.URL.path isEqualToString:startFilePath]) {
                    url = [NSURL URLWithString:[self performSelector:@selector(CDV_LOCAL_SERVER)]];
                } else {
                    NSURL* readAccessUrl = [HCPFilesStructure pluginRootFolder];
                    if ([request.URL.path containsString:readAccessUrl.path]) {
                        url = [NSURL URLWithString:[request.URL.path substringFromIndex:readAccessUrl.path.length] relativeToURL:localServerUrl];
                        if ([handler respondsToSelector:@selector(setAssetPath:)])
                            [handler performSelector:@selector(setAssetPath:) withObject:readAccessUrl.path];
                    }
                }
                if(request.URL.query) {
                    url = [NSURL URLWithString:[@"?" stringByAppendingString:request.URL.query] relativeToURL:url];
                }
                if(request.URL.fragment) {
                    url = [NSURL URLWithString:[@"#" stringByAppendingString:request.URL.fragment] relativeToURL:url];
                }
                request = [NSURLRequest requestWithURL:url];
                return [(WKWebView*)self.engineWebView loadRequest:request];
            } else {
                SEL wk_sel = NSSelectorFromString(CDV_WKWEBVIEW_FILE_URL_LOAD_SELECTOR);
                
                // by default we set allowingReadAccessToURL property to the plugin's root folder,
                // so the WKWebView would load our updates from it.
                NSURL* readAccessUrl = [HCPFilesStructure pluginRootFolder];
                
                // if we are loading index page from the bundle - we need to go up in the folder structure, so the next load from the external storage would work
                if (![request.URL.absoluteString containsString:readAccessUrl.absoluteString]) {
                    readAccessUrl = [[[request.URL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
                }
                
                return ((id (*)(id, SEL, id, id))objc_msgSend)(self.engineWebView, wk_sel, request.URL, readAccessUrl);
            }
        } else {
            return [(WKWebView*)self.engineWebView loadRequest:request];
        }
    } else { // can't load, print out error
        NSString* errorHtml = [NSString stringWithFormat:
                               @"<!doctype html>"
                               @"<title>Error</title>"
                               @"<div style='font-size:2em'>"
                               @"   <p>The WebView engine '%@' is unable to load the request: %@</p>"
                               @"   <p>Most likely the cause of the error is that the loading of file urls is not supported in iOS %@.</p>"
                               @"</div>",
                               NSStringFromClass([self class]),
                               [request.URL description],
                               [[UIDevice currentDevice] systemVersion]
                               ];
        return [self loadHTMLString:errorHtml baseURL:nil];
    }
}

@end

#endif
