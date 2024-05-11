import SwiftUI
import Firebase

class FirebaseManager: ObservableObject {
    @Published var isLoggedIn = false
    static let shared = FirebaseManager()
    let auth: Auth
    let firestore: Firestore
    
    private init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        listenForAuthChanges()
    }
    
    
    func listenForAuthChanges() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                if user.isEmailVerified {
                    self.isLoggedIn = true
                    print("User is logged in and email is verified.")
                } else {
                    self.isLoggedIn = false
                    print("User is logged in but email is not verified.")
                }
            } else {
                self.isLoggedIn = false
                print("User is logged out.")
            }
        }
    }
    
    
    func signOut() {
        do {
            try auth.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func sendVerificationEmail(completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in"]))
            return
        }
        
        currentUser.sendEmailVerification { error in
            completion(error)
        }
    }
    
    func fetchDataFromFirestore() {
        firestore.collection("users").document("exampleDocument").getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                let data = document.data()
                print("Fetched data: \(data ?? [:])")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    static func sendExitMessage(to chatUser: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "ChatManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user UID is nil"])
            completion(error)
            return
        }
        
        let messageData = [
            FirebaseConstants.fromId: currentUserUID,
            FirebaseConstants.toId: chatUser,
            FirebaseConstants.text: "User has left the chat room",
            "timestamp": Timestamp()
        ] as [String: Any]
        
        let messagesCollectionRef = Firestore.firestore().collection("messages").document(chatUser).collection(currentUserUID)
        
        messagesCollectionRef.addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending exit message: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Exit message sent successfully.")
                completion(nil)
            }
        }
    }
    
    static func sendJoinMessage(to chatUser: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "ChatManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user UID is nil"])
            completion(error)
            return
        }
        
        let messageData = [
            FirebaseConstants.fromId: currentUserUID,
            FirebaseConstants.toId: chatUser,
            FirebaseConstants.text: "The matching user has entered the room.",
            "timestamp": Timestamp()
        ] as [String: Any]
        
        let messagesCollectionRef = Firestore.firestore().collection("messages").document(chatUser).collection(currentUserUID)
        
        messagesCollectionRef.addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending exit message: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Join message sent successfully.")
                completion(nil)
            }
        }
    }
    
    func saveUserProfile(name: String, age: Int, completion: @escaping (Error?) -> Void) {
        guard let currentUser = auth.currentUser else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in"]))
            return
        }
        
        let userData: [String: Any] = [
            "name": name,
            "age": age
        ]
        
        let userDocRef = firestore.collection("user").document(currentUser.uid)
        userDocRef.setData(userData, merge: true) { error in
            completion(error)
        }
    }
    
    func report(type: String, explanation: String, other: Int, completion: @escaping (Error?) -> Void) {
        guard let currentUser = auth.currentUser else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in"]))
            return
        }
        
        var reportData: [String: Any] = [:]
        
        if other == 1 {
            reportData = [
                "type": type,
                "explanation": explanation
            ]
        } else {
            reportData = [
                "type": type
            ]
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
            
        firestore.collection("report").document(currentUser.uid).collection(dateString).addDocument(data: reportData) { error in
            if let error = error {
                print("Error reporting: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Reported successfully!")
                completion(nil)
            }
        }
    }
    
    func fetchUserInfo(userID: String, completion: @escaping (Result<(name: String, age: Int), Error>) -> Void) {
        firestore.collection("user").document(userID).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                if let name = document.get("name") as? String, let age = document.get("age") as? Int {
                    completion(.success((name, age)))
                } else {
                    completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document data was malformed."])))
                }
            } else {
                completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document does not exist."])))
            }
        }
    }
}

