import UIKit

class GuidePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    class GuideImageCell: UICollectionViewCell {
        var initialized = false
        var imageView: UIImageView!

        func load(_ img: UIImage) {
            if !self.initialized {
                self.initialized = true
                self.imageView = UIImageView()
                self.contentView.addSubview(self.imageView)
                self.imageView.translatesAutoresizingMaskIntoConstraints = false
                self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
                self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0).isActive = true
                self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0).isActive = true
                self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
            }

            self.imageView.image = img
        }
    }

    static let collectionCellReuseId = "collectionCellReuseId"
    var pageControl: UIPageControl!
    var collectionView: UICollectionView!
    var collectionSource: [UIImage]!

    @IBOutlet weak var rootView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootView.backgroundColor = .white

        // Initialize images
        self.collectionSource = [
            UIImage(named: NSLocalizedString("Guide1MainView", comment: "Guide1MainView"))!,
            UIImage(named: NSLocalizedString("Guide2Selection", comment: "Guide2Selection"))!,
            UIImage(named: NSLocalizedString("Guide3Applied", comment: "Guide3Applied"))!,
            UIImage(named: NSLocalizedString("Guide43dTouch", comment: "Guide43dTouch"))!,
        ]

        let titleLabel = UILabel()
        self.rootView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("GuideViewTitle", comment: "GuideViewTitle")
        titleLabel.font = UIFont(name: ConverterMainViewController.wideFontName, size: 18)
        titleLabel.textColor = .black
        titleLabel.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: 7).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rootView.rightAnchor, constant: 0).isActive = true
        titleLabel.textAlignment = .center

        let dismissButton = AmShadowButton()
        let realDismiss = dismissButton.getRealButton(1)

        realDismiss.setTitle(NSLocalizedString("DismissGuideButtonText", comment: "DismissGuideButtonText"), for: .normal)
        realDismiss.setTitleColor(ConverterMainViewController.longNameButtonFontColor, for: .normal)
        realDismiss.titleLabel!.font = UIFont(name: ConverterMainViewController.wideFontName, size: 16)
        realDismiss.setBackgroundColor(color: ConverterMainViewController.longNameButtonBackColor, forState: .normal)
        self.rootView.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: -18).isActive = true
        dismissButton.centerXAnchor.constraint(equalTo: self.rootView.centerXAnchor).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 53).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dismissButton.button!.addTarget(self, action: #selector(dismissToMain), for: .touchUpInside)

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissToMain))
        self.rootView.addGestureRecognizer(swipeDownGesture)
        swipeDownGesture.direction = .down

        self.pageControl = UIPageControl()
        self.rootView.addSubview(self.pageControl)
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.pageControl.heightAnchor.constraint(equalToConstant: 27).isActive = true
        self.pageControl.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -5).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.rootView.centerXAnchor).isActive = true
        self.pageControl.backgroundColor = .clear
        self.pageControl.hidesForSinglePage = true
        self.pageControl.numberOfPages = self.collectionSource.count
        self.pageControl.isUserInteractionEnabled = false

        self.pageControl.pageIndicatorTintColor = ConverterMainViewController.inputFieldInactiveFontColor
        self.pageControl.currentPageIndicatorTintColor = ConverterMainViewController.inputFieldActivateFontColor

        // Initialize collection view
        let guideContainer = AmCardView()
        let innerContainer = guideContainer.getSubview(5)
        self.rootView.addSubview(guideContainer)
        guideContainer.translatesAutoresizingMaskIntoConstraints = false
        guideContainer.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: 50).isActive = true
        guideContainer.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: -86).isActive = true
        guideContainer.centerXAnchor.constraint(equalTo: self.rootView.centerXAnchor).isActive = true
        guideContainer.widthAnchor.constraint(equalTo: guideContainer.heightAnchor, multiplier: 9.0 / 16.0).isActive = true
        innerContainer.backgroundColor = .lightGray

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(GuideImageCell.self, forCellWithReuseIdentifier: GuidePageViewController.collectionCellReuseId)
        innerContainer.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: innerContainer.topAnchor).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: innerContainer.leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: innerContainer.rightAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: innerContainer.bottomAnchor).isActive = true
        self.collectionView.bounces = false
        self.collectionView.bouncesZoom = false
        self.collectionView.isPagingEnabled = true
        self.collectionView.isSpringLoaded = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
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


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuidePageViewController.collectionCellReuseId, for: indexPath) as? GuideImageCell else { return UICollectionViewCell() }
        cell.load(self.collectionSource[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let indexPath = IndexPath(item: Int( (targetContentOffset.pointee.x + self.collectionView.frame.width * 0.5) / self.collectionView.frame.width ), section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        self.pageControl.currentPage = indexPath.item
    }
}
