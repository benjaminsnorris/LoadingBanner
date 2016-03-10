/*
 |  _   ____   ____   _
 | ⎛ |‾|  ⚈ |-| ⚈  |‾| ⎞
 | ⎝ |  ‾‾‾‾| |‾‾‾‾  | ⎠
 |  ‾        ‾        ‾
 */

import UIKit

struct StaticBanner {
    static let banner = LoadingBanner(frame: .zero)
}

public extension UIViewController {
    
    /// A shared loading banner that can show at the top of the view controller
    public var sharedLoadingBanner: LoadingBanner {
        let loadingBanner = StaticBanner.banner
        view.addSubview(loadingBanner)
        loadingBanner.translatesAutoresizingMaskIntoConstraints = false
        loadingBanner.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        loadingBanner.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        loadingBanner.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        return loadingBanner
    }
    
}