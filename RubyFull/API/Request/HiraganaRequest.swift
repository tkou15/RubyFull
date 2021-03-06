//
//  HiraganaRequest.swift
//  RubyFull
//
//  Created by kouichi on 2020/01/21.
//  Copyright © 2020 kouichi. All rights reserved.
//

import Foundation
import APIKit

struct HiraganaRequest: Request {
    let inputString: String
    
    typealias Response = HiraganaResponse
    
    var baseURL: URL {
        URL.init(string: "https://labs.goo.ne.jp")!
    }
    
    var path: String {
        "/api/hiragana"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> HiraganaResponse {
        if urlResponse.statusCode == 200{
            return try HiraganaResponse.decodeValue(object)
        }
        throw HiraganaError.badRequest
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Any? {
        [
            "app_id": "0e202c1445aaf8c3c38ffaf1b831bf4f40887879a5fe755ece31c63444a304c3",
            "sentence": inputString,
            "output_type": "hiragana"
        ]
    }
}
