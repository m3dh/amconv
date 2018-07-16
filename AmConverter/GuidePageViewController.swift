import UIKit

class GuidePageViewController: UIPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
            self.dismissToMain()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SharedUIHelper.getStatusBar().backgroundColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SharedUIHelper.getStatusBar().backgroundColor = ConverterMainViewController.xBarBackgroundColor
    }

    @objc func dismissToMain() {
        self.dismiss(animated: true, completion: nil)
    }
}
