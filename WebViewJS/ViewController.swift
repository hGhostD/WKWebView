//
//  ViewController.swift
//  WebViewJS
//
//  Created by 胡佳文 on 2017/7/17.
//  Copyright © 2017年 胡佳文. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate,WKUIDelegate {


    var webView:WKWebView!
    var config:WKWebViewConfiguration!

    lazy var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor(red: 0, green: 147/255, blue: 1, alpha: 1)
        progress.trackTintColor = UIColor.clear
        return progress
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 2)
        self.progressView.isHidden = true
        UIView.animate(withDuration: 1) { 
            self.progressView.progress = 0.0
        }



        //监听状态
//        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
//        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //注册js方法

        // 创建配置
        let config = WKWebViewConfiguration()
        // 创建UserContentController（提供JavaScript向webView发送消息的方法）
        let userContent = WKUserContentController()
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        userContent.add(self, name: "webViewApp")
        // 将UserConttentController设置到配置文件
        config.userContentController = userContent

        webView = WKWebView(frame: self.view.frame, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        self.view.addSubview(webView)

        //加载本地页面
        webView.load(URLRequest(url: NSURL.fileURL(withPath: Bundle.main.path(forResource: "index", ofType: "html")!)))

        //允许手势，后退前进等操作
        webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.navigationItem.title = "加载中。。。"
        UIView.animate(withDuration: 0.5) { 
            self.progressView.progress = Float(self.webView.estimatedProgress)
        }
    }

    //alert捕获
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        //通知回调
        completionHandler()
        //使用ios-alert 代替js的alert
        let alert = UIAlertController(title: "ios-alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler:nil))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    //被js调用的原生方法
    func hello(name:String){
        let alert = UIAlertController(title: "app", message: "hello :\(name)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler:nil))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: WKScriptMessageHandler {
    //实现js调用ios的handle委托
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //接受传过来的消息从而决定app调用的方法
        let dict = message.body as! Dictionary<String,String>
        let method:String = dict["method"]!
        let param1:String = dict["param1"]!
        if method=="hello"{
            hello(name: param1)
        }
    }
}

