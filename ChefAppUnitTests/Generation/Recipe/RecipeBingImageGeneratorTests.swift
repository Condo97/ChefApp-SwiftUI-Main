import XCTest
import CoreData
@testable import ChefApp_SwiftUI

class RecipeBingImageGeneratorTests: XCTestCase {
    var sut: RecipeBingImageGenerator!
    var mockContext: NSManagedObjectContext!
    var mockNetworkManager: MockNetworkPersistenceManager!
    
    override func setUp() {
        super.setUp()
        
        // Testing
        sut = RecipeBingImageGenerator()
//        CDClient = TestCDClient()
        mockContext = CDClient.mainManagedObjectContext
        mockNetworkManager = MockNetworkPersistenceManager()
        ChefAppNetworkPersistenceManager.shared = mockNetworkManager
    }
    
    func test_generateBingImage_Success() async throws {
        // Given
        let recipe = Recipe(context: mockContext)
        recipe.name = "Test Recipe"
        let objectID = await mockContext.perform { recipe.objectID }
        
        // When/Then
        try await sut.generateBingImage(
            recipeObjectID: objectID,
            authToken: try await AuthHelper.ensure(),
            in: mockContext
        )
        
        // Verify state transitions
        XCTAssertTrue(sut.isGenerating)
        let predicate = NSPredicate { _, _ in !self.sut.isGenerating }
        await fulfillment(of: [expectation(for: predicate, evaluatedWith: nil)], timeout: 30)
        
        // Verify network call
        XCTAssertEqual(mockNetworkManager.saveCalledCount, 1)
    }
    
    func test_generateBingImage_InvalidQuery() async {
        // Given
        let recipe = Recipe(context: mockContext) // No name set
        let objectID = try! await mockContext.perform { recipe.objectID }
        
        // When/Then
        do {
            try await sut.generateBingImage(
                recipeObjectID: objectID,
                authToken: try await AuthHelper.ensure(),
                in: mockContext
            )
            XCTFail("Should throw invalidQuery error")
        } catch RecipeBingImageGenerator.Errors.invalidQuery {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
}

// MARK: - Mock Network Manager
class MockNetworkPersistenceManager: ChefAppNetworkPersistenceManager {
    
    var saveCalledCount = 0
    
    override func saveAndUploadRecipeImageURLToServer(
        recipeObjectID: NSManagedObjectID,
        image: UIImage,
        imageExternalURL: URL,
        authToken: String,
        in managedContext: NSManagedObjectContext
    ) async throws {
        saveCalledCount += 1
    }
    
}
