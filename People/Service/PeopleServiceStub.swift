//
//  PeopleServiceStub.swift
//  People
//
//  Created by Andrey on 10.03.2023.
//

import CoreLocation

class PeopleServiceStub: PeopleService {
    
    private let peopleCount = 100
    private let avatarsCount = 6
    let maxPageCount = 20
    
    private var avatarURLS: [String] = []
    private var allPeople: [HumanModel] = []
    @Published private var loadedPeople: [HumanModel] = []
    
    private var timer: Timer?
    
    init() {
        // Create people
        
        for index in 0..<peopleCount {
            allPeople.append(HumanModel(
                id: index,
                name: "User " + String(index),
                location: .init(
                    latitude: Double.random(in: 0...10),
                    longitude: Double.random(in: 0...10)
                ),
                avatarURL: "avatar" + String(Double.random(in: 1.0...Double(avatarsCount)))
            ))
        }
        
        // Update people
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [self] _ in
            for index in 0..<allPeople.count {
                let offset = Double.random(in: -1...1)
                allPeople[index].location = .init(
                    latitude: allPeople[index].location.coordinate.latitude + offset,
                    longitude: allPeople[index].location.coordinate.longitude + offset
                )
            }
            let newPeople = loadedPeople.compactMap { loaded in
                allPeople.first { $0 == loaded }
            }
            loadedPeople = newPeople
        }
    }
    
    // MARK: Requests
    
    func getPeople(offset: Int, count: Int?) -> PeoplePage {
        let offset = min(max(offset, 0), allPeople.count - 1)
        let count = min(max(count ?? maxPageCount, 0), allPeople.count - 1 - offset)
        loadedPeople = Array(allPeople[offset...(offset + count)])
        return PeoplePage(people: $loadedPeople, offset: offset, count: count)
    }
    
    func searchPeople(query: String, completion: PeopleHandler) {
        completion(allPeople.filter { $0.name.contains(query) })
    }
}
