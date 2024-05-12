import SwiftUI

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15){
                Text("TERMS AND CONDITIONS")
                    .font(.system(size: 25, weight: .bold))
                Spacer().frame(height: 10)
                
                Text("Create your own EULA")
                Spacer().frame(height: 20)
                
            }
        }
        .padding()
    }
}

