//
//  HumanModel.swift
//  People
//
//  Created by Andrey on 09.03.2023.
//

import CoreLocation
import DeepDiff

struct HumanModel {
    let id: Int
    let name: String
    var location: CLLocation
    let avatarURL: String
}

// MARK: - Equatable
extension HumanModel: Equatable {
    
    static func == (lhs: HumanModel, rhs: HumanModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - DiffAware
extension HumanModel: DiffAware {
    typealias DiffId = Int

    var diffId: DiffId {
        id
    }

    static func compareContent(_ lhs: HumanModel, _ rhs: HumanModel) -> Bool {
        lhs == rhs
    }
}
