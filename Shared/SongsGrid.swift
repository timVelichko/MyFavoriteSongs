//
//  SongsGrid.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 18.06.2022.
//

import SwiftUI
import QGrid

extension UserDefaults: StorageProvider {}

struct SongsGrid: View {
    
    private var songs: [Song] = []
    private let favoritesService: FavoritesService
    
    init(_ songs: [Song],
         favoritesService: FavoritesService = LocalFavoritesService(UserDefaults.standard)) {
        self.songs = songs
        self.favoritesService = favoritesService
    }
    
    var body: some View {
        QGrid(songs, columns: 2, columnsInLandscape: 4,
        vSpacing: 20, hSpacing: 20) { song in
            SongCell(song, favoriteHandler: { isFavorite in
                if isFavorite {
                    favoritesService.addToFavorites(song.id)
                } else {
                    favoritesService.removeFromFavorites(song.id)
                }
            })
        }
        .padding([.leading, .trailing], 10)
        .ignoresSafeArea(.container, edges: [.bottom])
    }
    
}

struct SongCell: View {
    
    typealias FavoriteHandler = (Bool) -> Void
    
    @ObservedObject private var song: Song
    private let favoriteHandler: FavoriteHandler
    
    init(_ song: Song, favoriteHandler: @escaping FavoriteHandler) {
        self.song = song
        self.favoriteHandler = favoriteHandler
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            AsyncImage(url: song.thumbnailUrl) { image in
                image.resizable()
                    .aspectRatio(1, contentMode: .fit)
            } placeholder: {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.gray)
            }
                .padding([.leading, .trailing], 20)
            HStack {
                VStack(alignment: .leading) {
                    Text(song.title ?? "")
                        .lineLimit(2)
                    Text(song.artistName ?? "")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Button("\(Image(systemName: song.favoriteIconName))") {
                    song.isFavorite.toggle()
                    favoriteHandler(song.isFavorite)
                }
                .font(.title2)
            }
        }
    }
    
}

extension Song {
    
    var favoriteIconName: String {
        isFavorite ? "star.fill" : "star"
    }
    
}
