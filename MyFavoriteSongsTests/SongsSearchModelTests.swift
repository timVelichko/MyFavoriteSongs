//
//  SongsSearchModelTests.swift
//  Tests iOS
//
//  Created by Tim Velichko on 19.06.2022.
//

import XCTest
@testable import MyFavoriteSongs
import Combine

class MockFavoritesService: FavoritesService {
    
    var favoriteSongIds: [String] = []
    
    func addToFavorites(_ songId: String) {
        favoriteSongIds.append(songId)
    }
    
    func removeFromFavorites(_ songId: String) {
        favoriteSongIds.removeAll(where: { $0 == songId })
    }
    
}

class MockSongSearchProvider: SongSearchProvider {
    
    var songsForSearch = [SongModel]()
    var singleSong: SongModel!
    var throwError = false
    
    func searchSongs(for term: String) -> AnyPublisher<[SongModel], Error> {
        if throwError {
            return Fail(error: MockError.randomError)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        } else {
            return Just(songsForSearch)
                .setFailureType(to: Error.self)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
    
    func getSong(by id: String) -> AnyPublisher<SongModel, Error> {
        if throwError || singleSong == nil {
            return Fail(error: MockError.randomError)
                .eraseToAnyPublisher()
        } else {
            return Just(singleSong)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
     
}

enum MockError: Error {
    case randomError
}

class SongsSearchModelTests: XCTestCase {
    
    private var model: SongsSearchModel!
    private var favoritesService: MockFavoritesService!
    private var songSearchProvider: MockSongSearchProvider!

    override func setUpWithError() throws {
        favoritesService = MockFavoritesService()
        songSearchProvider = MockSongSearchProvider()
        model = SongsSearchModel(favoritesService, songsProvider: songSearchProvider)
    }

    func testFavoriteSongs() throws {
        favoritesService.favoriteSongIds = []
        XCTAssertEqual(model.favoriteSongs.count, 0)
        
        let songId = "111"
        favoritesService.favoriteSongIds = [ songId ]
        
        XCTAssertEqual(model.favoriteSongs.count, 1)
        XCTAssertEqual(model.favoriteSongs[0].id, songId)
        validateEmpty(song: model.favoriteSongs[0])
        
        let testSong = Song(id: "546", title: "title 1", artistName: "1 artist", isFavorite: true)
        testSong.thumbnailUrl = URL(string: "https://zerkalo.io")
        let otherTestSong = Song(id: "111", title: "title 2", artistName: "2 artist", isFavorite: true)
        otherTestSong.thumbnailUrl = URL(string: "https://nashaniva.com")
        model.songs = [ otherTestSong, testSong ]
        favoritesService.favoriteSongIds = [ "546", "999", "3" ]
        
        XCTAssertEqual(model.favoriteSongs.count, 3)
        XCTAssertEqual(model.favoriteSongs[0].id, "546")
        XCTAssertEqual(model.favoriteSongs[0].title, "title 1")
        XCTAssertEqual(model.favoriteSongs[0].artistName, "1 artist")
        XCTAssertEqual(model.favoriteSongs[0].thumbnailUrl?.absoluteString, "https://zerkalo.io")
        XCTAssertEqual(model.favoriteSongs[1].id, "999")
        validateEmpty(song: model.favoriteSongs[1])
        
        songSearchProvider.singleSong = generateSongModel(id: "3", title: "fetched title",
                                                          artist: "fetched article")
        XCTAssertEqual(model.favoriteSongs[2].id, "3")
        XCTAssertEqual(model.favoriteSongs[2].title, "fetched title")
        XCTAssertEqual(model.favoriteSongs[2].artistName, "fetched article")
    }
    
    func testSearchSongsError() {
        model.searchInProgress = false
        model.error = nil
        model.songs = []
        model.justStarted = true
        songSearchProvider.throwError = true
        model.searchSongs(by: "test")
        XCTAssertTrue(model.searchInProgress)
        
        let expectation = expectation(description: "search songs request")
        DispatchQueue(label: "test").asyncAfter(deadline: .now() + 1.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.5)
        
        XCTAssertFalse(model.searchInProgress)
        XCTAssertNotNil(model.error)
        XCTAssertEqual(model.songs.count, 0)
        XCTAssertTrue(model.justStarted)
    }
    
    func testSearchSongsSuccess() {
        model.searchInProgress = false
        model.error = nil
        model.songs = []
        model.justStarted = true
        songSearchProvider.throwError = false
        var songModel = generateSongModel(id: "14", title: "14 title", artist: "artist 14")
        songModel.artworkUrl100 = "https://zerkalo.io"
        songSearchProvider.songsForSearch = [
            songModel,
            generateSongModel(id: "54", title: "a title", artist: "artist 55")
        ]
        model.searchSongs(by: "test")
        
        XCTAssertTrue(model.searchInProgress)
        
        let expectation = expectation(description: "search songs request")
        DispatchQueue(label: "test").asyncAfter(deadline: .now() + 1.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.5)
        
        XCTAssertFalse(model.searchInProgress)
        XCTAssertNil(model.error)
        XCTAssertEqual(model.songs.count, 2)
        XCTAssertEqual(model.songs[0].id, "14")
        XCTAssertEqual(model.songs[0].title, "14 title")
        XCTAssertEqual(model.songs[0].artistName, "artist 14")
        XCTAssertEqual(model.songs[0].thumbnailUrl?.absoluteString, "https://zerkalo.io")
        XCTAssertEqual(model.songs[1].id, "54")
        XCTAssertEqual(model.songs[1].title, "a title")
        XCTAssertEqual(model.songs[1].artistName, "artist 55")
        XCTAssertNil(model.songs[1].thumbnailUrl)
        XCTAssertFalse(model.justStarted)
    }
    
    func testGetSongDetailsError() {
        model.error = nil
        let emptySong = Song(id: "33")
        model.getSongDetails(by: "33", for: emptySong)
        
        XCTAssertNotNil(model.error)
        validateEmpty(song: emptySong)
    }
    
    func testGetSongDetailsSuccess() {
        var songModel = generateSongModel(id: "33", title: "b title", artist: "c artist")
        songModel.artworkUrl100 = "https://nashaniva.com"
        songSearchProvider.singleSong = songModel
        let emptySong = Song(id: "33")
        model.getSongDetails(by: "33", for: emptySong)
        
        XCTAssertNil(model.error)
        XCTAssertEqual(emptySong.title, "b title")
        XCTAssertEqual(emptySong.artistName, "c artist")
        XCTAssertEqual(emptySong.thumbnailUrl?.absoluteString, "https://nashaniva.com")
    }
    
}

// MARK: - Private methods
private extension SongsSearchModelTests {
    
    func generateSongModel(id: String, title: String, artist: String) -> SongModel {
        let json: [String: Any] = [
            "trackId": Int64(id)!,
            "artistName": artist,
            "trackName": title
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        return try! JSONDecoder().decode(SongModel.self, from: data)
    }
    
    func validateEmpty(song: Song) {
        XCTAssertNil(song.title)
        XCTAssertNil(song.artistName)
        XCTAssertNil(song.thumbnailUrl)
    }

}
