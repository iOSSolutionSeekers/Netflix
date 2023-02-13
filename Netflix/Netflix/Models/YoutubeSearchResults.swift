//
//  YoutubeSearchResults.swift
//  Netflix
//
//  Created by Sudharshan on 21/12/22.
//

import Foundation

struct YoutubeSearchResults: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
