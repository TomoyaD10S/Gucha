import SwiftUI
import Foundation

class BlockedUserManager: ObservableObject {
    static let shared = BlockedUserManager()
    
    @Published var blockedUsers: [BlockedUser] = []
    
    private init() {
        loadBlockedUsers()
    }
    
    func blockUser(_ user: BlockedUser) {
        if !blockedUsers.contains(user) {
            blockedUsers.append(user)
            saveBlockedUsers()
        }
    }
    
    func unblockUser(_ user: BlockedUser) {
        if let index = blockedUsers.firstIndex(of: user) {
            blockedUsers.remove(at: index)
            saveBlockedUsers()
        }
    }
    
    func isBlocked(_ user: BlockedUser) -> Bool {
        return blockedUsers.contains(user)
    }
    
    private func saveBlockedUsers() {
        let data = try? JSONEncoder().encode(blockedUsers)
        UserDefaults.standard.set(data, forKey: "BlockedUsers")
    }
    
    private func loadBlockedUsers() {
        if let data = UserDefaults.standard.data(forKey: "BlockedUsers") {
            if let savedBlockedUsers = try? JSONDecoder().decode([BlockedUser].self, from: data) {
                self.blockedUsers = savedBlockedUsers
            }
        }
    }
}

struct BlockedUser: Identifiable, Equatable, Codable {
    let id: UUID
    let userID: String
    let username: String
    let age: Int
    
    init(userID: String, username: String, age: Int) {
        self.id = UUID()
        self.userID = userID
        self.username = username
        self.age = age
    }
}




struct BlockedUserView: View {
    @ObservedObject var blockedUserManager = BlockedUserManager.shared
    
    var body: some View {
        VStack {
            Text("Blocked Users")
                .font(.title)
                .padding()
            
            List(blockedUserManager.blockedUsers) { user in
                VStack(alignment: .leading) {
                    Text("Username: \(user.username)")
                    Text("Age: \(user.age)")
                }
            }
            .padding()
            
            Spacer()
        }
    }
}
