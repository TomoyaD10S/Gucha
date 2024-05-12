import SwiftUI

enum AlertType: Identifiable {
    case showingReportAlert
    case showErrorAlert
    case completemessage
    
    var id: Int {
        // Use a unique identifier for each case
        switch self {
        case .showingReportAlert:
            return 0
        case .showErrorAlert:
            return 1
        case .completemessage:
            return 2
        }
    }
}

struct ReportView: View {
    @State private var alertType: AlertType?
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @State private var selectedViolation: String = ""
    @State private var otherViolation: String = ""
    @State private var isSubmitEnabled = false
    @State private var isshowErrorAlert = false

    var body: some View {
        VStack {
            
            VStack(alignment: .leading) {
                Text("Violation:")
                    .padding(.leading)
                VStack(alignment: .leading) {
                    CheckboxField(text: "Spam", isChecked: $selectedViolation, value: "Spam")
                    CheckboxField(text: "Inappropriate Content", isChecked: $selectedViolation, value: "Inappropriate Content")
                    CheckboxField(text: "Harassment", isChecked: $selectedViolation, value: "Harassment")
                    CheckboxField(text: "Bullying", isChecked: $selectedViolation, value: "Bullying")
                    CheckboxField(text: "Other", isChecked: $selectedViolation, value: "Other")
                }
            }
            .padding()
            
            if selectedViolation == "Other" {
                TextEditorWithBorder(text: $otherViolation)
                    .padding()
            }
            
            Button("Submit") {
                self.alertType = .showingReportAlert
            }
            .padding()
            .disabled(!isSubmitEnabled)
            
        }
        .navigationTitle("Report")
        
        .onChange(of: selectedViolation) { _, newValue in
            
            if newValue != "Other" {
                isSubmitEnabled = true
            } else {
                isSubmitEnabled = false
            }
        }
        .onChange(of: otherViolation) { _, newValue in

            if selectedViolation == "Other" {
                isSubmitEnabled = !newValue.isEmpty
            }
        }
        
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .showingReportAlert:
                return Alert(
                    title: Text("Are you sure you want to report?"),
                    message: Text("Reporting this conversation will be reviewed by the administration, and may result in the suspension of the matched user's account."),
                    primaryButton: .default(Text("Yes")) {
                        if selectedViolation == "Other" {
                            firebaseManager.report(type: selectedViolation, explanation: otherViolation, other: 1){ error in
                                if let error = error {
                                    print("Failed to report: \(error.localizedDescription)")
                                    self.alertType = .showErrorAlert
                                } else {
                                    print("Reported successfully!")
                                    self.alertType = .completemessage
                                }
                            }
                        } else {
                            firebaseManager.report(type: selectedViolation, explanation: "", other: 0){ error in
                                if let error = error {
                                    print("Failed to report: \(error.localizedDescription)")
                                    self.alertType = .showErrorAlert
                                } else {
                                    print("Reported successfully!")
                                    self.alertType = .completemessage
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("No"))
                )
            case .showErrorAlert:
                return Alert(
                    title: Text("Error"),
                    message: Text("Failed to send a report"),
                    dismissButton: .default(Text("OK")) {
                        self.alertType = nil
                    }
                )
            case .completemessage:
                return Alert(
                    title: Text(""),
                    message: Text("Reported successfully!"),
                    dismissButton: .default(Text("OK")) {
                        self.alertType = nil
                    }
                )
            }
        }
    }

    
    struct TextEditorWithBorder: View {
        @Binding var text: String
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            if colorScheme == .dark {
                TextEditor(text: $text)
                    .background(RoundedRectangle(cornerRadius: 0).stroke(Color.white, lineWidth: 1))
                    .padding()
            } else {
                TextEditor(text: $text)
                    .background(RoundedRectangle(cornerRadius: 0).stroke(Color.black, lineWidth: 1))
                    .padding()
            }
        }
    }
}

struct CheckboxField: View {
    var text: String
    @Binding var isChecked: String
    var value: String
    
    var body: some View {
        Button(action: {
            isChecked = value
        }) {
            HStack {
                Image(systemName: isChecked == value ? "checkmark.square" : "square")
                Text(text)
            }
        }
        .foregroundColor(.primary)
        .padding(.vertical, 4)
    }
}
