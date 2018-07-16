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
    var collectionView: UICollectionView!
    var collectionSource: [UIImage]!

    @IBOutlet weak var rootView: UIView!

    /*
     - full cell movements
     - dots
     - title, ok button
     - iphone wrapper
    */

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

        // Initialize collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(GuideImageCell.self, forCellWithReuseIdentifier: GuidePageViewController.collectionCellReuseId)
        self.rootView.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: 40).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: 40).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.rootView.rightAnchor, constant: -40).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: -100).isActive = true
        self.collectionView.backgroundColor = .blue
        self.collectionView.bounces = false
        self.collectionView.bouncesZoom = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
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
        print(">> W\(collectionView.bounds.width), H\(collectionView.bounds.height), I\(indexPath.item) <<")
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
