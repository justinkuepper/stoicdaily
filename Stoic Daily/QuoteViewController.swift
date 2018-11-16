//
//  QuoteViewController.swift
//  Stoic Daily
//
//  Created by Justin Kuepper on 11/8/18.
//  Copyright © 2018 Justin Kuepper. All rights reserved.
//

import UIKit
import UserNotifications

class QuoteViewController: UIViewController {

    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bylineLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
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
        quoteLabel.font = UIFont(name: "Hiragino Mincho ProN W3", size: 30)
        
        // Detect tap to show details.
        let tapAction = UITapGestureRecognizer()
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapAction)
        tapAction.addTarget(self, action: #selector(actionTapped(_:)))
        
        // Set date and byline strings.
        dateLabel.text = getDateString()
        bylineLabel.text = getByline(currentDate: getDate())
        
        // Size the quote text to fit height.
        quoteLabel.resizeToFitHeight()
        
        // Fade in the quote and byline text.
        quoteLabel.alpha = 0
        bylineLabel.alpha = 0
        quoteLabel.fadeIn()
        bylineLabel.fadeIn()
        
        // Style quote button.
        shareButton.layer.borderWidth = 0.8
        shareButton.layer.borderColor = UIColor.lightGray.cgColor
        shareButton.layer.cornerRadius = 5
    }
    
    struct Quote: Decodable {
        var date: String
        var title: String
        var quote: String
        var byline: String
        var detail: String
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
    
    // Takes a string date and returns a detail string.
    func getDetails(currentDate: String) -> String {
        do {
            let db = Bundle.main.url(forResource: "quotes", withExtension: "json")!
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: db)
            let quotes = try decoder.decode([Quote].self, from: data)
            let quote = quotes.filter{ $0.date == currentDate }
            return quote[0].detail
        } catch {
            print(error)
            return ""
        }
    }
    
    // Takes a string date and returns a byline string.
    func getByline(currentDate: String) -> String {
        do {
            let db = Bundle.main.url(forResource: "quotes", withExtension: "json")!
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: db)
            let quotes = try decoder.decode([Quote].self, from: data)
            let quote = quotes.filter{ $0.date == currentDate }
            return quote[0].byline
        } catch {
            print(error)
            return ""
        }
    }
    
    // Takes a string date and returns a title string.
    func getTitle(currentDate: String) -> String {
        do {
            let db = Bundle.main.url(forResource: "quotes", withExtension: "json")!
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: db)
            let quotes = try decoder.decode([Quote].self, from: data)
            let quote = quotes.filter{ $0.date == currentDate }
            return quote[0].title
        } catch {
            print(error)
            return ""
        }
    }
    
    // Handle the tap to show detail view.
    @objc func actionTapped(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        vc.modalTransitionStyle = .flipHorizontal
        vc.quoteTitle = getTitle(currentDate: getDate())
        vc.quoteDetails = getDetails(currentDate: getDate())
        self.present(vc, animated: true, completion: nil)
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

// Extension to resize font to fit height.
extension UILabel {
    func resizeToFitHeight(){
        var currentfontSize = font.pointSize
        let minFontsize = CGFloat(5)
        let constrainedSize = CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)
        
        while (currentfontSize >= minFontsize){
            let newFont = font.withSize(currentfontSize)
            let attributedText: NSAttributedString = NSAttributedString(string: text!, attributes: [NSAttributedString.Key.font: newFont])
            let rect: CGRect = attributedText.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, context: nil)
            let size: CGSize = rect.size
            
            if (size.height < frame.height - 10) {
                font = newFont
                break;
            }
            currentfontSize = currentfontSize - 1
        }
        
        if (currentfontSize == minFontsize){
            font = font.withSize(currentfontSize)
        }
    }
}
