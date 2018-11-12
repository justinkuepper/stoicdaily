//
//  DetailViewController.swift
//  Stoic Daily
//
//  Created by Justin Kuepper on 11/12/18.
//  Copyright © 2018 Justin Kuepper. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var quoteDetails : String = ""
    @IBOutlet weak var quoteDetailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteDetailsLabel.text = quoteDetails
    }
}
