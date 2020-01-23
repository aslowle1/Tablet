//
//  ImageOperation.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import Foundation

//MARK: Image Operation class & Protocol

///Images will be fetched concurrently and as such I decied to use an opertion queue and will notifiy the delegate as each image is retrieved

///Assumption: Order in which image is pulled is not important

protocol ImageOperationDelegate: class {
    func imageFetchComplete(id: String, data: Data?, error: Error?)
}

class ImageOperation: CustomOp {
    
    var path: URL
    
    var id: String
    
    weak var delegate: ImageOperationDelegate?
    
    init(path: URL, id: String, delegate: ImageOperationDelegate) {
        self.path = path
        self.id = id
        self.delegate = delegate
    }
    
     override func main() {

        var request = URLRequest(url:path)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            
            guard self != nil else {
                return
            }
            
            guard error == nil else {
                self!.delegate?.imageFetchComplete(id: self!.id, data: nil, error: error)
                self!.state = .Finished
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self!.state = .Finished
                return
            }

            switch httpResponse.statusCode {
            case 200:
                self!.delegate?.imageFetchComplete(id: self!.id, data: data, error: nil)
            default:
                self!.delegate?.imageFetchComplete(id: self!.id, data: nil, error: error)
            }
            self!.state = .Finished
        }
        task.resume()
    }
    
}
