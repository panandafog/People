//
//  ImageServiceMock.swift
//  People
//
//  Created by Andrey on 12.03.2023.
//

import UIKit

class ImageServiceMock: ImageService {
    func getAvatar(url: String, completion: ImageHandler) {
        completion(UIImage(named: url))
    }
}
