//
//  NASAResult.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import Foundation
import UIKit

//MARK: Option 1 - Notice no optionals the check for existance is done during fetch

struct NASAResult {
    let id: String
    var title: String
    var center: String
    var description: String
    var imageURL: URL
    var imageData: Data?
    var image: UIImage? {
        if imageData == nil {
            return nil
        } else {
            return UIImage(data: imageData!)
        }
    }
}

//MARK: Option 2 - Codable(DID NOT USE THE CODABLE APPROACH FELT UNNECCESSARY)

///Structure represents the current way in which the data is pulled - felt more confusing

struct NASAResult2: Codable, Hashable {
    var links: [LinkData]?
    var data: [ContentData]
    var imageData: Data?
    var image: UIImage? {
        if self.imageData == nil {
            return nil
        } else {
            return UIImage(data: self.imageData!)
        }
    }
    struct LinkData: Codable, Hashable {
        var href: String?
        var rel: String?
        var render: String?
    }
    struct ContentData: Codable, Hashable {
        let id: String?
        var title: String?
        var center: String?
        var description: String?
        var imageURL: URL
    }
}
