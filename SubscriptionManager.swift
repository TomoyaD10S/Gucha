import Foundation
import StoreKit
import SwiftUI

import StoreKit

class SubscriptionManager: NSObject, ObservableObject, SKProductsRequestDelegate {
    static let shared = SubscriptionManager()

    private let productID = "Subscription4Gucha"
    
    var isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
    @Published var isSubscribed = false

    
    func requestSubscription() {
        guard SKPaymentQueue.canMakePayments() else {
            print("User cannot make payments.")
            return
        }

        let paymentRequest = SKMutablePayment()
        paymentRequest.productIdentifier = productID
        SKPaymentQueue.default().add(paymentRequest)
    }

    func handlePaymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                handlePurchased()
                queue.finishTransaction(transaction)
                print(transaction)
            case .failed:
                print("Transaction failed: \(transaction.error?.localizedDescription ?? "")")
                queue.finishTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }

    func cancelSubscription() {
        guard let subscriptionTransaction = SKPaymentQueue.default().transactions.first(where: {
            $0.transactionState == .purchased && $0.payment.productIdentifier == productID
        }) else {
            showAlert(message: "Subscription not found.")
            print("Subscription not found.")
            return
        }
        print("Transaction state:", subscriptionTransaction.transactionState.rawValue)
        SKPaymentQueue.default().finishTransaction(subscriptionTransaction)
        UserDefaults.standard.set(false, forKey: "isSubscribed")

        showCancelPopup()
    }

    func fetchReceipt() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    private func handlePurchased() {
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        showSubscriptionSuccessPopup()
    }

    private func showAlert(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }

    private func showCancelPopup() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        let alertController = UIAlertController(title: "Subscription Canceled", message: "Your subscription has been successfully canceled.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rootViewController.present(alertController, animated: true, completion: nil)
    }

    private func showSubscriptionSuccessPopup() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        let alertController = UIAlertController(title: "Subscription Success", message: "Your subscription has been successfully processed.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rootViewController.present(alertController, animated: true, completion: nil)
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        for product in products {
            print("Product ID: \(product.productIdentifier), Title: \(product.localizedTitle), Price: \(product.price)")
        }
    }
}

