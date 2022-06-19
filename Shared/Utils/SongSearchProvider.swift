//
//  SongSearchProvider.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 19.06.2022.
//

import Foundation
import Combine

struct SongModel: Decodable, Hashable {
    var trackId: Int64
    var artistName: String?
    var trackName: String?
    var artworkUrl100: String?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.trackId == rhs.trackId
    }
}

protocol SongSearchProvider {
    func searchSongs(for term: String) -> AnyPublisher<[SongModel], Error>
    func getSong(by id: String) -> AnyPublisher<SongModel, Error>
}
