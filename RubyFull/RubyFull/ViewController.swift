//
//  ViewController.swift
//  RubyFull
//
//  Created by takahashi kouichi on 2020/01/16.
//  Copyright © 2020 kouichi. All rights reserved.
//

import UIKit
import Combine
import APIKit

struct HiraganaResponse : Codable {
    let converted: String
    let output_type: String
    let request_id: String
}

struct HiraganaRequest: Request {
    
    typealias Response = HiraganaResponse
    var baseURL: URL {
        URL.init(string: "https://labs.goo.ne.jp")!
    }
    
    var path: String {
        "/api/hiragana"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> HiraganaResponse {
        return HiraganaResponse.init(converted: "a", output_type: "b", request_id: "c")
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Any? {
        [
            "app_id": "0e202c1445aaf8c3c38ffaf1b831bf4f40887879a5fe755ece31c63444a304c3",
            "sentence": "今日はいい天気ですね",
            "output_type": "hiragana"
        ]
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let request = HiraganaRequest()
        
        Session.send(request) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}
