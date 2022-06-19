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
            listView
                .navigationTitle("songsSearch.title")
                .toolbar {
                    NavigationLink(destination: FavoriteSongsView(model), label: {
                        Text("\(Image(systemName: "star.fill"))")
                    })
                }
        }
        .searchable(text: $searchInput)
        .onSubmit(of: .search) {
            model.searchSongs(by: searchInput)
        }
    }
    
    @ViewBuilder
    var listView: some View {
        if model.justStarted || (searchInput.count == 0 && model.songs.isEmpty) {
            Text("songsSearch.welcomeMessage")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
        } else if model.songs.isEmpty {
            let message = String(format: NSLocalizedString("songsSearch.empty", comment: ""),
                                 searchInput)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
        } else {
            SongsGrid(model.songs)
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
