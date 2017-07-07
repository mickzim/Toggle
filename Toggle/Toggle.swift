import Foundation

enum ToggleState {
    case on
    case off
    case undecided
}

extension ToggleState {
    var color: UIColor {
        switch self {
        case .undecided: return #colorLiteral(red: 0.8374213576, green: 0.8374213576, blue: 0.8374213576, alpha: 1)
        case .off: return UIColor.red
        case .on: return UIColor.green
        }
    }
    var cgColor: CGColor {
        return color.cgColor
    }

    var gradientState: (on: Bool, off: Bool) {
        switch self {
        case .undecided: return (false, false)
        case .off: return (true, true)
        case .on: return (true, true)
        }
    }
}

@IBDesignable open class Toggle: UIControl {

    @IBInspectable public var borderWidth: CGFloat = 0.1
    @IBInspectable public var borderColor: UIColor = UIColor.darkGray

    @IBInspectable public var offStateColor: UIColor = UIColor.red
    @IBInspectable public var onStateColor: UIColor = UIColor.green

    @IBInspectable public var selectionState: Bool? = nil

    fileprivate var toggleState: ToggleState {
        guard let selectionState = selectionState else { return .undecided }
        return selectionState ? .on : .off
    }

    fileprivate var onImage: UIImage!
    fileprivate var offImage: UIImage!
//    fileprivate let onImage = #imageLiteral(resourceName: "toggle-on")
//    fileprivate let offImage = #imageLiteral(resourceName: "toggle-off")

    fileprivate let backgroundLayer = RoundedLayer()
    fileprivate let toggleLayer = RoundedLayer()
    fileprivate let offGradient = RoundedGradientLayer()
    fileprivate let onGradient = RoundedGradientLayer()

    fileprivate var bgColor: UIColor {
        return backgroundColor ?? UIColor.lightGray
    }

    required public init?(coder:NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame);
        setup()
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        setupLayers()
    }

    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard layer == self.layer else { return }

        toggleLayer.position = CGPoint(x: xPositionOfToggle, y: 0.5)
        backgroundLayer.backgroundColor = toggleState.cgColor

        backgroundLayer.contents = nil
        toggleLayer.contents = toggleImage

        toggleGradientLayers()
    }

}

private extension Toggle {
    var xPositionOfToggle: CGFloat {
        return xPosition(forState: toggleState)
    }

    var toggleImage: CGImage? {
        switch toggleState {
        case .undecided: return nil
        case .on: return onImage.cgImage
        case .off: return offImage.cgImage
        }
    }

    func toggleGradientLayers() {
        let gradientState = toggleState.gradientState
        onGradient.isHidden = gradientState.on
        offGradient.isHidden = gradientState.off
    }

    func xPosition(forState toggleState: ToggleState) -> CGFloat {
        let w = layer.bounds.width - toggleLayer.bounds.width
        switch toggleState {
        case .undecided: return w / 2
        case .off: return 0.5
        case .on: return w - 1.0
        }
    }

    func setup() {
        isEnabled = true
        setupLayers()
    }


    func setupLayers() {
        let bundle = Bundle(identifier: "de.mobile.Toggle")
        onImage = UIImage(named: "toggle-on", in: bundle, compatibleWith: nil)!
        offImage = UIImage(named: "toggle-off", in: bundle, compatibleWith:  nil)!

        backgroundLayer.bounds = layer.bounds
        backgroundLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundLayer.borderWidth = borderWidth
        backgroundLayer.borderColor = borderColor.cgColor
        backgroundLayer.backgroundColor = toggleState.cgColor

        layer.addSublayer(backgroundLayer)

        let w = layer.bounds.size.height

        toggleLayer.bounds = CGRect(origin: backgroundLayer.bounds.origin.insetBy(dx: 0.5, dy: 0.5), size: CGSize(width: w, height: w)).insetBy(dx: 0.5, dy: 0.5)
        toggleLayer.anchorPoint = CGPoint(x: 0, y: 0)
        toggleLayer.borderWidth = 0.1
        toggleLayer.backgroundColor = UIColor.white.cgColor


        offGradient.bounds = backgroundLayer.bounds.left(portion: 0.66)
        offGradient.anchorPoint = CGPoint(x: 0, y: 0)
        offGradient.colors = [ToggleState.undecided.cgColor, ToggleState.off.cgColor]
        offGradient.startPoint = CGPoint(x: 0.5, y: 0)
        offGradient.endPoint = CGPoint(x: 2, y: 0)
        offGradient.position = CGPoint(x: backgroundLayer.bounds.width - offGradient.bounds.width, y: 0.0)

        onGradient.bounds = backgroundLayer.bounds.left(portion: 0.66)
        onGradient.anchorPoint = CGPoint(x: 0, y: 0)
        onGradient.colors = [ToggleState.on.cgColor, ToggleState.undecided.cgColor]
        onGradient.startPoint = CGPoint(x: -1, y: 0)
        onGradient.endPoint = CGPoint(x: 0.5, y: 0)
        onGradient.position = CGPoint(x: 0.0, y: 0.0)

        backgroundLayer.addSublayer(offGradient)
        backgroundLayer.addSublayer(onGradient)

        backgroundLayer.addSublayer(toggleLayer)

    }

}

extension CGPoint {
    func insetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

class RoundedLayer: CALayer {
    override func layoutSublayers() {
        super.layoutSublayers()
        cornerRadius = bounds.size.height / 2
    }
}

class RoundedGradientLayer: CAGradientLayer {
    override func layoutSublayers() {
        super.layoutSublayers()
        cornerRadius = bounds.size.height / 2
    }
}

extension CGRect {
    func left(portion: CGFloat) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width * portion, height: size.height)
    }
    func right(portion: CGFloat) -> CGRect {
        return CGRect(x: origin.x + (size.width * portion), y: origin.y, width: size.width * portion, height: size.height)
    }

}

