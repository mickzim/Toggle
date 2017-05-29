import Foundation

enum ToggleState {
    case on
    case off
    case undecided
}

extension ToggleState {
    var cgColor: CGColor {
        switch self {
        case .undecided: return #colorLiteral(red: 0.8374213576, green: 0.8374213576, blue: 0.8374213576, alpha: 1).cgColor
        case .off: return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor
        case .on: return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor
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
    }

}

private extension Toggle {
    var xPositionOfToggle: CGFloat {
        let w = layer.bounds.width - toggleLayer.bounds.width
        switch toggleState {
        case .undecided: return w / 2
        case .off: return 0.5
        case .on: return w - 1.0
        }
    }

    var toggleImage: CGImage? {
        switch toggleState {
        case .undecided: return nil
        case .on: return onImage.cgImage
        case .off: return offImage.cgImage
        }
    }

    var toggledBackgroundColor: UIColor {
        switch toggleState {
        case .undecided: return #colorLiteral(red: 0.8374213576, green: 0.8374213576, blue: 0.8374213576, alpha: 1)
        case .off: return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case .on: return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
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

        let combinedImage = UIImage.combine(images: onImage, offImage, width: layer.bounds.width)
        backgroundLayer.contents = combinedImage.cgImage
        backgroundLayer.contentsGravity = kCAGravityCenter
        backgroundLayer.addSublayer(toggleLayer)

    }

}

private extension CGPoint {
    func insetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

private class RoundedLayer: CALayer {
    override func layoutSublayers() {
        super.layoutSublayers()
        cornerRadius = bounds.size.height / 2
    }
}

