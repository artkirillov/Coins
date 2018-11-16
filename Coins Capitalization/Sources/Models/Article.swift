//
//  Article.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 20.06.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

struct Article {
    
    // MARK: - Public Properties
    
    var source: Source
    var author: String?
    var title: String
    var description: String
    var url: String
    var urlToImage: String?
    var publishedAt: Date?
    
    var isEmpty: Bool {
        return title.isEmpty || description.isEmpty || url.isEmpty || author == nil
    }
    
    // MARK: - Constructors
    
    init(sourceName: String = "",
         sourceLogo: String = "",
         author: String?,
         title: String,
         description: String,
         url: String,
         urlToImage: String? = nil,
         publishedAt: Date? = nil)
    {
        let source = Source(name: sourceName, logo: sourceLogo)
        self.init(source: source, author: author, title: title, description: description,
                  url: url, urlToImage: urlToImage, publishedAt: publishedAt)
    }
    
    init(source: Source,
         author: String?,
         title: String,
         description: String,
         url: String,
         urlToImage: String? = nil,
         publishedAt: Date? = nil)
    {
        self.source = source
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
    }
    
    // MARK: - Public Methods
    
    mutating func reset() {
        author = nil
        title = ""
        description = ""
        url = ""
        urlToImage = nil
        publishedAt = nil
    }
    
}

class Source {
    
    // MARK: - Public Properties
    
    var name: String
    var logo: String {
        didSet {
            guard let url = URL(string: logo) else { return }
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                guard let data = data, let image = UIImage(data: data), error == nil else { return }
                DispatchQueue.main.async { [weak self] in self?.image = image }
            }).resume()
        }
    }
    var image: UIImage?
    
    // MARK: - Constructors
    
    init(name: String = "", logo: String = "") {
        self.name = name
        self.logo = logo
    }
}
