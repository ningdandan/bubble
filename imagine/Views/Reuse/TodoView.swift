import SwiftUI


struct TodoItemView: View {
    let action: Action
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: action.isFinished ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(action.isFinished ? .green : .gray)
            }
            Text(action.content)
                .subtitleFont()
                .strikethrough(action.isFinished)
            Spacer()
            Text(dateString(from: action.createdDate))
                .labelFont()
        }
        .padding(.vertical, 4)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}


struct TodoInputView: View {
    @State private var text: String = ""
    var onCommit: (String) -> Void

    

    var body: some View {
        HStack(spacing: 8) {
            TextField("Add a task...", text: $text)
                .titleFont()

            Button(action: {
                if !text.isEmpty {
                    onCommit(text)
                    text = ""
                }
            }) {
                Image("send")
//                    .foregroundColor(.gray)
            }
        }.dottedFieldStyle()
        .padding(.horizontal)
       .padding(.vertical, 12)
//        .background(Color.clear)
    }
}
