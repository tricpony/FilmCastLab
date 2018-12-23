//
//  FlipPresentAnimationController.swift
//  FilmCastLab
//
//  Created by aarthur on 8/17/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

/////////////////////
//
// https://www.raywenderlich.com/322-custom-uiviewcontroller-transitions-getting-started
// https://www.raywenderlich.com/915-uipresentationcontroller-tutorial-getting-started
//
/////////////////////

import UIKit

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = originFrame
        snapshot.layer.cornerRadius = 25.0
        snapshot.layer.masksToBounds = true
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true
        
        AnimationHelper.perspectiveTransform(for: containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(.pi / 2)
        snapshot.alpha = 0
        let duration = transitionDuration(using: transitionContext)

        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                
                //fade the from view
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3) {
                    fromVC.view.alpha = 0.2
                }
                
                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
                    snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                    snapshot.alpha = 1
                }
                
                UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
                    snapshot.frame = finalFrame
                    snapshot.layer.cornerRadius = 0
                }
                
        },
            completion: { _ in
                toVC.view.isHidden = false
                fromVC.view.alpha = 1
                snapshot.removeFromSuperview()
                fromVC.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

    }
    

}
