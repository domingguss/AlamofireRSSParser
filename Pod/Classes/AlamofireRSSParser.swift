//
//  AlamofireRSSParser.swift
//  Pods
//
//  Created by Donald Angelillo on 3/2/16.
//
//

import Foundation
import Alamofire

extension Request {
    public static func RSSResponseSerializer() -> ResponseSerializer<RSSFeed, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let parser = AlamofireRSSParser(data: validData)
            
            let parsedResults: (feed: RSSFeed?, error: NSError?) = parser.parse()
            
            if let feed = parsedResults.feed {
                return .Success(feed)
            } else {
                return .Failure(parsedResults.error!)
            }
        }
    }
    
//    public func responseRSS(parser parser: AlamofireRSSParser?, completionHandler: Response<RSSFeed, NSError> -> Void) -> Self {
//        return response(responseSerializer: Request.RSSResponseSerializer(parser), completionHandler: completionHandler)
//    }
    
    public func responseRSS(completionHandler: Response<RSSFeed, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.RSSResponseSerializer(), completionHandler: completionHandler)
    }
}



public class AlamofireRSSParser: NSObject, NSXMLParserDelegate {
    var parser: NSXMLParser? = nil
    var feed: RSSFeed? = nil
    var parsingItems: Bool = false
    
    var currentItem: RSSItem? = nil
    var currentString: String!
    var currentAttributes: [String: String]? = nil
    var parseError: NSError? = nil
    
    public var data: NSData? = nil {
        didSet {
            if let data = data {
                self.parser = NSXMLParser(data: data)
                self.parser?.delegate = self
            }
        }
    }
    
    override init() {
        self.parser = NSXMLParser();
        
        super.init()
    }
    
    init(data: NSData) {
        self.parser = NSXMLParser(data: data)
        super.init()
        
        self.parser?.delegate = self
    }
    
    func parse() -> (feed: RSSFeed?, error: NSError?) {
        self.feed = RSSFeed()
        self.currentItem = nil
        self.currentAttributes = nil
        self.currentString = String()
        
        self.parser?.parse()
        return (feed: self.feed, error: self.parseError)
    }
    
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.currentString = String()
        
        self.currentAttributes = attributeDict
        
        if ((elementName == "item") || (elementName == "entry")) {
            self.currentItem = RSSItem()
        }
        
        
        //print(elementName);
    }
    
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //if we're at the item level
        if let currentItem = self.currentItem {
            if (elementName == "item") {
                self.feed?.items.append(currentItem)
                return
            }
            
            if (elementName == "title") {
                currentItem.title = self.currentString
            }
            
            if (elementName == "description") {
                currentItem.itemDescription = self.currentString
            }
            
            if (elementName == "link") {
                currentItem.link = self.currentString
            }
            
            if (elementName == "guid") {
                currentItem.guid = self.currentString
            }
            
            if (elementName == "author") {
                currentItem.author = self.currentString
            }
            
            if (elementName == "comments") {
                currentItem.comments = self.currentString
            }
            
            if (elementName == "source") {
                currentItem.source = self.currentString
            }
            
            if (elementName == "pubDate") {
                if let date = RSSDateFormatter.rfc822DateFormatter().dateFromString(self.currentString) {
                    currentItem.pubDate = date
                } else if let date = RSSDateFormatter.rfc822DateFormatter2().dateFromString(self.currentString) {
                    currentItem.pubDate = date
                }
            }
            
            if (elementName == "published") {
                if let date = RSSDateFormatter.publishedDateFormatter().dateFromString(self.currentString) {
                    currentItem.pubDate = date
                } else if let date = RSSDateFormatter.publishedDateFormatter2().dateFromString(self.currentString) {
                    currentItem.pubDate = date
                }
            }
            
            
        //if we're at the top level
        } else {
            if (elementName == "title") {
                self.feed?.title = self.currentString
            }
            
            if (elementName == "description") {
                self.feed?.feedDescription = self.currentString
            }
            
            if (elementName == "link") {
                self.feed?.link = self.currentString
            }
            
            if (elementName == "language") {
                self.feed?.language = self.currentString
            }
            
            if (elementName == "copyright") {
                self.feed?.copyright = self.currentString
            }
            
            if (elementName == "managingEditor") {
                self.feed?.managingEditor = self.currentString
            }
            
            if (elementName == "webMaster") {
                self.feed?.webMaster = self.currentString
            }
            
            if (elementName == "generator") {
                self.feed?.generator = self.currentString
            }
            
            if (elementName == "docs") {
                self.feed?.docs = self.currentString
            }
            
            if (elementName == "ttl") {
                self.feed?.ttl = Int(self.currentString)
            }
            
            if (elementName == "pubDate") {
                if let date = RSSDateFormatter.rfc822DateFormatter().dateFromString(self.currentString) {
                    self.feed?.pubDate = date
                } else if let date = RSSDateFormatter.rfc822DateFormatter2().dateFromString(self.currentString) {
                    self.feed?.pubDate = date
                }
            }
            
            if (elementName == "published") {
                if let date = RSSDateFormatter.publishedDateFormatter().dateFromString(self.currentString) {
                    self.feed?.pubDate = date
                } else if let date = RSSDateFormatter.publishedDateFormatter2().dateFromString(self.currentString) {
                    self.feed?.pubDate = date
                }
            }
            
            if (elementName == "lastBuildDate") {
                if let date = RSSDateFormatter.rfc822DateFormatter().dateFromString(self.currentString) {
                    self.feed?.lastBuildDate = date
                } else if let date = RSSDateFormatter.rfc822DateFormatter2().dateFromString(self.currentString) {
                    self.feed?.lastBuildDate = date
                }
            }
            
            
            
        }
        
        
        
    }
    
    public func parser(parser: NSXMLParser, foundCharacters string: String) {
        self.currentString.appendContentsOf(string)
    }
    
    public func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        self.parseError = parseError
        self.parser?.abortParsing()
    }
}

struct RSSDateFormatter {
    static func rfc822DateFormatter() -> NSDateFormatter {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return dateFormatter
    }
    
    static func rfc822DateFormatter2() -> NSDateFormatter {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return dateFormatter
    }
    
    static func publishedDateFormatter() -> NSDateFormatter {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }
    
    static func publishedDateFormatter2() -> NSDateFormatter {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        return dateFormatter
    }
}
