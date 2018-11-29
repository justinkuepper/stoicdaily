//
//  QuoteViewController.swift
//  Stoic Daily
//
//  Created by Justin Kuepper on 11/8/18.
//  Copyright © 2018 Justin Kuepper. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class QuoteViewController: UIViewController {

    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var bylineLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    struct Quote: Decodable {
        var id: String
        var date: String
        var title: String
        var quote: String
        var byline: String
        var detail: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set or retrieve the daily quote.
        let quote = getQuote()
        
        // Set styling for the quote text.
        let attString = NSMutableAttributedString(string: quote!.quote)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attString.length))
        quoteLabel.attributedText = attString
        quoteLabel.font = UIFont(name: "Hiragino Mincho ProN W3", size: 30)
        
        // Set date and byline strings.
        dateButton.setTitle(getDateString(), for: .normal)
        bylineLabel.text = quote!.byline
        
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
        
        // Detect tap to show details.
        let tapAction = UITapGestureRecognizer()
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapAction)
        tapAction.addTarget(self, action: #selector(actionTapped(_:)))
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
    
    // Retrieves or sets a quote for the day.
    func getQuote() -> Quote? {
        let currentDate = getDateString()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchQuote = NSFetchRequest<NSFetchRequestResult>(entityName: "Quotes")
        fetchQuote.predicate = NSPredicate(format: "quoteDate == %@", currentDate)
        fetchQuote.fetchLimit = 1
        let existingQuotes = try! context.fetch(fetchQuote) as! [NSManagedObject]
        print(existingQuotes)
        
        if existingQuotes.count > 0 {
            do {
                let db = Bundle.main.url(forResource: "quotes", withExtension: "json")!
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: db)
                let quotes = try decoder.decode([Quote].self, from: data)
                let existingQuote = existingQuotes.first!.value(forKey: "quoteId") as! String
                let quote = quotes.filter{ $0.id == existingQuote }
                return quote[0]
            } catch {
                print(error)
                return nil
            }
        } else {
            do {
                clearQuotes()
                let db = Bundle.main.url(forResource: "quotes", withExtension: "json")!
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: db)
                let quotes = try decoder.decode([Quote].self, from: data)
                let quote = quotes.randomElement()!
                let quoteEntity = NSEntityDescription.entity(forEntityName: "Quotes", in: context)!
                let savedQuote = NSManagedObject(entity: quoteEntity, insertInto: context)
                savedQuote.setValue(quote.id, forKey: "quoteId")
                savedQuote.setValue(currentDate, forKey: "quoteDate")
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                return quote
            } catch {
                print(error)
                return nil
            }
        }
    }
    
    // Clear all previous quotes to save space.
    func clearQuotes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Quotes")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
            }
        } catch {
            print("Failed to delete data.")
        }
    }
    
    // Handle the tap to show detail view.
    @objc func actionTapped(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        vc.modalTransitionStyle = .flipHorizontal
        vc.quoteTitle = getQuote()!.title
        vc.quoteDetails = getQuote()!.detail
        self.present(vc, animated: true, completion: nil)
    }
    
    // Open dialog to share quote.
    @IBAction func shareQuote(_ sender: Any) {
        let quote = getQuote()!.title
        let shareObject = [quote]
        let activityVC = UIActivityViewController(activityItems: shareObject as [Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // This could eventually be used to change the date.
    @IBAction func changeDate(_ sender: UIButton) {
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
