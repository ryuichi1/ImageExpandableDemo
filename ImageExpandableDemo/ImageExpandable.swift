import UIKit

/// 画像を拡大操作するプロトコル
@objc public protocol ImageExpandable {
    var isImageExpanded: Bool { get set }
    var currentExpandedScale: CGFloat { get set }
    var expandedImageView: UIImageView? { get set }
    
    var expandedImage: UIImage { get }
    var expandedImageViewDefaultFrame: CGRect { get }
    
    @objc func doubleTappedAction(_ sender: UIGestureRecognizer)
    @objc func panAction(_ sender: UIPanGestureRecognizer)
    @objc func pinchAction(_ sender: UIPinchGestureRecognizer)
}

public extension ImageExpandable where Self: UIViewController {
    func setImageExpandedGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTappedAction))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        self.view.addGestureRecognizer(panGesture)
        
        let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction))
        self.view.addGestureRecognizer(pinchGetsture)
    }
    
    func imageExpanded(doubleTappedAction gesture: UIGestureRecognizer) {
        if !isImageExpanded {
            addExpandedImageView()
            guard let imageView = expandedImageView else { return }
            
            // ダブルタップでは現在のスケールの1.5倍にする
            currentExpandedScale = 1.5
            let transform = CGAffineTransform(scaleX: currentExpandedScale, y: currentExpandedScale)
            UIView.animate(withDuration: 0.3) {
                imageView.transform = transform
            }
        } else {
            // 拡大中のダブルタップは元のサイズまで戻して消す
            removeExpandedImageView()
        }
    }
    
    func imageExpanded(panAction gesture: UIPanGestureRecognizer) {
        guard let imageView = expandedImageView else { return }
        
        // Pan操作のジェスチャー分だけ拡大画像を移動させる
        let point: CGPoint = gesture.translation(in: self.view)
        let movedPoint = CGPoint(
            x: imageView.center.x + point.x,
            y: imageView.center.y + point.y
        )
        imageView.center = movedPoint
        gesture.setTranslation(.zero, in: self.view)
    }
    
    func imageExpanded(pinchAction gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // 1~3倍までの拡大を受け付ける
            var changedScale = currentExpandedScale
            changedScale += (gesture.scale - 1) / 10
            if changedScale <= 1.0 {
                changedScale = 1.0
            } else if changedScale > 3.0 {
                changedScale = 3.0
            }
            
            // パン操作後のスケールが1.0以上かつ拡大してない場合はImageViewを追加する
            if changedScale > 1.0, !isImageExpanded {
                addExpandedImageView()
            }
            
            guard let imageView = expandedImageView else { return }
            imageView.transform = CGAffineTransform(scaleX: changedScale, y: changedScale)
            currentExpandedScale = changedScale
            
        default:
            // ジェスチャーが終わった後にスケールが1.1以下だったらViewを削除する
            if currentExpandedScale <= 1.1 {
                removeExpandedImageView()
            }
        }
    }
    
    private func addExpandedImageView() {
        let imageView = UIImageView(frame: expandedImageViewDefaultFrame)
        imageView.image = expandedImage
        self.view.addSubview(imageView)
        self.view.bringSubviewToFront(imageView)
        expandedImageView = imageView
        isImageExpanded = true
    }
    
    private func removeExpandedImageView() {
        guard let imageView = expandedImageView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            imageView.frame = self.expandedImageViewDefaultFrame
        }) { _ in
            imageView.removeFromSuperview()
            self.isImageExpanded = false
        }
    }
}
