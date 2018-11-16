//
//  DetailViewController.swift
//  Stoic Daily
//
//  Created by Justin Kuepper on 11/12/18.
//  Copyright © 2018 Justin Kuepper. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var quoteTitle : String = ""
    var quoteDetails : String = ""
    
    @IBOutlet weak var quoteDetailsLabel: UILabel!
    @IBOutlet weak var quoteTitleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quoteTitleLabel.text = quoteTitle.uppercased()
        
        // Set styling for the quote details.
        let attString = NSMutableAttributedString(string: quoteDetails)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attString.length))
        quoteDetailsLabel.attributedText = attString
        quoteDetailsLabel.font = UIFont(name: "Hiragino Mincho ProN W3", size: 20)
        
        // Style save button.
        saveButton.layer.borderWidth = 0.8
        saveButton.layer.borderColor = UIColor.lightGray.cgColor
        saveButton.layer.cornerRadius = 5
    }
    
    // Dismiss the quote details.
    @IBAction func backToQuote(_ sender: Any) {
        self.modalTransitionStyle = .flipHorizontal
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
}
