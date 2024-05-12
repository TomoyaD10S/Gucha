import SwiftUI

enum AlertType3: Identifiable {
    case showingBlockAlert
    case completemessage
    
    var id: Int {
        // Use a unique identifier for each case
        switch self {
        case .showingBlockAlert:
            return 0
        case .completemessage:
            return 1
        }
    }
}

struct BlockView: View {
    let userID: String
    let name: String
    let age: Int
    @StateObject var blockedUserManager = BlockedUserManager.shared
    @State private var alertType: AlertType3?
    
    var body: some View {
        VStack {
            Spacer().frame(width:20)
            Text("Name: \(name)")
                .padding()
                .font(.title)
            
            Text("Age: \(age)")
                .padding()
                .font(.title)
            
            Spacer().frame(width:50)
            
            Text("Please press the button below if you want to block the matched user.")
                .padding()
                .font(.headline)
            
            Button(action: {
                self.alertType = .showingBlockAlert
            }) {
                Text("Block User")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .showingBlockAlert:
                return Alert(
                    title: Text("Are you sure you want to block?"),
                    message: Text("Once the user is blocked, they will never be matched again."),
                    primaryButton: .default(Text("Yes")) {
                        let userToBlock = BlockedUser(userID: self.userID, username: self.name, age: self.age)
                        blockedUserManager.blockUser(userToBlock)
                        self.alertType = .completemessage
                        
                    },
                    secondaryButton: .cancel(Text("No"))
                )
            case .completemessage:
                return Alert(
                    title: Text(""),
                    message: Text("Blocked successfully!"),
                    dismissButton: .default(Text("OK")) {
                        self.alertType = nil
                    }
                )
            }
        }
    }
}
