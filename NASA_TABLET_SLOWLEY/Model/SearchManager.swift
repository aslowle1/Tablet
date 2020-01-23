//
//  SearchManager.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import Foundation


/*
 - Network request is requested two different ways - Paging & Searching
 - After a user input the search text is saved, along with the ids of each result
 - ids map to a unique result which contains the details(name, image) etc..
 - Image is returned via closure in groups(if multiple images are available) or one-by-one(Operation)
 - If an operation is on-going and the user starts(or continues) a search that current image request is canceled

 */

class SearchManager: ImageOperationDelegate {

    private let uri: String = "https://images-api.nasa.gov/search"
    var cachedSearchHistory: [String:SearchHistory] = [:]
    var cachedContent: [String:NASAResult] = [:]
    
    var operationQueue = OperationQueue()
    private var operations = [Operation]()
    
    var networkStatus: NetworkActivityStatus = NetworkActivityStatus()
    
    var completion: (([NASAResult], String?) -> ())!
    
    init(completion: @escaping ([NASAResult], String?) -> ()) {
        self.completion = completion
    }
    
    func search(_ input: String) {

        guard (networkStatus.state == .Paging) || ((networkStatus.state == .Searching) && cachedSearchHistory[input] == nil) else {
            
            cancelAllExistingImageFetchRequest()
            
            var existingItems = [NASAResult]()
            
            cachedSearchHistory[input]?.ids.forEach({ (id) in
                if let item = cachedContent[id] {
                    existingItems.append(item)
                }
            })
            
            if existingItems.isEmpty {
                completion!([],nil)
            } else {
                imageDataIsAvailableCheck(for: existingItems)
            }
            return
        }
        
        var request = URLRequest(url: buildURL(input)!)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [oldState = networkStatus, weak self](data, response, error) in
            
            guard self != nil else {
                return
            }
            
            guard error == nil else {
                DispatchQueue.main.async {[weak self] in
                self!.completion?([],error?.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                
                let items = (data != nil) ? self!.parseData(data!) : []
                
                //Update Cache with new ids for query and if network was triggered by paging update the page count
                switch oldState.state {
                case .Paging:
                    self!.cachedSearchHistory[oldState.query!]!.page += 1
                    self!.cachedSearchHistory[oldState.query!]!.ids.append(contentsOf: items.map({$0.id}))
                case .Searching:
                    var newHistory = SearchHistory(query:oldState.query!)
                    newHistory.ids = items.map({$0.id})
                    self!.cachedSearchHistory[oldState.query!] = newHistory
                default: break
                }
                
                if items.isEmpty {
                    self!.cachedSearchHistory[oldState.query!]!.maximumFetchReached = true
                    DispatchQueue.main.async {[weak self] in
                    self!.completion!(items,nil)
                    }
                } else if oldState == self!.networkStatus {
                    self!.imageDataIsAvailableCheck(for: items)
                }
                
            default:
                DispatchQueue.main.async {[weak self] in
                self!.completion!([],error?.localizedDescription)
                }
            }
        }
        
        task.resume()
    }
    
    
    private func imageDataIsAvailableCheck(for items:[NASAResult]) {
        let imageDataAvailable = items.filter({$0.imageData != nil})
        if !imageDataAvailable.isEmpty {
            DispatchQueue.main.async {[weak self] in
                self?.completion!(imageDataAvailable,nil)
            }
        }
        let imageDataFetchRequired = items.filter({$0.imageData == nil})
        if !imageDataFetchRequired.isEmpty {
            fetchImages(imageDataFetchRequired)
        }
    }
    
    private func buildURL(_ input: String) -> URL? {
        var urlComponents = URLComponents(string: uri)
        
        let qItem = URLQueryItem(name: "q", value: input)
        
        let mediaTypeQueryItem = URLQueryItem(name: "media_type", value: "image")
        
        var pageQueryItem = URLQueryItem(name: "page", value: "2")
        
        if networkStatus.state == .Paging {
            pageQueryItem.value = "\(cachedSearchHistory[input]!.page + 1)"
        }
        urlComponents?.queryItems = [qItem,mediaTypeQueryItem,pageQueryItem]
        return urlComponents?.url
    }
    
    private func parseData(_ data: Data) -> [NASAResult] {
                
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any], let collection = json["collection"] as? [String:Any], let items = collection["items"] as? [[String: Any]] else {
            return []
        }
        
        var results = [NASAResult]()
        
        items.forEach { (itemData) in
            if let item = (itemData["data"] as? [[String:Any]])?.first, let id = item["nasa_id"] as? String, let title = item["title"] as? String, let center = item["center"] as? String, let description = item["description"] as? String, let links = itemData["links"] as? [[String:Any]], let imagePath = links[0]["href"] as? String, let imageURL = URL(string: imagePath) {
                
                let item = NASAResult(id: id, title: title, center: center, description: description, imageURL: imageURL, imageData: nil)
                if cachedContent[id] == nil {
                    cachedContent[id] = item
                }
                results.append(item)
            }
        }
        
        return results
    }
    
    private func fetchImages(_ items:[NASAResult]) {
        cancelAllExistingImageFetchRequest()
        items.forEach { (item) in
            operations.append(ImageOperation(path: item.imageURL, id: item.id, delegate: self))
        }
        
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
     func imageFetchComplete(id: String, data: Data?, error: Error?) {
        
        guard error == nil else {
            return
        }
        
        DispatchQueue.main.async {[weak self] in
            guard self != nil else {
                return
            }
            self!.cachedContent[id]?.imageData = data
            guard let history = self!.cachedSearchHistory[self!.networkStatus.query!], history.ids.contains(id) else {
            return
        }
            self!.completion!([self!.cachedContent[id]!],nil)
        }
    }
    
    private func cancelAllExistingImageFetchRequest() {
        operations = []
        operationQueue.cancelAllOperations()
    }
 
}
