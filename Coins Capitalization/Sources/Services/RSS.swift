//
//  RSS.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 22.06.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

final class RSS: NSObject {
    
    // MARK: - Public Nested
    
    enum Feed: String {
        
        // English
        
        case bitcoinMagazine    = "https://bitcoinmagazine.com/feed/"
        case ccn                = "https://www.ccn.com/feed/"
        case coinDesk           = "https://www.coindesk.com/feed/"
        case ethereumWorldNews  = "https://ethereumworldnews.com/feed/"
        case newsBTC            = "https://www.newsbtc.com/feed/"
        
        static var en: [Feed] {
            return [.bitcoinMagazine, .ccn, .coinDesk, .ethereumWorldNews, .newsBTC]
        }
        
        // Russian
        
        case cryptocurrencyTech = "https://cryptocurrency.tech/feed"
        case forklog            = "https://forklog.com/news/feed/"
        
        static var ru: [Feed] {
            return [.cryptocurrencyTech, .forklog]
        }
        
        var url: URL? {
            return URL(string: rawValue)
        }
    }
    
    // MARK: - Public Properties
    
    static var feeds: [Feed] {
        switch Locale.current.identifier.dropLast(3) {
        case "ru": return Feed.ru
        default:   return Feed.en
        }
    }
    
    // MARK: - Constructors
    override init() {
    }
    
    // MARK: - Public Methods
    
    /// Requests news articles from RSS
    func requestNewsArticles(from feed: Feed, success: @escaping ([Article]) -> Void, failure: @escaping (Error) -> Void) {
        if let url = feed.url {
            self.success = success
            self.failure = failure
            xmlParser = XMLParser(contentsOf: url)
            xmlParser?.delegate = self
            xmlParser?.parse()
        }
    }
    
    // MARK: - Private Properties
    
    private var items: [Article] = []
    
    private var xmlParser: XMLParser?
    private var currentSource = Source(name: "", logo: "")
    private var currentArticle = Article(author: "", title: "", description: "", url: "")
    private var elementsStack: [String] = []
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        return dateFormatter
    }()
    
    private var success: (([Article]) -> Void)?
    private var failure: ((Error) -> Void)?
    
}
    
// MARK: - XMLParserDelegate

extension RSS: XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
        items = []
        currentSource = Source(name: "", logo: "")
        currentArticle.reset()
        elementsStack = ["rss"]
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "item" {
            if !currentArticle.isEmpty {
                currentArticle.source = currentSource
                items.append(currentArticle)
            }
            currentArticle.reset()
        }
        
        if let lastElement = elementsStack.last, lastElement != elementName {
            elementsStack.append(elementName)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let string = string.replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
        
        let count = elementsStack.count
        
        guard !string.isEmpty, count > 2 else { return }
        
        let currentElement = elementsStack[count - 1]
        let parentElement = elementsStack[count - 2]
        
        if parentElement == "channel" && currentElement == "title" {
            currentSource.name += string
        }
        
        if parentElement == "image" && currentElement == "url" {
            currentSource.logo += string
        }
        
        if currentElement == "title" {
            currentArticle.title += string
        }
        
        if currentElement == "description" {
            currentArticle.description += string.removeAllTags().replacingOccurrences(of: "\n", with: "")
        }
        
        if currentElement == "link" {
            currentArticle.url += string
        }
        
        if currentElement == "pubDate" {
            currentArticle.publishedAt = RSS.dateFormatter.date(from: string)
        }
        
        if currentElement.range(of: "creator") != nil {
            currentArticle.author = "\(currentArticle.author ?? "")" + string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let lastElement = elementsStack.last, lastElement == elementName {
            elementsStack.removeLast()
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        success?(items)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        failure?(parseError)
    }

}

extension String {
    
    func removeAllTags() -> String {
        let data = Data(utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                                .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            return attributedString.string
        } else {
            return self
        }
    }
    
}
