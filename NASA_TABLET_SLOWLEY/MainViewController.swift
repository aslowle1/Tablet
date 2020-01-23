//
//  ViewController.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {

    //MARK: Model Objects
    
    lazy var dataSource = CollectionViewDataSource(controller: self)
    
    lazy var contentHandler = SearchManager(completion: incoming(content:error:))
    
    //MARK: UI Elements
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "image")
            collectionView.dataSource = dataSource
            collectionView.delegate = dataSource
        }
    }
        
    @IBOutlet weak var alertLabel: UILabel! {
        didSet {
            alertLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var pagingActivityIndicator: UIActivityIndicatorView! {
        didSet {
            pagingActivityIndicator.isHidden = true
        }
    }

    //MARK: Search Bar & Search Actions
    
    @IBOutlet weak var searchActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UITextField! {
        didSet {
            searchBar.delegate = self
            searchBar.addTarget(self, action: #selector(searchBarisActive), for: UIControl.Event.editingChanged)
        }
    }
    
    @objc func searchBarisActive(textField: UITextField) {
        ///1. reset data source for new new search
        dataSource.items = []
        collectionView.reloadData()
        guard let input = textField.text, !input.isEmpty else {
            return
        }
        ///2. Reset Views
        alertLabel.isHidden = true
        searchActivityIndicator.isHidden = false
        searchActivityIndicator.startAnimating()
        pagingActivityIndicator.stopAnimating()
        
        ///3. Update Status to new search
        contentHandler.networkStatus.state = .Searching
        contentHandler.networkStatus.query = input
        contentHandler.search(input)
    }
    
    func incoming(content: [NASAResult], error: String?) {
        ///1. Hop onto the main queue
        ///2. Update UI
            searchActivityIndicator.stopAnimating()
            pagingActivityIndicator.stopAnimating()
            
            guard error == nil else {
        ///Display Errors(If Required)
                alertLabel.isHidden = false
                alertLabel.text = error
                return
            }
        
        ///3. Content should only be empty is no results are returned
            if content.isEmpty {
                alertLabel.isHidden = false
                if contentHandler.networkStatus.state == .Paging {
                    alertLabel.text = "No More Images Available"
                } else if contentHandler.networkStatus.state == .Searching {
                    alertLabel.text = "No Result Found"
                }
            } else {
        ///4. Add Items to datasource and perform insert function into collectionview
                let currentCount =  dataSource.items.count
                dataSource.items.append(contentsOf: content)
                
                if currentCount == 0 {
                    collectionView.reloadData()
                } else {
                    let newIndexPaths = Array(currentCount..<content.count + currentCount).map(){return IndexPath(row: $0, section: 0)}
                    collectionView.insertItems(at: newIndexPaths)
                }
            }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ///1. Check it user is at the bottom of the content view
        ///2. Then check to verify that operation queue is empty, if not empty that means that images from current page is still being fetched
        ///3. Unlikely but if the paging activity indicator is showing we don't want to go into and trigger another search
        if isAtBottomOfPage() && contentHandler.operationQueue.operationCount == 0 && pagingActivityIndicator.isHidden  {
            pagingActivityIndicator.isHidden = false
            pagingActivityIndicator.startAnimating()
            contentHandler.networkStatus.state = .Paging
            let input = searchBar.text!
            contentHandler.networkStatus.query = input
            contentHandler.search(input)
        }
    }
    
    private func isAtBottomOfPage() -> Bool {
        let contentLarger = (collectionView.contentSize.height > collectionView.frame.size.height)
        let viewableHeight = contentLarger ? collectionView.frame.size.height : collectionView.contentSize.height
        return (collectionView.contentOffset.y >= collectionView.contentSize.height - viewableHeight)
    }

}

