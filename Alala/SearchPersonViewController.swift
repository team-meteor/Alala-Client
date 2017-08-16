import UIKit

class SearchPersonViewController: UIViewController {

  fileprivate let tempView = UIView().then {
    $0.backgroundColor = .red
  }
  fileprivate let tempView1 = UIView().then {
    $0.backgroundColor = .blue
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()

  }

  func configureView() {
    self.view.addSubview(tempView)
    self.tempView.addSubview(tempView1)

    self.tempView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self.view)
    }
    self.tempView1.snp.makeConstraints { make in
      make.top.left.right.equalTo(self.tempView)
      make.height.equalTo(30)
    }
  }

}
