//
//  FavoriteSongsView.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 18.06.2022.
//

import SwiftUI

struct FavoriteSongsView: View {
    
    private let favoritesService = LocalFavoritesService(UserDefaults.standard)
    private let shownSongs: [Song]
    private let model: SongsSearchModel
    
    init(_ shownSongs: [Song], model: SongsSearchModel) {
        self.shownSongs = shownSongs
        self.model = model
    }
    
    var body: some View {
        SongsGrid(favoritesService.favoriteSongIds.map { id in
            if let existing = shownSongs.first(where: { shown in shown.id == id }) {
                return existing
            } else {
                let song = Song(id: id, isFavorite: true)
                model.getSongDetails(by: id, for: song)
                return song
            }
        })
        .navigationTitle("favoriteSongs.title")
    }
    
}
