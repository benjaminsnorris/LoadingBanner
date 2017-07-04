/*
 |  _   ____   ____   _
 | | |‾|  ⚈ |-| ⚈  |‾| |
 | | |  ‾‾‾‾| |‾‾‾‾  | |
 |  ‾        ‾        ‾
 */

import UIKit

@IBDesignable open class LoadingBanner: UIView {

    // MARK: - Public properties
    
    @IBInspectable open var backgroundTint: UIColor = UIColor.blue.withAlphaComponent(0.2) {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable open var errorTint: UIColor = UIColor.red.withAlphaComponent(0.2) {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable open var height: CGFloat = 24.0 {
        didSet {
            heightConstraint.constant = height
            layoutIfNeeded()
        }
    }
    
    @IBInspectable open var defaultText: String = "Loading…" {
        didSet {
            loadingLabel.text = defaultText
        }
    }
    
    open var effectStyle: UIBlurEffectStyle = .extraLight {
        didSet {
            let effect = UIBlurEffect(style: effectStyle)
            visualEffectView.effect = effect
            let vibrancyEffect = UIVibrancyEffect(blurEffect: effect)
            vibrancyView.effect = vibrancyEffect
        }
    }
    
    
    // MARK: - Internal properties
    
    var visualEffectView: UIVisualEffectView = {
        let lightStyle = UIBlurEffectStyle.extraLight
        let lightBlurEffect = UIBlurEffect(style: lightStyle)
        return UIVisualEffectView(effect: lightBlurEffect)
    }()
    var vibrancyView: UIVisualEffectView!
    
    
    // MARK: - Private properties
    
    
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate let loadingStackView = UIStackView()
    fileprivate let loadingLabel = UILabel()
    fileprivate let errorStackView = UIStackView()
    fileprivate let errorLabel = UILabel()
    fileprivate var errorMessage: String?
    fileprivate var showing = false
    
    
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
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        heightConstraint.constant = height
        layoutIfNeeded()
    }
    
    
    // MARK: - Public functions
    
    open func showLoading() {
        toggleError(nil)
        loadingLabel.text = defaultText
        showBanner()
    }
    
    open func showMessage(_ text: String?) {
        toggleError(nil)
        loadingLabel.text = text
        showBanner()
    }
    
    open func showError(_ message: String?) {
        toggleError(message ?? "")
        showBanner()
    }

    open func dismiss() {
        dismissBanner()
    }
    
}


// MARK: - Internal functions

extension LoadingBanner {
    
    func dismissBanner() {
        showing = false
        toggleBanner({
            self.errorMessage = nil
            self.loadingStackView.isHidden = false
            self.errorStackView.isHidden = true
        })
    }

}


// MARK: - Private functions

private extension LoadingBanner {
    
    func toggleBanner(_ completion: (() -> ())? = nil) {
        updateColors()
        UIView.animate(withDuration: 0.0, animations: {
            // This is a hack to get the banner to start in the right place
            }, completion: { finished in
                if self.showing {
                    self.spinner.startAnimating()
                    self.heightConstraint.constant = self.height
                } else {
                    self.spinner.stopAnimating()
                    self.heightConstraint.constant = 0.0
                }
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
                    self.layoutIfNeeded()
                }) { complete in
                    completion?()
                }
        }) 
    }
    
    func updateColors() {
        if let _ = errorMessage {
            visualEffectView.contentView.backgroundColor = errorTint
        } else {
            visualEffectView.contentView.backgroundColor = backgroundTint
        }
    }
    
    func toggleError(_ message: String?) {
        if let message = message {
            errorMessage = message
            errorLabel.text = message
            errorStackView.isHidden = false
            loadingStackView.isHidden = true
        } else {
            errorMessage = nil
            loadingStackView.isHidden = false
            errorStackView.isHidden = true
        }
    }
    
    func showBanner() {
        showing = true
        toggleBanner()
    }
    
    
    // MARK: - Initial setup
    
    func setupViews() {
        backgroundColor = nil
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 0.0)
        heightConstraint.isActive = true
        
        addSubview(visualEffectView)
        setupFullSize(visualEffectView)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: visualEffectView.effect as! UIBlurEffect)
        vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        visualEffectView.contentView.addSubview(vibrancyView)
        setupFullSize(vibrancyView)
        
        vibrancyView.contentView.addSubview(loadingStackView)
        setupFullHeight(loadingStackView)
        loadingStackView.centerXAnchor.constraint(equalTo: vibrancyView.centerXAnchor).isActive = true
        loadingStackView.spacing = 4.0
        
        loadingStackView.addArrangedSubview(spinner)
        spinner.hidesWhenStopped = false
        
        loadingLabel.text = defaultText
        loadingLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        loadingStackView.addArrangedSubview(loadingLabel)
        
        vibrancyView.contentView.addSubview(errorStackView)
        setupFullSize(errorStackView)
        
        errorStackView.addArrangedSubview(errorLabel)
        errorLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        errorLabel.textAlignment = .center
        
        let closeLabel = UILabel()
        closeLabel.text = "✕"
        closeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        closeLabel.translatesAutoresizingMaskIntoConstraints = false
        closeLabel.widthAnchor.constraint(equalTo: closeLabel.heightAnchor).isActive = true
        errorStackView.addArrangedSubview(closeLabel)
        
        errorStackView.isHidden = true
        
        let button = UIButton()
        addSubview(button)
        setupFullSize(button)
        button.addTarget(self, action: #selector(LoadingBanner.dismissBanner), for: .touchUpInside)
        
        updateColors()
    }
    
    func setupFullSize(_ view: UIView) {
        guard let superview = view.superview else { fatalError("Must have a superview to set up constraints") }
        setupFullHeight(view)
        view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
}
    
    func setupFullHeight(_ view: UIView) {
        guard let superview = view.superview else { fatalError("Must have a superview to set up constraints") }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
}
