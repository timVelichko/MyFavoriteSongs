//
//  ItunesWithCacheSongSearchProvider.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 19.06.2022.
//

import Foundation
import Combine

class ItunesWithCacheSongSearchProvider: SongSearchProvider {
    
    enum ItunesError: Error {
        case invalidUrl
        case songNotFound
    }
    
    private let session = URLSession(configuration: .default)
    private let domain = "https://itunes.apple.com"
    
    private enum Path: String {
        case search = "/search"
        case getSong = "/lookup"
    }
    
    private enum Param: String {
        case term, id
    }
    
    func searchSongs(for term: String) -> AnyPublisher<[SongModel], Error> {
        var urlComponents = URLComponents(string: domain + Path.search.rawValue)
        urlComponents?.queryItems = [ URLQueryItem(name: Param.term.rawValue, value: term) ]
        guard let url = urlComponents?.url else {
            return Fail(error: ItunesError.invalidUrl).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .eraseToAnyPublisher()
    }
    
    func getSong(by id: String) -> AnyPublisher<SongModel, Error> {
        var urlComponents = URLComponents(string: domain + Path.getSong.rawValue)
        urlComponents?.queryItems = [ URLQueryItem(name: Param.id.rawValue, value: id) ]
        guard let url = urlComponents?.url else {
            return Fail(error: ItunesError.invalidUrl).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .tryMap {
                guard let song = $0.results.first else { throw ItunesError.songNotFound }
                return song
            }
            .eraseToAnyPublisher()
    }
    
}

private struct SearchResponse: Decodable {
    var results: [SongModel]
}
