//
//  RoverPhoto+CoreDataProperties.swift
//  
//
//  Created by Oti Oritsejafor on 6/30/20.
//
//

import Foundation
import CoreData


extension RoverPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoverPhoto> {
        return NSFetchRequest<RoverPhoto>(entityName: "RoverPhoto")
    }

    @NSManaged public var image: Data?
    @NSManaged public var url: String?

}
