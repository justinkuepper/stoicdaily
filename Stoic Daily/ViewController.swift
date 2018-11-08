//
//  ViewController.swift
//  Stoic Daily
//
//  Created by Justin Kuepper on 11/8/18.
//  Copyright © 2018 Justin Kuepper. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(getDate())
        print(getQuote(currentDate: "11/09"))
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

