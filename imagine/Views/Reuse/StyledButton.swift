// Views/Shared/StyledButton.swift
import SwiftUI

struct StyledButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}
