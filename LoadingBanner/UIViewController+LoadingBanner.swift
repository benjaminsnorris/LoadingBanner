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
    
    /// A custom loading banner that can show at the top of the view controller
    public var loadingBanner: LoadingBanner {
        let loadingBanner = StaticBanner.banner
        view.addSubview(loadingBanner)
        loadingBanner.translatesAutoresizingMaskIntoConstraints = false
        loadingBanner.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        loadingBanner.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        loadingBanner.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        return loadingBanner
    }
    
}