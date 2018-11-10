//
//  ViewController.swift
//  Stoic Daily
//
//  Created by Justin Kuepper on 11/8/18.
//  Copyright © 2018 Justin Kuepper. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func shareQuote(_ sender: Any) {
        let quote = getQuote(currentDate: getDate())
        let shareObject = [quote]
        let activityVC = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set styling for the quote text.
        let attString = NSMutableAttributedString(string: getQuote(currentDate: getDate()))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attString.length))
        quoteLabel.attributedText = attString
        quoteLabel.font = UIFont(name: "Hiragino Mincho ProN W3", size: 25)
        
        // Set date string.
        dateLabel.text = getDateString()
        
        // Fade in the quote text.
        quoteLabel.alpha = 0
        quoteLabel.fadeIn()
    }
    
    struct Quote: Decodable {
        var date: String
        var quote: String
    }
    
    // Retrieves and formats the current date.
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let result = formatter.string(from: date)
        return result
    }
    
    // Retrieves and formats the current date string.
    func getDateString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let result = formatter.string(from: date).uppercased()
        return result
    }
    
    // Takes string date and returns quote string.
    func getQuote(currentDate: String) -> String {
        do {
            let db = Bundle.main.url(forResource: "quotes", withExtension: "json")!
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: db)
            let quotes = try decoder.decode([Quote].self, from: data)
            let quote = quotes.filter{ $0.date == currentDate }
            return quote[0].quote
        } catch {
            print(error)
            return ""
        }
    }
}

// Extention to fade in and out text.
extension UIView {
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
