import Foundation
import UIKit

enum ToggleState {
    case on
    case off
    case undecided
}

extension ToggleState {
    var gradientState: (on: Bool, off: Bool) {
        switch self {
        case .undecided: return (false, false)
        case .off: return (true, true)
        case .on: return (true, true)
        }
    }
}

@IBDesignable open class Toggle: UIControl {

    @IBInspectable public var borderWidth: CGFloat = 1.5
    @IBInspectable public var borderColor: UIColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

    @IBInspectable public var offStateColor: UIColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    @IBInspectable public var onStateColor: UIColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)

    @IBInspectable public var selectionState: Bool? = false

    fileprivate var toggleState: ToggleState {
        guard let selectionState = selectionState else { return .undecided }
        return selectionState ? .on : .off
    }

    @IBInspectable public var onImage: UIImage?
    @IBInspectable public var offImage: UIImage?

    fileprivate let backgroundLayer = RoundedLayer()
    fileprivate let toggleLayer = RoundedLayer()
    fileprivate let offGradient = RoundedGradientLayer()
    fileprivate let onGradient = RoundedGradientLayer()

    fileprivate var bgColor: UIColor {
        return backgroundColor ?? UIColor.lightGray
    }

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: 77, height: 33)
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

        toggleLayer.position = CGPoint(x: xPositionOfToggle, y: 1)
        backgroundLayer.backgroundColor = cgBackgroundColor

        backgroundLayer.contents = nil
        toggleLayer.contents = toggleImage

        backgroundLayer.borderColor = cgBorderColor
        toggleGradientLayers()
    }

    open override func sendActions(for controlEvents: UIControlEvents) {
        super.sendActions(for: controlEvents)
        print("sendActions: \(controlEvents)")
    }

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        print("beginTracking: \(String(describing: touch)) \(String(describing: event))")
        let startTouch: CGFloat = touch.location(in: self).x
        stretchToggleButton(x: startTouch)
        return true
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        print("continueTracking: \(String(describing: touch)) \(String(describing: event))")
        return true
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        stopStretchingToggleButton()
        let endTouch: CGFloat = touch?.location(in: self).x ?? self.bounds.width / 2
        switchState(x: endTouch)
        print("endTracking: \(String(describing: touch)) \(String(describing: event))")
    }

    open override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        print("cancelTracking: \(String(describing: event))")
    }
}

private extension Toggle {
    var cgBackgroundColor: CGColor {
        switch toggleState {
        case .undecided: return UIColor.clear.cgColor
        case .off: return offStateColor.cgColor
        case .on: return onStateColor.cgColor
        }
    }

    var cgBorderColor: CGColor {
        switch toggleState {
        case .undecided: return borderColor.cgColor
        case .off: return offStateColor.cgColor
        case .on: return onStateColor.cgColor
        }
    }

    var xPositionOfToggle: CGFloat {
        return xPosition(forState: toggleState)
    }

    var toggleImage: CGImage? {
        switch toggleState {
        case .undecided: return nil
        case .on: return onImage?.cgImage
        case .off: return offImage?.cgImage
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
        case .off: return 2
        case .on: return w - 2
        }
    }

    func setup() {
        isEnabled = true
        setupLayers()
    }

    func stretchToggleButton(x startTouch: CGFloat) {
        let w = layer.bounds.size.height
        let bounds = CGRect(origin: backgroundLayer.bounds.origin, size: CGSize(width: w, height: w)).insetBy(dx: -borderWidth, dy: borderWidth)
        toggleLayer.bounds = bounds
        let x = xAnchorPoint(x: startTouch)
        toggleLayer.anchorPoint = CGPoint(x: x, y: -0.02)
    }

    func xAnchorPoint(x startTouch: CGFloat) -> CGFloat {
        switch selectionState {
        case .some(true): return 0.0
        case .some(false) : return 0.0
        case _: return startTouch >= bounds.width / 2 ? -0.10 : 0.10
        }
    }

    func stopStretchingToggleButton() {
        let w = layer.bounds.size.height
        let bounds = CGRect(origin: backgroundLayer.bounds.origin, size: CGSize(width: w, height: w)).insetBy(dx: borderWidth, dy: borderWidth)
        toggleLayer.bounds = bounds
        toggleLayer.anchorPoint = CGPoint(x: -0.00, y: -0.02)
    }

    func switchState(x endTouch: CGFloat) {
        selectionState = nextSelectionState(x: endTouch)
        self.setNeedsLayout()
    }

    func nextSelectionState(x endTouch: CGFloat) -> Bool? {
        switch selectionState {
        case .some(true): return nil
        case .some(false) : return nil
        default: return endTouch >= bounds.width / 2
        }
    }

    func setupLayers() {
        backgroundLayer.bounds = layer.bounds
        backgroundLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundLayer.borderWidth = borderWidth
        backgroundLayer.borderColor = borderColor.cgColor
        backgroundLayer.backgroundColor = cgBorderColor

        layer.addSublayer(backgroundLayer)

        let w = layer.bounds.size.height

        let bounds = CGRect(origin: backgroundLayer.bounds.origin, size: CGSize(width: w, height: w)).insetBy(dx: borderWidth, dy: borderWidth)
        toggleLayer.bounds = bounds
        toggleLayer.anchorPoint = CGPoint(x: -0.00, y: -0.02)
        toggleLayer.borderColor = borderColor.cgColor
        toggleLayer.backgroundColor = UIColor.white.cgColor

        toggleLayer.shadowOpacity = 0.5
        toggleLayer.shadowRadius = 1
        toggleLayer.shadowColor = UIColor.gray.cgColor
        toggleLayer.shadowOffset = CGSize(width: 0, height:  3)


//        let shadowLayer = CAShapeLayer()
//        shadowLayer.frame = toggleLayer.bounds
//        shadowLayer.path = UIBezierPath(roundedRect: toggleLayer.bounds, cornerRadius: toggleLayer.bounds.size.height / 2).cgPath
//        shadowLayer.shadowOpacity = 0.5
//        shadowLayer.shadowRadius = 5
//        shadowLayer.masksToBounds = false
//        shadowLayer.shadowOffset = .zero

//        offGradient.bounds = backgroundLayer.bounds.left(portion: 0.66)
//        offGradient.anchorPoint = CGPoint(x: 0, y: 0)
//        offGradient.colors = [ToggleState.undecided.cgColor, ToggleState.off.cgColor]
//        offGradient.startPoint = CGPoint(x: 0.75, y: 0)
//        offGradient.endPoint = CGPoint(x: 2, y: 0)
//        offGradient.position = CGPoint(x: backgroundLayer.bounds.width - offGradient.bounds.width, y: 0.0)
//
//        onGradient.bounds = backgroundLayer.bounds.left(portion: 0.66)
//        onGradient.anchorPoint = CGPoint(x: 0, y: 0)
//        onGradient.colors = [ToggleState.on.cgColor, ToggleState.undecided.cgColor]
//        onGradient.startPoint = CGPoint(x: -1, y: 0)
//        onGradient.endPoint = CGPoint(x: 0.25, y: 0)
//        onGradient.position = CGPoint(x: 0.0, y: 0.0)
//
//        backgroundLayer.addSublayer(offGradient)
//        backgroundLayer.addSublayer(onGradient)

        layer.addSublayer(toggleLayer)
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

