//
//  ViewController.swift
//  DetectCall
//
//  Created by Nguyễn Thành on 7/17/17.
//  Copyright © 2017 Nguyễn Thành. All rights reserved.
//

import UIKit
class ViewController: UIViewController,XMLParserDelegate {
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    override func viewDidLoad() {
        super.viewDidLoad()
        beginParse()
        
    
        // Do any additional setup after loading the view, typically from a nib.
    }
    func beginParse() {
        posts = []
        parser = XMLParser(contentsOf: URL(string: "http://dantri.com.vn/xa-hoi/phong-su-ky-su.rss")!)!
        parser.delegate = self
        parser.parse()
        print(parser)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

