//
//  FavoriteSongsView.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 18.06.2022.
//

import SwiftUI

struct FavoriteSongsView: View {
    
    private let favoritesService = LocalFavoritesService(UserDefaults.standard)
    private let model: SongsSearchModel
    
    init(_ model: SongsSearchModel) {
        self.model = model
    }
    
    var body: some View {
        listView
            .navigationTitle("favoriteSongs.title")
    }
    
    @ViewBuilder
    var listView: some View {
        if model.favoriteSongs.isEmpty {
            Text("favoriteSongs.empty")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
        } else {
            SongsGrid(model.favoriteSongs)
        }
    }
    
}
