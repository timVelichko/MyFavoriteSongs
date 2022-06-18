//
//  SongsSearchView.swift
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

struct SongsSearchView: View {
    
    private var songs: [Song] = [
        Song(title: "song 1", artistName: "artist 1"),
        Song(title: "song 2", artistName: "artist 2"),
        Song(title: "song 3", artistName: "artist 3"),
        Song(title: "song 4", artistName: "artist 4"),
        Song(title: "song 5", artistName: "artist 5", isFavorite: true),
        Song(title: "song 4", artistName: "artist 4"),
        Song(title: "song 4", artistName: "artist 4"),
        Song(title: "song 4", artistName: "artist 4"),
        Song(title: "song 4", artistName: "artist 4"),
        Song(title: "song 4", artistName: "artist 4"),
        Song(title: "song 4", artistName: "artist 4")
    ]
    @State private var searchInput: String = ""
    
    var body: some View {
        NavigationView {
            SongsGrid(songs)
            .navigationTitle("Search")
            .toolbar {
                Button("\(Image(systemName: "star.fill"))", action: {
                    
                })
            }
        }
        .searchable(text: $searchInput)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SongsSearchView()
                .previewInterfaceOrientation(.portrait)
//            ContentView()
//                .previewDevice("iPad Pro (9.7-inch)")
//                .previewInterfaceOrientation(.portraitUpsideDown)
        }
    }
}
