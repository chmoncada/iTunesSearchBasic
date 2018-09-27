//
//  Animator.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {

	let duration = 1.0
	var originFrame = CGRect.zero

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		let toView = transitionContext.view(forKey: .to)!
		let songDetailView = toView

		let initialFrame = originFrame
		let finalFrame = songDetailView.frame

		let xScaleFactor = initialFrame.width / finalFrame.width

		let yScaleFactor = initialFrame.height / finalFrame.height

		let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

		songDetailView.transform = scaleTransform
		songDetailView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
		songDetailView.clipsToBounds = true

		containerView.addSubview(toView)
		containerView.bringSubviewToFront(songDetailView)

		UIView.animate(
			withDuration: duration,
			delay:0.0,
			usingSpringWithDamping: 0.4,
			initialSpringVelocity: 0.0,
			animations: {
				songDetailView.transform = CGAffineTransform.identity
				songDetailView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
		},
			completion: { _ in
				transitionContext.completeTransition(true)
		}
		)
	}

}
