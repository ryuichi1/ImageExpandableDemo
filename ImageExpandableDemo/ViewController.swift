import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    // ImageExpandable
    var isImageExpanded: Bool = false {
        didSet {
            imageView.isHidden = self.isImageExpanded
        }
    }
    var currentExpandedScale: CGFloat = 0.0
    var expandedImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageExpandedGesture()
    }
}

extension ViewController: ImageExpandable {
    var expandedImage: UIImage {
        return UIImage(named: "test")!
    }
    
    var expandedImageViewDefaultFrame: CGRect {
        return imageView.frame
    }
    
    func doubleTappedAction(_ sender: UIGestureRecognizer) {
        imageExpanded(doubleTappedAction: sender)
    }

    func panAction(_ sender: UIPanGestureRecognizer) {
        imageExpanded(panAction: sender)
    }
    
    func pinchAction(_ sender: UIPinchGestureRecognizer) {
        imageExpanded(pinchAction: sender)
    }
}

