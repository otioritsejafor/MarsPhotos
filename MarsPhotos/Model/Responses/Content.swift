//
//  Content.swift
//  MarsPhotos
//
//  Created by Oti Oritsejafor on 6/23/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation

// MARK: - RoverData
struct RoverData: Codable {
    let photos: [Photo]
}

// MARK: - Photo
struct Photo: Codable, Hashable {
    
    let id, sol: Int
    let camera: Camera
    let imgSrc: String
    let earthDate: String
    let rover: Rover

    enum CodingKeys: String, CodingKey {
        case id, sol, camera
        case imgSrc = "img_src"
        case earthDate = "earth_date"
        case rover
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return (lhs.id == rhs.id)
    }
    
}

// MARK: - Camera
struct Camera: Codable, Hashable {
    let id: Int
    let name: String
    let roverID: Int
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case roverID = "rover_id"
        case fullName = "full_name"
    }
}

// MARK: - Rover
struct Rover: Codable, Hashable {
    let id: Int
    let name, landingDate, launchDate, status: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case landingDate = "landing_date"
        case launchDate = "launch_date"
        case status
    }
}
