//
//  SongsSearchView.swift
//  Shared
//
//  Created by Tim Velichko on 16.06.2022.
//

import SwiftUI

struct SongsSearchView: View {
    
    @State private var searchInput: String = ""
    @ObservedObject private var model = SongsSearchModel()
    
    var body: some View {
        NavigationView {
            SongsGrid(model.songs)
                .navigationTitle("songsSearch.title")
                .toolbar {
                    NavigationLink(destination: FavoriteSongsView(model.songs, model: model), label: {
                        Text("\(Image(systemName: "star.fill"))")
                    })
                }
        }
        .searchable(text: $searchInput)
        .onSubmit(of: .search) {
            model.searchSongs(by: searchInput)
        }
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
