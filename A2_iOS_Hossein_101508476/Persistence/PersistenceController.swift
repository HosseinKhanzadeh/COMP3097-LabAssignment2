import CoreData

// Loads the Core Data stack from ProductModel.xcdatamodeld and exposes the main `viewContext` to SwiftUI.
struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ProductModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            // Run once per install when the store is empty; avoids duplicating rows after user data exists.
            ProductSeeder.seedIfNeeded(context: container.viewContext)
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
