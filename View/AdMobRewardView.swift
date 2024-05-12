import SwiftUI
import UIKit
import GoogleMobileAds

class AdMobRewardView: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var rewardLoaded: Bool = false
    var rewardedAd: GADRewardedAd? = nil
    
    override init() {
        super.init()
        loadReward()
    }
    
    func loadReward() {
        //TEST ID
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest(), completionHandler: { (ad, error) in
            if let _ = error {
                self.rewardLoaded = false
                return
            }
            self.rewardLoaded = true
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        })
    }
    
    func showReward() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootVC = windowScene?.windows.first?.rootViewController
        if let ad = rewardedAd {
            ad.present(fromRootViewController: rootVC!, userDidEarnRewardHandler: {
                TokenManager.shared.recoverTokenIfNeeded()
                self.rewardLoaded = false
            })
        } else {
            self.rewardLoaded = false
            print("Rewarded ad is nil. Loading reward again.")
            self.loadReward()
        }
    }
    
}
