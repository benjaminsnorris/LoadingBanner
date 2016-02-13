//
//  LoadingBanner.swift
//  falkor
//
//  Created by Ben Norris on 2/10/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import UIKit

@IBDesignable public class LoadingBanner: UIView {

    // MARK: - Public properties
    
    @IBInspectable public var showing: Bool = false {
        didSet {
            shouldShow = showing
            configureShowing()
        }
    }
    
    @IBInspectable public var backgroundTint: UIColor = UIColor.blueColor().colorWithAlphaComponent(0.2) {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable public var errorTint: UIColor = UIColor.redColor().colorWithAlphaComponent(0.2) {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable public var height: CGFloat = 24.0 {
        didSet {
            heightConstraint.constant = height
            layoutIfNeeded()
        }
    }
    
    
    // MARK: - Private properties
    
    private let visualEffectView: UIVisualEffectView = {
        let lightStyle = UIBlurEffectStyle.ExtraLight
        let lightBlurEffect = UIBlurEffect(style: lightStyle)
        return UIVisualEffectView(effect: lightBlurEffect)
    }()
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    private var heightConstraint: NSLayoutConstraint!
    private let loadingStackView = UIStackView()
    private let errorStackView = UIStackView()
    private let errorLabel = UILabel()
    private var errorMessage: String?
    private var shouldShow = false
    
    
    // MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    // MARK: - Public functions
    
    public func showError(message: String?) {
        errorMessage = message
        errorLabel.text = message
        errorStackView.hidden = false
        loadingStackView.hidden = true
        shouldShow = true
        configureShowing()
    }
    
    

}


// MARK: - Internal functions

extension LoadingBanner {
    
    func dismissBanner() {
        shouldShow = false
        configureShowing({
            self.errorMessage = nil
            self.loadingStackView.hidden = false
            self.errorStackView.hidden = true
        })
    }

}


// MARK: - Private functions

private extension LoadingBanner {
    
    func configureShowing(completion: (() -> ())? = nil) {
        updateColors()
        if shouldShow {
            spinner.startAnimating()
            heightConstraint.constant = height
        } else {
            spinner.stopAnimating()
            heightConstraint.constant = 0.0
        }
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
                self.layoutIfNeeded()
            }) { complete in
                completion?()
            }
        }
    }
    
    func updateColors() {
        if let _ = errorMessage {
            visualEffectView.contentView.backgroundColor = errorTint
        } else {
            visualEffectView.contentView.backgroundColor = backgroundTint
        }
    }
    
    
    // MARK: - Initial setup
    
    func setupViews() {
        backgroundColor = nil
        
        heightConstraint = heightAnchor.constraintEqualToConstant(height)
        heightConstraint.active = true
        
        addSubview(visualEffectView)
        setupFullSize(visualEffectView)
        
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: visualEffectView.effect as! UIBlurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        visualEffectView.contentView.addSubview(vibrancyView)
        setupFullSize(vibrancyView)
        
        vibrancyView.contentView.addSubview(loadingStackView)
        setupFullHeight(loadingStackView)
        loadingStackView.centerXAnchor.constraintEqualToAnchor(vibrancyView.centerXAnchor).active = true
        loadingStackView.spacing = 4.0
        
        loadingStackView.addArrangedSubview(spinner)
        spinner.hidesWhenStopped = false
        
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        loadingStackView.addArrangedSubview(label)
        
        vibrancyView.contentView.addSubview(errorStackView)
        setupFullSize(errorStackView)
        
        errorStackView.addArrangedSubview(errorLabel)
        errorLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        errorLabel.textAlignment = .Center
        
        let closeLabel = UILabel()
        closeLabel.text = "✕"
        closeLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        closeLabel.translatesAutoresizingMaskIntoConstraints = false
        closeLabel.widthAnchor.constraintEqualToAnchor(closeLabel.heightAnchor).active = true
        errorStackView.addArrangedSubview(closeLabel)
        
        errorStackView.hidden = true
        
        let button = UIButton()
        addSubview(button)
        setupFullSize(button)
        button.addTarget(self, action: "dismissBanner", forControlEvents: .TouchUpInside)
        
        updateColors()
    }
    
    func setupFullSize(view: UIView) {
        guard let superview = view.superview else { fatalError("Must have a superview to set up constraints") }
        setupFullHeight(view)
        view.leadingAnchor.constraintEqualToAnchor(superview.leadingAnchor).active = true
        view.trailingAnchor.constraintEqualToAnchor(superview.trailingAnchor).active = true
}
    
    func setupFullHeight(view: UIView) {
        guard let superview = view.superview else { fatalError("Must have a superview to set up constraints") }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraintEqualToAnchor(superview.topAnchor).active = true
        view.bottomAnchor.constraintEqualToAnchor(superview.bottomAnchor).active = true
    }
    
}
