import Foundation
import SwiftUI

class FilterViewModel: ObservableObject {
    @Published var filterManager: FilterManager
    private let apiService = APIService.shared
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private var loadingTask: Task<Void, Never>?
    
    private var lastFilterType: FilterType?
    private var lastFilterValue: String?
    private var lastFilterState: [UUID: Bool] = [:]
    
    init() {
        self.filterManager = FilterManager.shared
        print("FilterViewModel инициализирован с общим FilterManager")
        
        self.filterManager.viewModel = self
        
        setupNotifications()
    }
    
    deinit {
        loadingTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoadingProgress),
            name: Notification.Name("CocktailLoadingProgress"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoadingComplete),
            name: Notification.Name("CocktailLoadingComplete"),
            object: nil
        )
    }
    
    @objc private func handleLoadingProgress(_ notification: Notification) {
        if let progress = notification.userInfo?["progress"] as? String {
            DispatchQueue.main.async { [weak self] in
                self?.filterManager.loadingProgress = progress
            }
        }
    }
    
    @objc private func handleLoadingComplete(_ notification: Notification) {
        guard let type = notification.userInfo?["type"] as? FilterType,
              let value = notification.userInfo?["value"] as? String else {
            return
        }
        
        if self.lastFilterType == type && self.lastFilterValue == value {
            DispatchQueue.main.async { [weak self] in
                self?.filterManager.loadingProgress = ""
            }
        }
    }
    
    // MARK: - API Взаимодействие
    
    @MainActor
    func loadFilterOptions() async {
        loadingTask?.cancel()
        
        loadingTask = Task {
            guard !Task.isCancelled else { return }
            
            isLoading = true
            error = nil
            print("Starting to load filter options")
            
            do {
                let categories = try await apiService.fetchFilterOptions()
                
                guard !Task.isCancelled else { return }
                
                print("Received categories: \(categories)")
                filterManager.categories = categories
            } catch {
                guard !Task.isCancelled else { return }
                
                print("Error loading filter options: \(error)")
                self.error = error
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Управление фильтрами
    
    func selectFilterOption(_ optionID: UUID) {
        cancelLoading()
        
        let wasSelected = lastFilterState[optionID] ?? false
        
        updateFilterSelections(selectingID: optionID)
        
        for categoryIndex in filterManager.categories.indices {
            if let index = filterManager.categories[categoryIndex].options.firstIndex(where: { $0.id == optionID }) {
                filterManager.categories[categoryIndex].options[index].isSelected = true
                filterManager.selectedFilterName = filterManager.categories[categoryIndex].options[index].name
                
                let filterType = filterManager.categories[categoryIndex].type
                let filterValue = filterManager.categories[categoryIndex].options[index].name
                
                lastFilterType = filterType
                lastFilterValue = filterValue
                lastFilterState[optionID] = true
                
                print("Выбран фильтр: \(filterValue), был выбран ранее: \(wasSelected)")
                loadFilteredCocktails(type: filterType, value: filterValue)
                break
            }
        }
    }
    
    private func updateFilterSelections(selectingID: UUID) {
        for categoryIndex in filterManager.categories.indices {
            for i in filterManager.categories[categoryIndex].options.indices {
                filterManager.categories[categoryIndex].options[i].isSelected = false
            }
        }
    }
    
    // MARK: - Загрузка коктейлей
    
    func loadFilteredCocktails(type: FilterType, value: String) {
        cancelLoading()
        
        lastFilterType = type
        lastFilterValue = value
        
        withAnimation {
            filterManager.isLoading = true
            filterManager.loadingProgress = "Загрузка коктейлей..."
            filterManager.error = nil
            filterManager.filteredCocktails = []
        }
        
        loadingTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                print("Загрузка коктейлей с фильтром: тип=\(type), значение=\(value)")
                
                let results = try await apiService.fetchCocktailsByFilter(type: type, value: value)
                print("Загружено коктейлей: \(results.count)")
                
                await MainActor.run {
                    if self.lastFilterType == type && self.lastFilterValue == value {
                        withAnimation {
                            self.filterManager.filteredCocktails = results
                            self.filterManager.isLoading = false
                            self.filterManager.loadingProgress = ""
                        }
                    }
                }
            } catch is CancellationError {
                print("Задача загрузки коктейлей была отменена")
            } catch {
                print("Ошибка при загрузке коктейлей: \(error)")
                
                await MainActor.run {
                    if self.lastFilterType == type && self.lastFilterValue == value {
                        withAnimation {
                            self.filterManager.error = error
                            self.filterManager.isLoading = false
                            self.filterManager.loadingProgress = ""
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Управление задачами
    
    func retryLastRequest() {
        if let type = lastFilterType, let value = lastFilterValue {
            loadFilteredCocktails(type: type, value: value)
        }
    }
    
    func refreshCurrentFilter() {
        if let type = lastFilterType, let value = lastFilterValue {
            loadFilteredCocktails(type: type, value: value)
        }
    }
    
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        
        filterManager.loadingProgress = ""
    }
}
