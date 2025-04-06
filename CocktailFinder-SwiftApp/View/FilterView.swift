import SwiftUI

struct FilterCategory1: Identifiable {
    let id = UUID()
    var name: String
    var options: [FilterOption]
}

struct FilterOption: Identifiable {
    let id = UUID()
    var name: String
    var isSelected: Bool = false
}

class FilterManager: ObservableObject {
    @Published var categories: [FilterCategory]
    @Published var selectedOption: String?
    
    init(categories: [FilterCategory]) {
        self.categories = categories
    }
    
    func selectOption(_ option: String) {
        withAnimation {
            if selectedOption == option {
                selectedOption = nil
            } else {
                selectedOption = option
            }
            print("Selected option: \(String(describing: selectedOption))")
        }
    }
}

import SwiftUI

struct FilterView: View {
    @StateObject private var viewModel = FilterViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                } else if let error = viewModel.error {
                    VStack {
                        Text("Ошибка загрузки")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Повторить") {
                            Task {
                                await viewModel.loadFilterOptions()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.filterManager.categories.isEmpty {
                    Text("Нет доступных фильтров")
                        .font(.headline)
                } else {
                    List {
                        ForEach(viewModel.filterManager.categories) { category in
                            DisclosureGroup(
                                content: {
                                    ForEach(category.options, id: \.self) { option in
                                        FilterOptionRow(
                                            title: option,
                                            isSelected: viewModel.filterManager.selectedOption == option
                                        ) {
                                            withAnimation {
                                                viewModel.filterManager.selectOption(option)
                                            }
                                        }
                                    }
                                },
                                label: {
                                    Text(category.name)
                                        .font(.headline)
                                }
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .task {
            print("FilterView appeared, starting data load")
            await viewModel.loadFilterOptions()
        }
    }
}

class FilterViewModel: ObservableObject {
    @Published var filterManager: FilterManager
    private let apiService = APIService.shared
    @Published var isLoading = false
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

struct FilterOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
