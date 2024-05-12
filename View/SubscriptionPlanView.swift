import SwiftUI
import StoreKit

struct SubscriptionPlanView: View {

    @StateObject var storeVM = StoreVM()

    var body: some View {
        VStack {
            Spacer()

            Text("Subscription Plan")
                .font(.title)
                .padding(.bottom, 20)

            if storeVM.purchasedSubscriptions.isEmpty {
                HStack {
                    Text("$1.00")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    Text("/month")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Text("Unlimited chatting without token restrictions upon subscription.")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                
                ForEach(storeVM.subscriptions) { product in
                    Button("Subscribe") {
                        Task {
                            await buy(product: product)
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
                }
                
                Text("Your subscription will be managed by your device. You can access your subscription only on this device.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 5)

                Spacer()
            } else {
                
                Text("You are subscribed!")
                    .font(.title)
                    .foregroundColor(.green)
                Text("Your subscription will be managed by your device. You can access your subscription only on this device.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                Text("Unlimited chatting without token restrictions upon subscription.")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                
                Text("To cancel a subscription on an iOS device, open the Settings app, select your Apple ID, choose 'Subscriptions,' and proceed with the cancellation process.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                Spacer()
            }
        }
        .padding()
    }
    func buy(product: Product) async {
        do {
            if try await storeVM.purchase(product) != nil {
                print("purchase succeeded")
            }
        } catch {
            print("purchase failed")
        }
    }
}
