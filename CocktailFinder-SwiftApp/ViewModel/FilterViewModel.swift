import Foundation

class FilterViewModel: ObservableObject {
    @Published var filterManager: FilterManager
    private let apiService = APIService.shared
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    init() {
        self.filterManager = FilterManager(categories: [])
        print("FilterViewModel initialized")
    }
    
    @MainActor
    func loadFilterOptions() async {
        isLoading = true
        print("Starting to load filter options")
        do {
            let categories = try await apiService.fetchFilterOptions()
            print("Received categories: \(categories)")
            filterManager.categories = categories
        } catch {
            print("Error loading filter options: \(error)")
            self.error = error
        }
        isLoading = false
    }
} 