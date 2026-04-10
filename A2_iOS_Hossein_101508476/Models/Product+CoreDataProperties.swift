import Foundation
import CoreData

extension Product {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Product> {
        NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged var productId: String
    @NSManaged var name: String
    @NSManaged var productDescription: String
    @NSManaged var price: Double
    @NSManaged var provider: String
}
