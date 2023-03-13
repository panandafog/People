//
//  CGRect+Extension.swift
//  People
//
//  Created by Andrey on 13.03.2023.
//

import Foundation

extension CGRect {
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
}
