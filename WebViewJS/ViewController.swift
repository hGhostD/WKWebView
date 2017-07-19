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
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "webViewApp")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 2)
        self.progressView.isHidden = true
        UIView.animate(withDuration: 1) { 
            self.progressView.progress = 0.0
        }



        //监听状态
//        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
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

        //加载本地页面
        webView.load(URLRequest(url: NSURL.fileURL(withPath: Bundle.main.path(forResource: "index", ofType: "html")!)))
//        webView.load(URLRequest.init(url: URL.init(string: "http://192.168.2.168:8080/")!))

        //允许手势，后退前进等操作
        webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
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
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler:{ _ in 
            self.webView.evaluateJavaScript("hu('这是来自iOS的调用,执行了JS代码')") { (item, error) in
                print(item ?? "错误",error ?? "没有错误")
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.isHidden = false
            
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1 {
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.progressView.isHidden = true
                }, completion: nil)
            }
        }
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

