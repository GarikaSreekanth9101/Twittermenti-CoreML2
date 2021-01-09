//
//  ViewController.swift
//  Twittermenti-CoreML2
//
//  Created by Garika Sreekanth on 08/01/21.
//  Copyright © 2021 Garika Sreekanth. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    let numberOfTweets = 100
    
    let swifter = Swifter(consumerKey: "Your consumerKey", consumerSecret: "Your consumerSecret")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
    }
    
    func fetchTweets()
    {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: numberOfTweets, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<self.numberOfTweets {
                    
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassifier = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassifier)
                    }
                }
                
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("There was an error with Twitter API request, \(error)")
            }
        }
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput])
    {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            
            for predic in predictions {
                let sentiment = predic.label
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            updateUI(with: sentimentScore)
            
        }catch {
            print("There was an error with making a prediction, \(error)")
        }
    }
    
    func updateUI(with sentimentScore: Int)
    {
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        }else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        }else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙁"
        }else if sentimentScore == 0 {
            self.sentimentLabel.text = "😕"
        }else if sentimentScore > -10 {
            self.sentimentLabel.text = "☹️"
        }else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        }else {
            self.sentimentLabel.text = "🤬"
        }
    }
    
}

