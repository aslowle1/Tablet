//
//  NetworkActivityStatus.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import Foundation

//MARK: Track the status of what is currently happening on the network

/// It is important to distinguid between when a user is actually searching or when we are paging since we are using the same function to go to the network

struct NetworkActivityStatus: Hashable {
    var state: StateOptions = .None
    var query: String?
    
    enum StateOptions: String {
        case None, Searching, Paging
    }
}

