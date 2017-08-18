/*
 |  _   ____   ____   _
 | | |‾|  ⚈ |-| ⚈  |‾| |
 | | |  ‾‾‾‾| |‾‾‾‾  | |
 |  ‾        ‾        ‾
 */

import UIKit

public protocol LoadingBannerDelegate: class {
    func bannerTapped(_ banner: LoadingBanner)
}

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
            messageLabel.text = defaultText
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
    
    open var customButtonText: String? {
        didSet {
            if let text = customButtonText {
                fakeButton.text = text
            } else {
                fakeButton.text = defaultFakeButtonTitle
            }
        }
    }

    open weak var delegate: LoadingBannerDelegate?
    
    
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
    fileprivate let stackView = UIStackView()
    fileprivate let messageLabel = UILabel()
    fileprivate let fakeButton = UILabel()
    fileprivate var showing = false
    fileprivate let defaultFakeButtonTitle = "✕"
    fileprivate var timer: Timer?
    
    
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
    
    open func showLoading(customButtonText: String? = nil) {
        showBanner(with: .loading, message: defaultText, customButtonTitle: customButtonText)
    }
    
    open func showMessage(_ text: String?, customButtonText: String? = nil, for duration: TimeInterval? = nil) {
        showBanner(with: .loading, message: text, customButtonTitle: customButtonText)
        if let duration = duration {
            timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismissBanner), userInfo: nil, repeats: false)
        }
    }
    
    open func showSuccess(message: String?, customButtonText: String? = nil, for duration: TimeInterval = 2.0) {
        showBanner(with: .success, message: message, customButtonTitle: customButtonText)
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismissBanner), userInfo: nil, repeats: false)
    }
    
    open func showError(_ message: String?, customButtonText: String? = nil, for duration: TimeInterval? = nil) {
        showBanner(with: .error, message: message, customButtonTitle: customButtonText)
        if let duration = duration {
            timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismissBanner), userInfo: nil, repeats: false)
        }
    }

    open func dismiss() {
        dismissBanner()
    }
    
}


// MARK: - Internal functions

extension LoadingBanner {
    
    func bannerTapped() {
        if let delegate = delegate {
            delegate.bannerTapped(self)
        } else {
            dismissBanner()
        }
    }
    
    func dismissBanner() {
        showing = false
        toggleBanner()
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
    
    func toggleSpinner(toShowing: Bool) {
        if toShowing {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
    
    func showBanner(with status: Status, message: String?, customButtonTitle: String?) {
        timer?.invalidate()
        toggleSpinner(toShowing: status == .loading)
        messageLabel.text = message
        self.status = status
        customButtonText = customButtonTitle
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
        
        vibrancyView.contentView.addSubview(stackView)
        setupFullSize(stackView)
        stackView.centerXAnchor.constraint(equalTo: vibrancyView.centerXAnchor).isActive = true
        stackView.spacing = 4.0
        
        let leadingSpacer = UIView()
        stackView.addArrangedSubview(leadingSpacer)
        stackView.addArrangedSubview(spinner)
        
        messageLabel.text = defaultText
        if #available(iOSApplicationExtension 10.0, *) {
            messageLabel.adjustsFontForContentSizeCategory = true
        }
        messageLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        messageLabel.textAlignment = .center
        stackView.addArrangedSubview(messageLabel)
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let trailingSpacer = UIView()
        stackView.addArrangedSubview(trailingSpacer)
        
        fakeButton.text = defaultFakeButtonTitle
        fakeButton.font = UIFont.preferredFont(forTextStyle: .caption1)
        fakeButton.textAlignment = .center
        fakeButton.translatesAutoresizingMaskIntoConstraints = false
        fakeButton.widthAnchor.constraint(greaterThanOrEqualTo: fakeButton.heightAnchor, multiplier: 1.0).isActive = true
        fakeButton.setContentHuggingPriority(800, for: .horizontal)
        stackView.addArrangedSubview(fakeButton)
        
        let button = UIButton()
        addSubview(button)
        setupFullSize(button)
        button.addTarget(self, action: #selector(LoadingBanner.bannerTapped), for: .touchUpInside)
        
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
