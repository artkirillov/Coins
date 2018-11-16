//
//  CustomViewControllerAnimator.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 14.04.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CustomViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration : TimeInterval
    var isPresenting : Bool
    var originFrame : CGRect
    
    init(duration : TimeInterval, isPresenting : Bool, originFrame : CGRect) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.originFrame = originFrame
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
        let snapshot = isPresenting ? toVC.view.snapshotView(afterScreenUpdates: true) : fromVC.view.snapshotView(afterScreenUpdates: false)
            else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = isPresenting ? originFrame : finalFrame
        snapshot.alpha = isPresenting ? 0.0 : 1.0
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        if isPresenting { toVC.view.isHidden = true }
        
        UIView.animate(
            withDuration: self.duration,
            animations: {
                snapshot.frame = self.isPresenting ? finalFrame : self.originFrame
                snapshot.alpha = self.isPresenting ? 1.0 : 0.0
        },
            completion: { _ in
                if self.isPresenting { toVC.view.isHidden = false }
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
