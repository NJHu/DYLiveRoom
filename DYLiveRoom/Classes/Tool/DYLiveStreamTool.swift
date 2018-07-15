//
//  DYLiveStreamTool.swift
//  DYLiveRoom
//
//  Created by NJHu on 2018/7/15.
//

import UIKit
import WebKit

public enum DYLiveStreamToolError: Error {
    case timeout
    case pageFail
}

public class DYLiveStreamTool: NSObject {
    public static var sharedTool: DYLiveStreamTool = DYLiveStreamTool()
    private var handles = [WKWebView: [String: Any]]()
}

extension DYLiveStreamTool {
    public func nj_getStreamUrl(roomId: String, success: @escaping (_ streamUrl: String) -> (), failure: @escaping (_ error: Error) -> ()) {
        
        let webView = addWkWebView()
        setUpWkWebView(webView: webView)
        
        handles[webView] = ["success": success, "failure": failure]
        
        let urlStr = "http://www.douyu.com/" + roomId
        if let url = URL(string: urlStr) {
            let urlRequestM = NSMutableURLRequest(url: url)
            webView.load(urlRequestM.copy() as! URLRequest)
        }
        
        let tinyDelay = DispatchTime.now() + Double(Int64(6 * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: tinyDelay) {
            self.failCallback(webView: webView, error: DYLiveStreamToolError.timeout)
        }
    }
}

// MARK:- handle
extension DYLiveStreamTool {
    private func failCallback(webView: WKWebView, error: Error) {
        if let fail =  self.handles[webView]?["failure"] as? ((_ error: Error) -> ()) {
            fail(error)
            self.handles.removeValue(forKey: webView)
        }
    }
    private func successCallback(webView: WKWebView, streamUrl: String) {
        if let success =  self.handles[webView]?["success"] as? ((_ streamUrl: String) -> ()) {
            success(streamUrl)
            self.handles.removeValue(forKey: webView)
        }
    }
}

// MARK:- setting
extension DYLiveStreamTool {
    private func addWkWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), configuration: configuration)
        return webView
    }
    private func setUpWkWebView(webView: WKWebView?) -> Void {
        let preferences = WKPreferences()
        
        //The minimum font size in points default is 0;
        preferences.minimumFontSize = 0;
        //是否支持JavaScript
        preferences.javaScriptEnabled = true;
        //不通过用户交互，是否可以打开窗口
        preferences.javaScriptCanOpenWindowsAutomatically = true;
        webView?.configuration.preferences = preferences
        
        webView?.configuration.userContentController = WKUserContentController()
        
        // 检测各种特殊的字符串：比如电话、网站
        webView?.configuration.dataDetectorTypes = .all
        // 播放视频
        webView?.configuration.allowsInlineMediaPlayback = true;
        
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        webView?.isOpaque = false
        
        webView?.backgroundColor = UIColor.clear
        
        webView?.allowsBackForwardNavigationGestures = true
        
        webView?.allowsLinkPreview = true
        
        webView?.uiDelegate = self;
        
        webView?.navigationDelegate = self;
        
        if #available(iOS 11, *) {
            webView?.scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
}


// MARK:- WKNavigationDelegate-导航监听
extension DYLiveStreamTool: WKNavigationDelegate {
    // 1, 在发送请求之前，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    // 3, 6, 加载 HTTPS 的链接，需要权限认证时调用  \  如果 HTTPS 是用的证书在信任列表中这不要此代理方法
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }else {
            completionHandler(.performDefaultHandling, nil)
        }
        
        webView.evaluateJavaScript("document.getElementById('html5player-video').src") { (streamUrl, error) in
            if let stream = streamUrl as? String, stream.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                self.successCallback(webView: webView, streamUrl: stream)
            }
        }
    }
    // 4, 在收到响应后，决定是否跳转, 在收到响应后，决定是否跳转和发送请求之前那个允许配套使用
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    // 1-2, 接收到服务器跳转请求之后调用
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    // 8, WKNavigation导航错误
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    //当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用回调函数
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
        self.failCallback(webView: webView, error: DYLiveStreamToolError.pageFail)
    }
}
// MARK:- WKNavigationDelegate-网页监听
extension DYLiveStreamTool {
    // 2, 页面开始加载时调用
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    // 5,内容开始返回时调用
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    // 7页面加载完成之后调用
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    // 9页面加载失败时调用
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.failCallback(webView: webView, error: DYLiveStreamToolError.pageFail)
    }
}

// MARK:- WKUIDelegate
extension DYLiveStreamTool: WKUIDelegate {
    
}



