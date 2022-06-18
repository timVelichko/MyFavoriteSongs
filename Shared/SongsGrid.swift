//
//  SongsGrid.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 18.06.2022.
//

import SwiftUI
import QGrid

struct SongsGrid: View {
    
    @State var songs: [Song] = []
    
    init(_ songs: [Song]) {
        self._songs = State(wrappedValue: songs)
    }
    
    var body: some View {
        QGrid(songs, columns: 2, columnsInLandscape: 4,
        vSpacing: 20, hSpacing: 20) { song in
            SongCell(song)
        }
        .padding([.leading, .trailing], 10)
        .ignoresSafeArea(.container, edges: [.bottom])
    }
    
}

struct SongCell: View {
    
    let song: Song
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Image(systemName: "music.quarternote.3")
                .resizable()
                .foregroundColor(.gray)
                .aspectRatio(1, contentMode: .fit)
                .padding([.leading, .trailing], 20)
            HStack {
                VStack(alignment: .leading) {
                    Text(song.title ?? "")
                    Text(song.artistName ?? "")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("\(Image(systemName: song.isFavorite ? "star.fill" : "star"))") {
                    
                }
                .font(.title2)
            }
        }
    }
    
}
