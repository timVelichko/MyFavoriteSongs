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
    
    init(_ shownSongs: [Song]) {
        self.shownSongs = shownSongs
    }
    
    var body: some View {
        SongsGrid(favoritesService.favoriteSongIds.map { id in
            if let existing = shownSongs.first(where: { shown in shown.id == id }) {
                return existing
            } else {
                return Song(id: id, isFavorite: true)
            }
        })
        .navigationTitle("favoriteSongs.title")
    }
    
}
