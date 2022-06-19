//
//  FavoritesService.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 18.06.2022.
//

import Foundation

protocol FavoritesService {
    
    var favoriteSongIds: [String] { get }
    func addToFavorites(_ songId: String)
    func removeFromFavorites(_ songId: String)
    
}
