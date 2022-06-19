//
//  SongsSearchModel.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 19.06.2022.
//

import Foundation
import Combine

class Song: Identifiable, ObservableObject {
    let id: String
    @Published var title: String?
    @Published var artistName: String?
    @Published var thumbnailUrl: URL?
    @Published var isFavorite: Bool = false
    
    required init(id: String, title: String? = nil,
                  artistName: String? = nil, isFavorite: Bool? = nil) {
        self.id = id
        self.title = title
        self.artistName = artistName
        if let isFavorite = isFavorite {
            self.isFavorite = isFavorite
        }
    }
    
    convenience init(id: String, title: String? = nil,
         artistName: String? = nil, listOfFavoriteIds: [String]) {
        self.init(id: id,
                  title: title,
                  artistName: artistName,
                  isFavorite: listOfFavoriteIds.contains(id))
    }
}

class SongsSearchModel: ObservableObject {
    
    @Published var songs: [Song] = []
    @Published var justStarted = true
    var favoriteSongs: [Song] {
        favoritesService.favoriteSongIds.map { id in
            if let existing = songs.first(where: { shown in shown.id == id }) {
                return existing
            } else {
                let song = Song(id: id, isFavorite: true)
                getSongDetails(by: id, for: song)
                return song
            }
        }
    }
    
    private let songsProvider = ItunesWithCacheSongSearchProvider()
    private var songsSubs: Cancellable?
    private var songDetailsSubscriptions = Set<AnyCancellable>()
    private let favoritesService: FavoritesService
    
    init(_ favoritesService: FavoritesService = LocalFavoritesService(UserDefaults.standard)) {
        self.favoritesService = favoritesService
    }
    
    func searchSongs(by term: String) {
        songsSubs = songsProvider.searchSongs(for: term)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                default: break
                }
            }, receiveValue: { [weak self] songModels in
                guard let self = self else { return }
                self.songs = songModels.map {
                    let song = Song(id: "\($0.trackId)",
                                    title: $0.trackName,
                                    artistName: $0.artistName,
                                    listOfFavoriteIds: self.favoritesService.favoriteSongIds)
                    if let urlString = $0.artworkUrl100 {
                        song.thumbnailUrl = URL(string: urlString)
                    }
                    return song
                }
                self.justStarted = false
            })
    }
    
    func getSongDetails(by id: String, for song: Song) {
        songsProvider.getSong(by: id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                default: break
                }
            }, receiveValue: { songModel in
                song.title = songModel.trackName
                song.artistName = songModel.artistName
                if let urlString = songModel.artworkUrl100 {
                    song.thumbnailUrl = URL(string: urlString)
                }
            })
            .store(in: &songDetailsSubscriptions)
    }
    
}
