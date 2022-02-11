import UIKit

final class ViewController: UIViewController {
  //MARK:- IB Outlets
  
  @IBOutlet private var tableView: TableView! {
    didSet { tableView.handleSelection = showItem }
  }
  
  @IBOutlet private var menuButton: UIButton!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var titleLabelConstraintCenterY: NSLayoutConstraint!
  @IBOutlet private var titleLabelConstraintLeftY: NSLayoutConstraint!
  @IBOutlet private var menuHeightConstraint: NSLayoutConstraint!
  @IBOutlet private var menuButtonTrailingConstraint: NSLayoutConstraint!
  
  
  //MARK:- Variables
  
  private var slider: HorizontalItemSlider!
  private var menuIsOpen = false
}

//MARK:- UIViewController
extension ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    slider = HorizontalItemSlider(in: view) { [unowned self] item in
      self.tableView.addItem(item)
      self.transitionCloseMenu()
    }
    titleLabel.superview!.addSubview(slider)
  }
}

//MARK:- private
private extension ViewController {
  @IBAction func toggleMenu() {
    menuIsOpen.toggle()
    titleLabel.text = menuIsOpen ? "Select Item!" : "Packing List"
    view.layoutIfNeeded()
    
    let constraints = titleLabel.superview!.constraints
    constraints.first {
      $0.firstItem === titleLabel
      && $0.firstAttribute == .centerX
    }?.constant = menuIsOpen ? -100 : 0
    titleLabelConstraintLeftY.isActive = menuIsOpen
    titleLabelConstraintCenterY.isActive = !menuIsOpen
    
    
    menuHeightConstraint.constant = menuIsOpen ? 200 : 80
    menuButtonTrailingConstraint.constant += menuIsOpen ? 8 : -8
    // Spring animation
    UIView.animate(
      withDuration: 1,
      delay: 0,
      usingSpringWithDamping: 0.6,
      initialSpringVelocity: 10,
      options: .allowUserInteraction,
      animations: {
        self.menuButton.transform = .init(rotationAngle: self.menuIsOpen ? .pi / 4 : 0)
        self.view.layoutIfNeeded()
      })
    // Normal animation
//    UIView.animate(
//      withDuration: 1 / 3,
//      delay: 0,
//      options: .curveEaseIn,
//      animations: {
//        self.menuButton.transform = .init(rotationAngle: self.menuIsOpen ? .pi / 4 : 0)
//        self.view.layoutIfNeeded()
//      }
//    )
  }
  
  func showItem(_ item: Item) {
    let imageView = UIImageView(item: item)
    imageView.backgroundColor = .init(white: 0, alpha: 0.5)
    imageView.layer.cornerRadius = 5
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)
    
    let containerView = UIView(frame: imageView.frame)
    view.addSubview(containerView)
    containerView.addSubview(imageView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let bottomConstraint = containerView.bottomAnchor.constraint(
      equalTo: view.bottomAnchor,
      constant: containerView.frame.height)
    let widthConstraint = containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1 / 3, constant: -50)
    
    NSLayoutConstraint.activate([
      bottomConstraint,
      widthConstraint,
      containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
      
      imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
    ])
    
    view.layoutIfNeeded()
    // Spring animation
    UIView.animate(
      withDuration: 1,
      delay: 0,
      usingSpringWithDamping: 0.6,
      initialSpringVelocity: 10,
      animations: {
        bottomConstraint.constant = imageView.frame.height * -2
        widthConstraint.constant = 0
        self.view.layoutIfNeeded()
      })
    // Normal animation
//    UIView.animate(withDuration: 0.8) {
//      bottomConstraint.constant = imageView.frame.height * -2
//      widthConstraint.constant = 0
//      self.view.layoutIfNeeded()
//    }
    
    // move away from screen with animate
//    UIView.animate(
//      withDuration: 2 / 3,
//      delay: 1.5, animations: {
//        bottomConstraint.constant = imageView.frame.height
//        widthConstraint.constant = -50
//        self.view.layoutIfNeeded()
//      },
//      completion: { _ in imageView.removeFromSuperview() })
    delay(seconds: 1.5) {
      UIView.transition(
        with: containerView,
        duration: 1,
        options: .transitionFlipFromBottom,
        animations: imageView.removeFromSuperview,
        completion: { _ in containerView.removeFromSuperview() })
    }
  }
  
  func transitionCloseMenu() {
    delay(seconds: 0.35, execute: toggleMenu)
    UIView.transition(
      with: self.titleLabel.superview!,
      duration: 0.5,
      options: .transitionFlipFromBottom,
      animations: {
        self.slider.isHidden = true
      },
      completion: { _ in self.slider.isHidden = false })
    
  }
}

private func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
}
