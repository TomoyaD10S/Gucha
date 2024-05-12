import SwiftUI
import Firebase

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    
}
struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel: ObservableObject {
    @State private var chatUser: String
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var count = 0
    
    init(chatUser: String) {
        self.chatUser = chatUser
        
        fetchMessages()

    }
    
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Error: Current user ID is nil")
            return
        }
        let toId = chatUser
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen For messages: \(error.localizedDescription)"
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("No documents in snapshot")
                    return
                }
                
                self.chatMessages = documents.map { queryDocumentSnapshot in
                    let data = queryDocumentSnapshot.data()
                    let docId = queryDocumentSnapshot.documentID
                
                    return ChatMessage(documentId: docId, data: data)
                }
                
                DispatchQueue.main.async{
                    self.count += 1
                }
            }
    }

    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else {return}
        let toId = chatUser
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId:fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, "timestamp": Timestamp()] as [String: Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Fail to save message into Farebse:\(error)"
            }
            print("Succesfully saved current user sending message")
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Fail to save message into Farebse:\(error)"
            }
            
            print("Recipient saved message as well")
        }
    }
}

struct ChatLogView: View {
    @State private var chatUser: String
    @ObservedObject private var vm: ChatLogViewModel
    @ObservedObject private var tokenManager = TokenManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var showHelpManagementView = false
    @Binding var matchUserID: String
    @Binding var matchUser: String
    @Binding var matchUserAge: Int
    
    init(chatUser: String, matchUserID: Binding<String>, matchUser: Binding<String>, matchUserAge: Binding<Int>) {
        self._chatUser = State(initialValue: chatUser)
        self.vm = ChatLogViewModel(chatUser: chatUser)
        self._matchUserID = matchUserID
        self._matchUser = matchUser
        self._matchUserAge = matchUserAge
    }
    
    var body: some View {
        ZStack {
            messagesView
            
        }
        .navigationTitle(matchUser)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            tokenManager.pauseTimer()
        }
        .onDisappear {
            tokenManager.resumeTimer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showHelpManagementView.toggle()
                }) {
                    Image(systemName: "exclamationmark.triangle")
                }
            }
        }
        .sheet(isPresented: $showHelpManagementView) {
            HelpManagementView(isPresented: $showHelpManagementView, userID:matchUserID, name:matchUser ,age:matchUserAge)
        }
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(vm.chatMessages) { message in
                            MessageView(message: message)
                        }
                        
                        HStack{ Spacer() }
                        .id(Self.emptyScrollToString)
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.init(white: colorScheme == .dark ? 0.0 : 0.95, alpha: 1)))
            //.background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                chatBottomBar
                    .background(Color(.systemBackground).ignoresSafeArea())
            }
        }
        .textSelection(.enabled)
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Message")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

