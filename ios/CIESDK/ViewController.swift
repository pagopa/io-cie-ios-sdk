//
//  ViewController.swift
//  CIESDK
//
//  Created by ugo chirico on 19/03/2020.
//

import UIKit
import WebKit;

class ViewController: UIViewController, WKNavigationDelegate {
    

    @IBOutlet weak var webView: WKWebView!
    
    public static let ciesdk = CIEIDSdk()
    private var deeplink : String? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.scrollView.bounces = false;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(JailbrakeDetector.isJailbroken().0)
        {
            let alert = UIAlertController(title: "CIE", message: "il dispositivo è Jailbroken", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
                                
        self.webView.navigationDelegate = self
        self.webView.customUserAgent = "Mozilla/5.0 (Linux; Android 7.0; Nexus 5 Build/LMY48B; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/43.0.2357.65 Mobile Safari/537.36"
        
        
        	
//        self.webView.load(URLRequest.init(url:  URL.init(string: "https://sp-ipzs-ssl.fbk.eu")!))
//        self.webView.load(URLRequest.init(url:  URL.init(string: "https://idserver.servizicie.interno.gov.it:8443/idp/")!))
//        self.webView.load(URLRequest.init(url:  URL.init(string: "https://app-backend.dev.io.italia.it/login?entityID=xx_servizicie_test&authLevel=SpidL2")!))
        
        self.webView.load(URLRequest.init(url:  URL.init(string: "https://app-backend.io.italia.it/login?entityID=xx_servizicie&authLevel=SpidL2")!))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        if ( (self.webView!.url?.absoluteString.contains("conversation"))!)
        {
            print("conversation")
            
            let script =
            // PRODUZIONE
            "window.location.href = 'https://idserver.servizicie.interno.gov.it/OpenApp?nextUrl=https://idserver.servizicie.interno.gov.it/idp/Authn/X509&name='+a+'&value='+b+'&authnRequestString='+c+'&OpText='+d+'&imgUrl='+f;"
            
            // COLLAUDO
//            "window.location.href = 'https://idserver.servizicie.interno.gov.it:8443/OpenApp?nextUrl=https://idserver.servizicie.interno.gov.it:8443/idp/Authn/X509&name='+a+'&value='+b+'&authnRequestString='+c+'&OpText='+d+'&imgUrl='+f;"
//
            
            self.webView.evaluateJavaScript(script) { (retval, error) in
                if(error != nil)
                {
                    print(error)
                }
                else
                {
                    print("ok \(retval)")
                    
                    self.deeplink = retval as? String
                    
                    print(self.deeplink)
                    self.webView!.stopLoading()
                    
                    ViewController.ciesdk.post(url: self.deeplink!, pin: "11223344", completed: { (error, response) in
                        
                        if(error == 0)
                        {
                            print(response)
                        }
                        else
                        {
                            print(error)
                        }

                        self.deeplink = nil
                        
                        DispatchQueue.main.async {
                            self.webView.load(URLRequest.init(url:  URL.init(string: response!)!))
                        }                                                
                    })
                    
                }
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        print("decidePolicyFor ")

        print("navigation " + self.webView!.url!.absoluteString)

        if(self.deeplink == nil)
        {
            decisionHandler(.allow)
        }
        else
        {
            decisionHandler(.cancel)
        }
    }    
}

