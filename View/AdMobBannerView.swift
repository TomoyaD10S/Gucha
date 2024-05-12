import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: View {
    var body: some View {
        AdBannerViewController()
            .frame(width: 320, height: 100)
            .background(Color.gray)
    }
}

struct AdBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 100)))
  
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // TESTID
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["2077ef9a63d2b398840261c8221a0c9b"] //Test
        
        bannerView.rootViewController = viewController
        bannerView.load(GADRequest())
        
        viewController.view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // nothing to do
    }
}
