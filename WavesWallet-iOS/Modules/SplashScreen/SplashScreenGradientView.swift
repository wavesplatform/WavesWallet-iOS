import UIKit

private struct Constants {
    static let smallTriangles: CGFloat = 74
    static let largeTriangles: CGFloat = 80

    static let firstScaleTrianglesDuration: TimeInterval = 0.68
    static let shiftGradientDuration: TimeInterval = 1.6
    static let splashDuration: TimeInterval = 0.44
    static let splashDelay: TimeInterval = 1.84

    static let gradientStartPoint = CGPoint(x: 0, y: 0)
    static let gradientEndPoint = CGPoint(x: 0.25, y: 1.16)
    static let gradientAnimationEndPoint = CGPoint(x: 0.25, y: 0.7)
}

protocol SplashScreenGradientViewDelegate: AnyObject {
    func splashScreenCompleted() -> Void
}

final class SplashScreenGradientView: UIView {
    private var whiteCanvas: UIView = UIView()
    @IBOutlet private var titleLabel: UILabel!

    private let triangleMaskLayer = CAShapeLayer()
    private let tooptriangleMaskLayer = CAShapeLayer()

    private var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.882, green: 0.294, blue: 0.318, alpha: 1).cgColor,
            UIColor(red: 0.353, green: 0.506, blue: 0.918, alpha: 1).cgColor,
        ]
        layer.locations = [0, 1]
        layer.startPoint = Constants.gradientStartPoint
        layer.endPoint = Constants.gradientEndPoint

        return layer
    }()

    weak var delegate: SplashScreenGradientViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupElements()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        triangleMaskLayer.frame = bounds

        triangleMaskLayer.path = triangleMaskPath(maskFrame: smallTriangleFrame(),
                                                  bounds: bounds).cgPath

        tooptriangleMaskLayer
            .path = triangleMaskPath(maskFrame: smallTriangleFrame(),
                                     bounds: bounds, inverse: false).cgPath
    }

    private func setupElements() {
        layer.addSublayer(gradientLayer)

        triangleMaskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        triangleMaskLayer.fillColor = UIColor.white.cgColor

        tooptriangleMaskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        tooptriangleMaskLayer.fillColor = UIColor.white.cgColor

        addSubview(whiteCanvas)
        whiteCanvas.translatesAutoresizingMaskIntoConstraints = false
        whiteCanvas.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        whiteCanvas.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        whiteCanvas.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        whiteCanvas.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true

        whiteCanvas.backgroundColor = .white
        whiteCanvas.isUserInteractionEnabled = false
        whiteCanvas.layer.mask = triangleMaskLayer
        gradientLayer.mask = tooptriangleMaskLayer
    }

    func runAnimations() {
        runScaleAnimation(to: triangleMaskLayer, duration: Constants.firstScaleTrianglesDuration, delay: 0.1)
        runGradientAnimation(layer: gradientLayer, duration: Constants.shiftGradientDuration, delay: 0.1)

        runSplashAnimation(maskLayer: triangleMaskLayer, duration: Constants.splashDuration, delay: Constants.splashDelay)
        runSplashAnimation(maskLayer: triangleMaskLayer, duration: Constants.splashDuration, delay: Constants.splashDelay)

        runSplashAnimation(maskLayer: tooptriangleMaskLayer, duration: Constants.splashDuration,
                           delay: Constants.splashDelay, inverseMask: false)

        runAphaAnimation(layer: titleLabel.layer, duration: Constants.splashDuration, delay: Constants.splashDelay)
        
        runAphaAnimation(layer: whiteCanvas.layer, duration: Constants.splashDuration, delay: Constants.splashDelay)
    }
}

// MARK: Animations

private extension SplashScreenGradientView {
    private func runAphaAnimation(layer: CALayer,
                                  duration: TimeInterval,
                                  delay: CFTimeInterval = 0) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.beginTime = CACurrentMediaTime() + delay  
        animation.duration = duration
        animation.toValue = 0
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "aplhaChange")
    }

    private func runGradientAnimation(layer: CAGradientLayer, duration: TimeInterval, delay: CFTimeInterval = 0,
                                      completionBlock: (() -> Void)? = nil) {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "endPoint")
        gradientChangeAnimation.beginTime = CACurrentMediaTime() + delay
        gradientChangeAnimation.duration = duration
        gradientChangeAnimation.toValue = Constants.gradientAnimationEndPoint
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false

        CATransaction.begin()
        layer.add(gradientChangeAnimation, forKey: "colorChange")
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock(completionBlock)
        CATransaction.commit()
    }

    private func runScaleAnimation(to layer: CAShapeLayer, duration: TimeInterval, delay: CFTimeInterval = 0) {
        let paths = [triangleMaskPath(maskFrame: smallTriangleFrame(),
                                      bounds: bounds),
                     triangleMaskPath(maskFrame: largeTriangleFrame(),
                                      bounds: bounds)]
            .map { $0.cgPath }

        let animation = CAKeyframeAnimation(keyPath: "path")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
        animation.keyTimes = [0.0, 1.0]

        animation.values = paths
        animation.calculationMode = .cubic
        animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards

        layer.add(animation, forKey: "scale_path")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.commit()
    }

    private func runSplashAnimation(maskLayer: CAShapeLayer, duration: TimeInterval,
                                    delay: CFTimeInterval = 0,
                                    inverseMask: Bool = true) {
        let maskFrame = largeTriangleFrame()

        let steps: [CGFloat] = [0.0, 1.0]

        let paths = steps.map { step -> UIBezierPath in
            trianglesMaskPathByStep(maskFrame: maskFrame, bounds: bounds, step: step, inverse: inverseMask)
        }
        .map { $0.cgPath }

        let animation = CAKeyframeAnimation(keyPath: "path")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
        animation.keyTimes = [0.0, 1.0]

        animation.values = paths
        animation.calculationMode = .cubic
        animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.delegate = self

        maskLayer.add(animation, forKey: "runSplash")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.commit()
    }
}

extension SplashScreenGradientView: CAAnimationDelegate {
 
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
     
        if anim == tooptriangleMaskLayer.animation(forKey: "runSplash") {
            self.delegate?.splashScreenCompleted()
        }
    }
}

// MARK: Math

private extension SplashScreenGradientView {
    private func triangleFrame(size: CGFloat) -> CGRect {
        return CGRect(x: (bounds.width - size) * 0.5,
                      y: (bounds.height - size) * 0.5,
                      width: size,
                      height: size)
    }

    private func largeTriangleFrame() -> CGRect {
        return triangleFrame(size: Constants.largeTriangles)
    }

    private func smallTriangleFrame() -> CGRect {
        return triangleFrame(size: Constants.smallTriangles)
    }

    private func createTrianglePath(bounds: CGRect, frame: CGRect, angle: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath(rect: bounds)

        // Делаем два треугольника
        path.addTriangleTop(frame: frame, angle: angle)
        path.addTriangleBottom(frame: frame, angle: angle)

        return path
    }

    private func trianglesMaskPathByStep(maskFrame: CGRect, bounds: CGRect, step: CGFloat,
                                         inverse: Bool = true) -> UIBezierPath {
        // Высчитывем во сколько раз надо увеличить треугольники
        // 0.4 - берется почти средняя ширина треугольника
        let coef: CGFloat = bounds.height / (maskFrame.width * 0.4)

        // нельзя уменьшать треугольники меньше своего размера
        let sizeScale: CGFloat = max(1, coef * step)

        let width = maskFrame.width * sizeScale
        let height = maskFrame.height * sizeScale

        // Высчитываем финальную центральную точку треугольников
        let xFinal = bounds.width - (maskFrame.width * coef * 0.5)
        let yFinal = -maskFrame.height * coef * 0.5

        var newPoint = maskFrame.origin

        // Высчитываем новую позици относительно шага
        newPoint.x = newPoint.x + (xFinal - newPoint.x) * step
        newPoint.y = newPoint.y + (yFinal - newPoint.y) * step

        // высчитыаем новый угол относительно шага
        let angle: CGFloat = (.pi / 4) * step

        var frame = CGRect.zero
        frame.size = CGSize(width: width, height: height)
        frame.origin = newPoint

        let path = createTrianglePath(bounds: bounds, frame: frame, angle: angle)

        if inverse {
            path.append(UIBezierPath(rect: bounds))
        }

        return path
    }

    private func triangleMaskPath(maskFrame: CGRect, bounds: CGRect, inverse: Bool = true) -> UIBezierPath {
        let path = createTrianglePath(bounds: bounds, frame: maskFrame, angle: 0)
        if inverse {
            path.append(UIBezierPath(rect: bounds))
        }
        return path
    }
}

private extension CGPoint {
    // умножаем вектор на угол
    // https://en.wikipedia.org/wiki/Rotation_matrix
    func setAngle(angle: CGFloat) -> CGPoint {
        return .init(x: x * cos(angle) - y * sin(angle), y: x * sin(angle) + y * cos(angle))
    }

    // Вычитание ввекторов
    func sub(point: CGPoint) -> CGPoint {
        return .init(x: x - point.x, y: y - point.y)
    }

    // сложение ввекторов
    func add(point: CGPoint) -> CGPoint {
        return .init(x: x + point.x, y: y + point.y)
    }

    // растояние векторов
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}

private extension UIBezierPath {
    func addTriangleTop(frame: CGRect, angle: CGFloat) {
        let mid = CGPoint(x: frame.midX, y: frame.midY)

        let pointFirst = CGPoint(x: frame.minX, y: frame.minY)
            .sub(point: mid)
            .setAngle(angle: angle)
            .add(point: mid)

        let pointSecond = CGPoint(x: frame.maxX, y: frame.minY)
            .sub(point: mid)
            .setAngle(angle: angle)
            .add(point: mid)

        let pointThird = CGPoint(x: frame.midX, y: frame.midY)
            .sub(point: mid)
            .setAngle(angle: angle)
            .add(point: mid)

        move(to: pointFirst)
        addLine(to: pointSecond)
        addLine(to: pointThird)
        close()
    }

    func addTriangleBottom(frame: CGRect, angle: CGFloat) {
        let mid = CGPoint(x: frame.midX, y: frame.midY)

        // перед тем как менять угол, нужно отнять центральную точку
        let pointFirst = CGPoint(x: frame.minX, y: frame.maxY)
            .sub(point: mid)
            .setAngle(angle: angle)
            .add(point: mid)

        let pointSecond = CGPoint(x: frame.maxX, y: frame.maxY)
            .sub(point: mid)
            .setAngle(angle: angle)
            .add(point: mid)

        let pointThird = CGPoint(x: frame.midX, y: frame.midY)
            .sub(point: mid)
            .setAngle(angle: angle)
            .add(point: mid)

        move(to: pointFirst)
        addLine(to: pointSecond)
        addLine(to: pointThird)
        close()
    }
}
