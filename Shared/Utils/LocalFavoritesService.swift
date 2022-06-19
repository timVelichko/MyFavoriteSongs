//
//  LocalFavoritesService.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 18.06.2022.
//

import Foundation

protocol StorageProvider {
    
    func stringArray(forKey key: String) -> [String]?
    func set(_ value: Any?, forKey defaultName: String)
    
}

class LocalFavoritesService: FavoritesService {
    
    private let storage: StorageProvider
    private let favoriteIdsKey = "favoriteIds"
    
    init(_ storage: StorageProvider) {
        self.storage = storage
    }
    
    var favoriteSongIds: [String] { storage.stringArray(forKey: favoriteIdsKey) ?? [] }
    
    func addToFavorites(_ songId: String) {
        let songIds = Set(favoriteSongIds + [songId])
        storage.set(Array(songIds), forKey: favoriteIdsKey)
    }
    
    func removeFromFavorites(_ songId: String) {
        var songIds = favoriteSongIds
        songIds.removeAll(where: { $0 == songId })
        storage.set(songIds, forKey: favoriteIdsKey)
    }
    
}
