//
//  PeoplePage.swift
//  People
//
//  Created by Andrey on 12.03.2023.
//

import Combine

struct PeoplePage {
    let people: Published<[HumanModel]>.Publisher
    let offset: Int
    let count: Int
}
