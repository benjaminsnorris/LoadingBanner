/*
 |  _   ____   ____   _
 | ⎛ |‾|  ⚈ |-| ⚈  |‾| ⎞
 | ⎝ |  ‾‾‾‾| |‾‾‾‾  | ⎠
 |  ‾        ‾        ‾
 */

import UIKit

@IBDesignable public class LoadingBanner: UIView {

    // MARK: - Public properties
    
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
    
    @IBInspectable public var defaultText: String = "Loading…" {
        didSet {
            loadingLabel.text = defaultText
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
    private let loadingLabel = UILabel()
    private let errorStackView = UIStackView()
    private let errorLabel = UILabel()
    private var errorMessage: String?
    private var showing = false
    
    
    // MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    // MARK: - Lifecycle overrides
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        heightConstraint.constant = height
        layoutIfNeeded()
    }
    
    
    // MARK: - Public functions
    
    public func showLoading() {
        toggleError(nil)
        loadingLabel.text = defaultText
        showBanner()
    }
    
    public func showMessage(text: String?) {
        toggleError(nil)
        loadingLabel.text = text
        showBanner()
    }
    
    public func showError(message: String?) {
        toggleError(message ?? "")
        showBanner()
    }

    public func dismiss() {
        dismissBanner()
    }
    
}


// MARK: - Internal functions

extension LoadingBanner {
    
    func dismissBanner() {
        showing = false
        toggleBanner({
            self.errorMessage = nil
            self.loadingStackView.hidden = false
            self.errorStackView.hidden = true
        })
    }

}


// MARK: - Private functions

private extension LoadingBanner {
    
    func toggleBanner(completion: (() -> ())? = nil) {
        updateColors()
        UIView.animateWithDuration(0.0, animations: {
            // This is a hack to get the banner to start in the right place
            }) { finished in
                if self.showing {
                    self.spinner.startAnimating()
                    self.heightConstraint.constant = self.height
                } else {
                    self.spinner.stopAnimating()
                    self.heightConstraint.constant = 0.0
                }
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
    
    func toggleError(message: String?) {
        if let message = message {
            errorMessage = message
            errorLabel.text = message
            errorStackView.hidden = false
            loadingStackView.hidden = true
        } else {
            errorMessage = nil
            loadingStackView.hidden = false
            errorStackView.hidden = true
        }
    }
    
    func showBanner() {
        showing = true
        toggleBanner()
    }
    
    
    // MARK: - Initial setup
    
    func setupViews() {
        backgroundColor = nil
        
        heightConstraint = heightAnchor.constraintEqualToConstant(0.0)
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
        
        loadingLabel.text = defaultText
        loadingLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        loadingStackView.addArrangedSubview(loadingLabel)
        
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
