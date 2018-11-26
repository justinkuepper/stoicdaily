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
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var bylineLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set styling for the quote text.
        let attString = NSMutableAttributedString(string: getQuote(currentDate: getDate())!.quote)
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
        dateButton.setTitle(getDateString(), for: .normal)
        bylineLabel.text = getQuote(currentDate: getDate())!.byline
        
        // Size the quote text to fit height.
        quoteLabel.resizeToFitHeight()
        
        // Fade in the quote and byline text.
        quoteLabel.alpha = 0
        bylineLabel.alpha = 0
        quoteLabel.fadeIn()
        bylineLabel.fadeIn()
        
        // Style quote button.
        // This is a future button that will change the date when there's a quote for every day.
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
    
    // Takes string date and returns quote object.
    func getQuote(currentDate: String) -> Quote? {
        do {
            let db = Bundle.main.url(forResource: "quotes", withExtension: "json")!
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: db)
            let quotes = try decoder.decode([Quote].self, from: data)
            // Future: let quote = quotes.filter{ $0.date == currentDate }
            let quote = quotes.randomElement()!
            return quote
        } catch {
            print(error)
            return nil
        }
    }
    
    // Handle the tap to show detail view.
    @objc func actionTapped(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        vc.modalTransitionStyle = .flipHorizontal
        vc.quoteTitle = getQuote(currentDate: getDate())!.title
        vc.quoteDetails = getQuote(currentDate: getDate())!.detail
        self.present(vc, animated: true, completion: nil)
    }
    
    // Open dialog to share quote.
    @IBAction func shareQuote(_ sender: Any) {
        let quote = getQuote(currentDate: getDate())
        let shareObject = [quote]
        let activityVC = UIActivityViewController(activityItems: shareObject as [Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // Handle the tap to change the date and quote.
    // This will be implemented when there's a quote for every date.
    @IBAction func changeDate(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let datePickerVC = storyboard.instantiateViewController(withIdentifier: "datePickerVC")
        datePickerVC.modalPresentationStyle = .overCurrentContext
        self.present(datePickerVC, animated: true, completion: nil)
    }
    
    // Change the title of the button and update quote.
    @objc func dateChanged(_ sender: UIDatePicker) {
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
