//
//  UIViewController+LoadingBanner.swift
//  LoadingBanner
//
//  Created by Ben Norris on 2/18/16.
//  Copyright © 2016 BSN Design. All rights reserved.
//

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
        loadingBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingBanner.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        loadingBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        return loadingBanner
    }
    
}
