import XCTest
import CoreData
@testable import ChefApp_SwiftUI

class RecipeViewModelTests: XCTestCase {
    
    var viewModel: RecipeViewModel!
    var testManagedContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        testManagedContext = CDClient.mainManagedObjectContext
        
        // Create test recipe and viewModel
        let recipe = Recipe(context: testManagedContext)
        recipe.estimatedServings = 4
        recipe.estimatedServingsModified = 0
        try! testManagedContext.save()
        viewModel = RecipeViewModel(recipe: recipe)
    }
    
    override func tearDown() {
        testManagedContext.reset()
        viewModel = nil
        testManagedContext = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(viewModel.recipe, "Recipe should be initialized")
        XCTAssertEqual(viewModel.expandedPercentage, 1.0, "Initial expanded percentage should be 1.0")
        XCTAssertFalse(viewModel.isEditingTitle, "Should not be editing title initially")
    }
    
    func testGetEstimatedServings() {
        // Test default value
        XCTAssertEqual(viewModel.getEstimatedServings(), 4)
        
        // Test modified value
        viewModel.recipe.estimatedServingsModified = 6
        XCTAssertEqual(viewModel.getEstimatedServings(), 6)
    }
    
    func testSetEstimatedServings() async {
        let expectation = self.expectation(description: "Estimated servings update")
        
        viewModel.setEstimatedServings(servings: 8, in: testManagedContext)
        
        try! await Task.sleep(nanoseconds: 1_000_000)
        
        do {
            try await testManagedContext.perform {
                let updatedRecipe = try self.testManagedContext.existingObject(with: self.viewModel.recipe.objectID) as! Recipe
                XCTAssertEqual(updatedRecipe.estimatedServings, 8)
                expectation.fulfill()
            }
        } catch {
            XCTFail("Failed to fetch updated recipe: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testImageGenerationWorkflow() async {
        let mockGenerator = MockRecipeBingImageGenerator()
        let mockAuth = MockAuthHelper()
        
        await viewModel.regenerateBingImageIfNecessary(
            recipeBingImageGenerator: mockGenerator,
            in: testManagedContext
        )
        
        XCTAssertTrue(mockGenerator.generateCalled, "Should call image generator when no image exists")
    }
    
    func testInvalidIngredientValidation() async throws {
        let mockRegenerator = MockRecipeDirectionsRegenerator()
        
        // Create recipe with all ingredients marked for deletion
        try await testManagedContext.perform { [weak self] in
            let ingredient = RecipeMeasuredIngredient(context: self!.testManagedContext)
            ingredient.markedForDeletion = true
            self!.viewModel.recipe.addToMeasuredIngredients(ingredient)
            try self!.testManagedContext.save()
        }
        
        await viewModel.resolveIngredientsAndRegenerateDirections(
            recipeDirectionsRegenerator: mockRegenerator,
            in: testManagedContext
        )
        
        await MainActor.run {
            XCTAssertTrue(viewModel.alertShowingAllItemsMarkedForDeletion, "Should show alert when all ingredients marked for deletion")
        }
    }
    
    // MARK: - Mock Implementations
    class MockRecipeBingImageGenerator: RecipeBingImageGenerator {
        var generateCalled = false
        
        override func generateBingImage(recipeObjectID: NSManagedObjectID, authToken: String, in managedContext: NSManagedObjectContext) async throws {
            generateCalled = true
        }
    }
    
    class MockRecipeDirectionsRegenerator: RecipeDirectionsRegenerator {
        var regenerateCalled = false
        
        override func regenerateDirectionsAndResolveUpdatedIngredients(for recipeObjectID: NSManagedObjectID, additionalInput: String, authToken: String, in managedContext: NSManagedObjectContext) async throws {
            regenerateCalled = true
        }
    }
    
    class MockAuthHelper {
        static func ensure() async throws -> String {
            return "mock-auth-token"
        }
    }
    
}
