//
//  String+Localization.swift
//  People
//
//  Created by Andrey on 13.03.2023.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
}
