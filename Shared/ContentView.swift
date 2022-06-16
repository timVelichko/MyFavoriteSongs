//
//  ContentView.swift
//  Shared
//
//  Created by Tim Velichko on 16.06.2022.
//

import SwiftUI

struct Song: Identifiable {
    let id = UUID()
    let title: String?
    let artistName: String?
    var isFavorite: Bool = false
}

struct ContentView: View {
    
    @State private var songs: [Song] = [
        Song(title: "song 1", artistName: "artist 1"),
        Song(title: "song 2", artistName: "artist 2"),
        Song(title: "song 3", artistName: "artist 3"),
        Song(title: "song 4", artistName: "artist 4"),
        Song(title: "song 5", artistName: "artist 5", isFavorite: true)
    ]
    @State private var searchInput: String = ""
    
    var body: some View {
        NavigationView {
            List(songs) {
                SongCell($0)
            }
            .navigationTitle("Search")
        }
        .searchable(text: $searchInput)
    }
}

struct SongCell: View {
    
    let song: Song
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
