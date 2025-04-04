import SwiftUI

struct RandomCocktailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Случайный коктейль")
                .font(.title)
            Button {
            }
            label: {
                Label("Попытать удачу", systemImage: "dice")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(Color.blue)
            .cornerRadius(14)
        }
    }
}

#Preview {
    RandomCocktailView()
}
