//
//  PeopleService.swift
//  People
//
//  Created by Andrey on 10.03.2023.
//

protocol PeopleService: AnyObject {
    typealias PeopleHandler = ([HumanModel]) -> Void
    
    var maxPageCount: Int { get }
    
    func getPeople(offset: Int, count: Int?) -> PeoplePage
    func searchPeople(query: String, completion: PeopleHandler)
}
