//
//  Product+CoreDataProperties.swift
//  superMaketList_CoreData
//
//  Created by Pipe Carrasco on 01-06-21.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var idProduct: UUID?
    @NSManaged public var nameProduct: String?
    @NSManaged public var priceProduct: Int32

}

extension Product : Identifiable {

}
