//
//  SearchHistory.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import Foundation
// MARK: Search History: Cache search history rather than constant reload for each letter of search

///Stores results for query as well as the last paged queried

struct SearchHistory: Hashable {
    var page = 1
    var query: String
    var ids: [String] = []
    var maximumFetchReached = false
    
    static func == (lhs: SearchHistory, rhs: SearchHistory) -> Bool {
        return lhs.query == rhs.query
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(query)
    }
}
