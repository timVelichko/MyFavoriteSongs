//
//  SongsSearchView.swift
//  Shared
//
//  Created by Tim Velichko on 16.06.2022.
//

import SwiftUI

class Song: Identifiable, ObservableObject {
    let id: String
    @Published var title: String?
    @Published var artistName: String?
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

struct SongsSearchView: View {
    
    private var songs: [Song] = []
    @State private var searchInput: String = ""
    
    init() {
        let favoritedList = LocalFavoritesService(UserDefaults.standard).favoriteSongIds
        songs = stride(from: 0, to: 10, by: 1).map {
            Song(id: "\($0)",
                 title: "song \($0)",
                 artistName: "artist \($0)",
                 listOfFavoriteIds: favoritedList)
        }
    }
    
    var body: some View {
        NavigationView {
            SongsGrid(songs)
                .navigationTitle("songsSearch.title")
                .toolbar {
                    NavigationLink(destination: FavoriteSongsView(songs), label: {
                        Text("\(Image(systemName: "star.fill"))")
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
