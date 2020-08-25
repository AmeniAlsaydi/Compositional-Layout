//
//  APIClient.swift
//  Compositional-Layout-with-Combine
//
//  Created by Amy Alsaydi on 8/25/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import Foundation
import Combine

struct PhotoResultsWrapper: Decodable {
  let hits: [Photo]
}

struct Photo: Decodable, Hashable {
  let id: Int
  let webformatURL: String
}

class APIClient {
    public func searchPhotos(for query: String) -> AnyPublisher<[Photo], Error> {
        let perPage = 200 // max is 200
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "paris"
        let endpoint = "https://pixabay.com/api/?key=\(Config.apikey)&q=\(query)&per_page=\(perPage)&safesearch=true"
       
        let url = URL(string: endpoint)!
      
        // were using Combine for networking
       return  URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // only value were interested in is the data
            .decode(type: PhotoResultsWrapper.self, decoder: JSONDecoder())
            .map { $0.hits }
            .receive(on: DispatchQueue.main) // on what thread to recive
            .eraseToAnyPublisher()
 
    }
}
