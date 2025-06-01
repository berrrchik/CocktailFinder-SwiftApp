import SwiftUI

struct AlphabetCarouselView: View {
    let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    var onLetterSelected: (String) -> Void
    var selectedLetter: String? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(letters, id: \.self) { letter in
                    let letterString = String(letter).lowercased()
                    let isSelected = selectedLetter?.lowercased() == letterString
                    
                    Button(action: {
                        onLetterSelected(letterString)
                    }) {
                        Text(String(letter))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(width: 44, height: 44)
                            .background(isSelected ? Color.customOrange : Color.customOrange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color.customOrange : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    AlphabetCarouselView(selectedLetter: "a") { letter in
        print("Выбрана буква: \(letter)")
    }
} 