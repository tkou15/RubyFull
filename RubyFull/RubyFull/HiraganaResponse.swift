//
//  HiraganaResponse.swift
//  RubyFull
//
//  Created by kouichi on 2020/01/21.
//  Copyright © 2020 kouichi. All rights reserved.
//
import Foundation
import APIKit
import Himotoki

struct HiraganaResponse : Decodable {
    let hiragana: String
    static func decode(_ e: Extractor) throws -> HiraganaResponse {
        return try HiraganaResponse(
            hiragana: e.value("converted"))
    }
}


