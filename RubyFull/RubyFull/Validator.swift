//
//  Validator.swift
//  RubyFull
//
//  Created by kouichi on 2020/01/19.
//  Copyright © 2020 kouichi. All rights reserved.
//

import Foundation

protocol InvalidStatus: Equatable {

}

enum InvalidID: InvalidStatus {
    case empty
    case hasNotKanji
}


extension InvalidID {
    var errorTitle: String{
        switch self {
        case .empty:
            return "文字列を入力してください"
        case .hasNotKanji:
            return "入力された文字列に漢字が含まれていません"
        }
    }
}

enum ValidationStatus<Invalid: InvalidStatus> {
    case valid
    case invalid(Invalid)
}

struct ValidationContainer<Target, Invalid: InvalidStatus> {

    private let target: Target
    private let invalid: Invalid?

    private func finish() -> ValidationStatus<Invalid> {

        if let invalid = invalid {
            return .invalid(invalid)

        } else {
            return .valid
        }

    }

    static func validate(_ target: Target, with validation: (Self) -> Self) -> ValidationStatus<Invalid> {

        let container = Self.init(target: target, invalid: nil)
        let result = validation(container).finish()

        return result

    }

    func guarantee(_ condition: (Target) -> Bool, otherwise invalidStatus: Invalid) -> Self {

        // If the container already has an invalid status, skip the condition check.
        guard invalid == nil else {
            return self
        }

        if condition(target) == true {
            return self

        } else {
            return ValidationContainer(target: target, invalid: invalidStatus)
        }

    }

}


typealias KanjiValidator = ValidationContainer<String, InvalidID>
extension ValidationContainer where Target == String, Invalid == InvalidID {

    func isNotEmpty() -> Self {
        return guarantee({ !$0.isEmpty }, otherwise: .empty)
    }

    func hasKanji() -> Self {
        return guarantee({ $0.hasKanji() }, otherwise: .hasNotKanji)

    }
}

extension String {
    func hasKanji() -> Bool {
        let pattern = "[\\p{Han}]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
        return matches.count > 0
    }
}
