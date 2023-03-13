//
//  ImageService.swift
//  People
//
//  Created by Andrey on 12.03.2023.
//

import UIKit

protocol ImageService: AnyObject {
    typealias ImageHandler = (UIImage?) -> Void
    
    func getAvatar(url: String, completion: ImageHandler)
}
