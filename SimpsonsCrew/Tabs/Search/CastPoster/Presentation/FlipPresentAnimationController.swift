//
//  FlipPresentAnimationController.swift
//  FilmCastLab
//
//  Created by aarthur on 8/17/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

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
        let duration = transitionDuration(using: transitionContext)

        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                
                //shrink the from view
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/4) {
                    fromVC.view.frame = self.originFrame
                    snapshot.layer.cornerRadius = snapshot.layer.cornerRadius
                }

                // 2
                UIView.addKeyframe(withRelativeStartTime: 1/4, relativeDuration: 1/4) {
                    fromVC.view.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                }
                
                // 3
                UIView.addKeyframe(withRelativeStartTime: 2/4, relativeDuration: 1/4) {
                    snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                }
                
                // 4
                UIView.addKeyframe(withRelativeStartTime: 3/4, relativeDuration: 1/4) {
                    snapshot.frame = finalFrame
                    snapshot.layer.cornerRadius = 0
                }
        },
            // 5
            completion: { _ in
                toVC.view.isHidden = false
                fromVC.view.frame = finalFrame
                snapshot.removeFromSuperview()
                fromVC.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

    }
    

}
