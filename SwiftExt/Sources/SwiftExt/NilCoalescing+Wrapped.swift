//
//  File.swift
//  
//
//  Created by Marius Hötten-Löns on 08.04.21.
//

extension Optional {
    /// Using the nil-coalescing operator (??) can have a negative impact on compile time performance, whereas this
    /// alternativ is more compiler friendly.
    func or(_ alternative: Wrapped) -> Wrapped {
        switch self {
        case let .some(some):
            return some
        default:
            return alternative
        }
    }
}
