import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
            HStack {
                Spacer()
                Text(message.text)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        } else {
            if message.text == "The matching user has entered the room." {
                Text(message.text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
            } else if message.text == "The matching user has entered the room." {
                Text(message.text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
            } else if message.text == "User has left the chat room" {
                Text(message.text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
            } else {
                HStack {
                    Text(message.text)
                        .padding()
                        .background(colorScheme == .dark ? Color.gray : Color.white)
                        .cornerRadius(8)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}
