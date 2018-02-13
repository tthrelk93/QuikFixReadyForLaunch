//
//  StripeConnectViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 2/2/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import WebKit


class StripeConnectViewController: UIViewController, WKUIDelegate, WKNavigationDelegate  {

    var webView: WKWebView!
    /*override func loadView() {
        
        
        
        
    }*/
    @IBAction func connectStripePressed(_ sender: Any) {
       
        print("webViewPressed")
       /* let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.isHidden = false
        webView.navigationDelegate = self*/
        
        let url : NSString = "https://connect.stripe.com/express/oauth/authorize?redirect_uri=https://quikfixjobs.com/home/&client_id=ca_B4F4BbbvDs0jH5cSZpYnkB9yLpCsdQVM&state={\(Auth.auth().currentUser!.uid)}" as NSString
        let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        print(searchURL)
        
        // url = URL(string: )
        print("fucking URL: \(url)")
        
        //let url = urlComponents.url!
        //var request = URLRequest(url: searchURL as URL)
        //webView.load(request)
        //view.addSubview(webView)
        //view.bringSubview(toFront: webView)
       
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(searchURL as URL)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(searchURL as URL)
        }
        
        //view.sendSubview(toBack: webView)
        //let webConfiguration = WKWebViewConfiguration()
        
        //webView.uiDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
