//
//  Container+Extensions.swift
//  People
//
//  Created by Andrey on 10.03.2023.
//

import Swinject

extension Container {
    
    static let defaultContainer: Container = {
        let container = Container()
        
        container.register(PeopleService.self) { _ in
            PeopleServiceMock()
        }
        
        container.register(ImageService.self) { _ in
            ImageServiceMock()
        }
        
        container.register(LocationService.self) { _ in
            LocationService()
        }
        .inObjectScope(.container)
        
        return container
    }()
}
