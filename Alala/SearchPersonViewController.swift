import UIKit

class SearchPersonViewController: UIViewController {

  fileprivate let tempView = UIView().then {
    $0.backgroundColor = .red
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()

  }

  func configureView() {
    self.view.addSubview(tempView)

    self.tempView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self.view)
    }
  }

}
