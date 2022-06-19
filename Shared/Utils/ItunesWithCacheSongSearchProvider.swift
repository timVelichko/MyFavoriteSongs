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
    private var songsCache = Set<SongModel>()
    
    private enum Path: String {
        case search = "/search"
        case getSong = "/lookup"
    }
    
    private enum Param: String {
        case term, id, media
    }
    
    func searchSongs(for term: String) -> AnyPublisher<[SongModel], Error> {
        var urlComponents = URLComponents(string: domain + Path.search.rawValue)
        urlComponents?.queryItems = [
            URLQueryItem(name: Param.term.rawValue, value: term),
            URLQueryItem(name: Param.media.rawValue, value: "music")
        ]
        guard let url = urlComponents?.url else {
            return Fail(error: ItunesError.invalidUrl).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .map { [unowned self] in
                self.songsCache = self.songsCache.union($0.results)
                return $0.results
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getSong(by id: String) -> AnyPublisher<SongModel, Error> {
        if let song = songsCache.first(where: { "\($0.trackId)" == id }) {
            return Just(song)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
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
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

private struct SearchResponse: Decodable {
    var results: [SongModel]
}
