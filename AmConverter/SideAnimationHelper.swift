import UIKit

enum SideMenuSlideDirection {
    case Left
    case Right
}

class SideAnimationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var sideMenuActivatedDirection: SideMenuSlideDirection?

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidePresentMenuAnimator(direction: self.sideMenuActivatedDirection!)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideDismissMenuAnimator()
    }
}

class SideDismissMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let snapshot = transitionContext.containerView.viewWithTag(SideMenuHelper.snapshotTagNumber),
            let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            animations: {
                snapshot.alpha = 1
                SharedUIHelper.getStatusBar().backgroundColor = ConverterMainViewController.xBarBackgroundColor
                fromController.view.center.y += UIScreen.main.bounds.height * SideMenuHelper.menuHeightPercent
        },
            completion: { _ in
                if !transitionContext.transitionWasCancelled {
                    transitionContext.containerView.insertSubview(toController.view, aboveSubview: fromController.view)
                    snapshot.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class SidePresentMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var direction: SideMenuSlideDirection

    init(direction: SideMenuSlideDirection) {
        self.direction = direction
    }

    func transitionDuration(using: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }

        // Create a snapshot (a picture) of current (from) view.
        let snapshot = fromController.view.snapshotView(afterScreenUpdates: false)!
        snapshot.tag = SideMenuHelper.snapshotTagNumber
        snapshot.isUserInteractionEnabled = false
        transitionContext.containerView.insertSubview(snapshot, aboveSubview: fromController.view)
        fromController.view.isHidden = true

        // Insert the to controller view below the from view
        transitionContext.containerView.insertSubview(toController.view, aboveSubview: snapshot)
        let previouCenterY = toController.view.center.y
        toController.view.center.y += UIScreen.main.bounds.height * SideMenuHelper.menuHeightPercent

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            animations: {
                snapshot.alpha = 0.5
                SharedUIHelper.getStatusBar().backgroundColor = SideMenuHelper.dimmedStatusBarColor
                toController.view.center.y = previouCenterY
        },
            completion: { _ in
                fromController.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

struct SideMenuHelper {
    static var menuHeightPercent: CGFloat = 0.5
    static var snapshotTagNumber: Int = 10001

    static let dimmedStatusBarColor: UIColor = UIColor(red: 36.0/255, green: 35.0/255, blue: 42.0/255, alpha: 1)
}
