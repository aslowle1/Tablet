//
//  DetailViewController.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var _title: UILabel!
    
    @IBOutlet weak var _description: UILabel!
    
    @IBOutlet weak var photographer: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var mainImage: UIImageView!

    @IBAction func dismissDetailController(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    var item: NASAResult
    
    init(item: NASAResult) {
        self.item = item
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _title.text  = item.title
        _description.text = item.description
        photographer.isHidden = true
        location.isHidden = true
        mainImage.image = item.image
        // Do any additional setup after loading the view.
    }
}
