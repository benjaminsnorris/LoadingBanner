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
    
    @IBInspectable open var successTint: UIColor = UIColor.green.withAlphaComponent(0.2) {
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
    
    
    // MARK: - Private enums
    
    fileprivate enum Status {
        case loading, error, success
    }
    
    
    // MARK: - Private properties
    
    fileprivate var status = Status.loading
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
        status = .loading
        loadingLabel.text = defaultText
        toggleSpinner(toShowing: true)
        showBanner()
    }
    
    open func showMessage(_ text: String?) {
        toggleError(nil)
        status = .loading
        loadingLabel.text = text
        toggleSpinner(toShowing: true)
        showBanner()
    }
    
    open func showSuccess(message: String?, for duration: Double = 2.0) {
        toggleError(nil)
        status = .success
        loadingLabel.text = message
        toggleSpinner(toShowing: false)
        showBanner()
        delay(duration) { 
            self.dismissBanner()
        }
    }
    
    open func showError(_ message: String?) {
        toggleError(message ?? "")
        status = .error
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
                    self.heightConstraint.constant = self.height
                } else {
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
        switch status {
        case .loading:
            visualEffectView.contentView.backgroundColor = backgroundTint
        case .error:
            visualEffectView.contentView.backgroundColor = errorTint
        case .success:
            visualEffectView.contentView.backgroundColor = successTint
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
    
    func toggleSpinner(toShowing: Bool) {
        if toShowing {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
    
    func showBanner() {
        showing = true
        toggleBanner()
    }
    
    func delay(_ delay: Double, _ closure: @escaping () -> ()) {
        let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: closure)
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
        
        loadingLabel.text = defaultText
        if #available(iOSApplicationExtension 10.0, *) {
            loadingLabel.adjustsFontForContentSizeCategory = true
        }
        loadingLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        loadingStackView.addArrangedSubview(loadingLabel)
        
        vibrancyView.contentView.addSubview(errorStackView)
        setupFullSize(errorStackView)
        
        errorStackView.addArrangedSubview(errorLabel)
        if #available(iOSApplicationExtension 10.0, *) {
            errorLabel.adjustsFontForContentSizeCategory = true
        }
        errorLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        errorLabel.textAlignment = .center
        
        let closeLabel = UILabel()
        closeLabel.text = "✕"
        closeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        closeLabel.textAlignment = .center
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
