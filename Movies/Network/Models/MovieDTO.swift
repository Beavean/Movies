//
//  MovieDTO.swift
//  Movies
//
//  Created by Anton Petrov on 20.10.2023.
//

import Foundation

struct MovieDTO: Decodable {
    let id: Int
    let rating: Double
    let votes: Int
    let releaseDate: String
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let genresIDs: [Int]
    let video: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case rating = "vote_average"
        case votes = "vote_count"
        case releaseDate = "release_date"
        case title
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case genresIDs = "genre_ids"
        case video
    }
}
