/*
 |  _   ____   ____   _
 | | |‾|  ⚈ |-| ⚈  |‾| |
 | | |  ‾‾‾‾| |‾‾‾‾  | |
 |  ‾        ‾        ‾
 */

import UIKit

public protocol LoadingBannerDelegate: class {
    func bannerTapped(_ banner: LoadingBanner)
    func bannerDismissed(_ banner: LoadingBanner)
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
            updateHeight(animated: false)
        }
    }
    
    @IBInspectable open var defaultText: String = "Loading…" {
        didSet {
            messageLabel.text = defaultText
        }
    }
    
    @IBInspectable open var startVisible: Bool = true {
        didSet {
            updateHeight(animated: false)
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
    fileprivate var timerAmount: TimeInterval?
    
    
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
        timerAmount = duration
        if let duration = duration {
            timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismissBanner), userInfo: nil, repeats: false)
        }
    }
    
    open func showSuccess(message: String?, customButtonText: String? = nil, for duration: TimeInterval = 2.0) {
        showBanner(with: .success, message: message, customButtonTitle: customButtonText)
        timerAmount = duration
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismissBanner), userInfo: nil, repeats: false)
    }
    
    open func showError(_ message: String?, customButtonText: String? = nil, for duration: TimeInterval? = nil) {
        showBanner(with: .error, message: message, customButtonTitle: customButtonText)
        timerAmount = duration
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
    
    @objc func bannerTapped() {
        buttonTouchEnded()
        if let delegate = delegate {
            delegate.bannerTapped(self)
        } else {
            dismissBanner()
        }
    }
    
    @objc func dismissBanner() {
        showing = false
        toggleBanner()
        delegate?.bannerDismissed(self)
    }
    
    @objc func buttonTouchBegan() {
        toggleViews(highlighted: true)
    }
    
    @objc func buttonTouchEnded() {
        toggleViews(highlighted: false)
    }
    
    func toggleViews(highlighted: Bool) {
        let alpha: CGFloat = highlighted ? 0.2 : 1.0
        stackView.alpha = alpha
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let maxDistance: CGFloat = 100.0
        switch recognizer.state {
        case .began:
            timer?.invalidate()
            transform = .identity
            buttonTouchEnded()
        case .cancelled, .failed:
            transform = .identity
        case .changed:
            let translation = recognizer.translation(in: superview!)
            var adjustedY = min(translation.y, maxDistance)
            if translation.y > maxDistance {
                let extra = translation.y - maxDistance
                let multiplierExtra = maxDistance - ((maxDistance / (maxDistance + extra)) * extra)
                let multiplier = multiplierExtra / maxDistance
                adjustedY += multiplier * extra
            }
            transform = CGAffineTransform(translationX: 0.0, y: adjustedY)
        case .ended:
            buttonTouchEnded()
            showing = false
            let translation = recognizer.translation(in: superview!)
            let velocity = recognizer.velocity(in: superview!)
            let adjustedY = min(translation.y, maxDistance)
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: (adjustedY / maxDistance) * (maxDistance * 0.4), options: [], animations: {
                self.transform = .identity
            }) { _ in
                if let timerAmount = self.timerAmount {
                    self.timer = Timer.scheduledTimer(timeInterval: timerAmount, target: self, selector: #selector(self.dismissBanner), userInfo: nil, repeats: false)
                }
            }
            if translation.y < 0 || velocity.y < -200 {
                self.toggleBanner()
            }
        case .possible:
            break
        }
    }

}


// MARK: - Private functions

private extension LoadingBanner {
    
    func toggleBanner(_ completion: (() -> ())? = nil) {
        updateColors()
        UIView.animate(withDuration: 0.0, animations: {
            // This is a hack to get the banner to start in the right place
            }, completion: { finished in
                self.updateHeight(animated: true, completion: completion)
        })
    }
    
    func updateHeight(animated: Bool, completion: (() -> Void)? = nil) {
        if self.showing {
            self.heightConstraint.constant = self.height
        } else {
            self.heightConstraint.constant = 0.0
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
                self.layoutIfNeeded()
            }) { complete in
                completion?()
            }
        } else {
            layoutIfNeeded()
            completion?()
        }
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
        timer = nil
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
        
        let middleSpacer = UIView()
        stackView.addArrangedSubview(middleSpacer)
        
        fakeButton.text = defaultFakeButtonTitle
        fakeButton.font = UIFont.preferredFont(forTextStyle: .caption1)
        fakeButton.textAlignment = .center
        fakeButton.translatesAutoresizingMaskIntoConstraints = false
        fakeButton.setContentHuggingPriority(UILayoutPriority(rawValue: 800), for: .horizontal)
        fakeButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        stackView.addArrangedSubview(fakeButton)
        
        let trailingSpacer = UIView()
        trailingSpacer.widthAnchor.constraint(equalToConstant: 8.0).isActive = true
        stackView.addArrangedSubview(trailingSpacer)
        
        let button = UIButton()
        addSubview(button)
        setupFullSize(button)
        button.addTarget(self, action: #selector(LoadingBanner.bannerTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchBegan), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchEnded), for: .touchDragExit)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panRecognizer)
        
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
