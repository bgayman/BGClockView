//
//  BGFlipTransition.swift
//  Clock
//
//  Created by Brad G. on 3/1/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}




typealias CompletionBlock = (Bool)->()

enum BGFlipStyle
{
    case fowardHorizontalRegularPerspective
    case fowardHorizontalReversePerspective
    case fowardVerticalRegularPerspective
    case fowardVerticalReversePerspective
    case backwardHorizontalRegularPerspective
    case backwardHorizontalReversePerspective
    case backwardVerticalRegularPerspective
    case backwardVerticalReversePerspective
}

public extension UIView
{
    public class func subViewIsAboveSubview(_ subView1:UIView,subView2:UIView) -> Bool
    {
        let superview = subView1.superview
        let index1 = superview?.subviews.index(of: subView1)
        let index2 = superview?.subviews.index(of: subView2)
        
        if index2 == NSNotFound
        {
            fatalError("Both views must have same superview")
        }
        return index1 > index2
    }
    
    public class func subViewIsBelowSubView(_ subView1:UIView,subView2:UIView) -> Bool
    {
        return self.subViewIsAboveSubview(subView2, subView2: subView1)
    }
    
    public func aboveSiblingView(_ siblingView:UIView) -> Bool
    {
        return UIView.subViewIsAboveSubview(self, subView2: siblingView)
    }
    
    public func belowSiblingView(_ siblingView:UIView) -> Bool
    {
        return UIView.subViewIsAboveSubview(siblingView, subView2: self)
    }
}

class BGFlipTransition: BGTransitions {
    
    var style:BGFlipStyle
    var coveredPageShadowOpacity:CGFloat
    var flippingPageShadowOpacity:CGFloat
    var flipShadowColor:UIColor
    var destinationViewShown:Bool
    var layersBuilt:Bool
    var animationView:UIView?
    var layerFront:CALayer?
    var layerFacing:CALayer?
    var layerBack:CALayer?
    var layerReveal:CALayer?
    var revealLayerMask:CAShapeLayer?
    var layerFrontShadow:CAGradientLayer?
    var layerBackShadow:CAGradientLayer?
    var layerFacingShadow:CALayer?
    var layerRevealShadow:CALayer?
    var flipStage:Int
    
    init(sourceView:UIView,destinationView:UIView,duration:TimeInterval,style:BGFlipStyle,completionAction:BGTransitionAction)
    {
        self.style = style
        self.coveredPageShadowOpacity = 1.0/3.0
        self.flippingPageShadowOpacity = 0.1
        self.flipShadowColor = UIColor.black
        self.layersBuilt = false
        self.destinationViewShown = false
        self.flipStage = 0
        
        super.init(sourceView: sourceView, destinationView: destinationView, duration: duration, timingCurve: .easeIn, completionAction: completionAction)
    }
    
    func timingCurveFunctionNameFirstHalf() -> String
    {
        switch self.timingCurve{
        case .easeIn:
            return kCAMediaTimingFunctionEaseIn
        case .easeInOut:
            return kCAMediaTimingFunctionEaseIn
        case .easeOut:
            return kCAMediaTimingFunctionLinear
        case .linear:
            return kCAMediaTimingFunctionLinear
        }
    }
    
    func timingCurveFunctionNameSecondHalf() -> String {
        switch self.timingCurve{
        case .easeOut:
            return kCAMediaTimingFunctionEaseOut
        case .easeInOut:
            return kCAMediaTimingFunctionEaseOut
        case .easeIn:
            return kCAMediaTimingFunctionLinear
        case .linear:
            return kCAMediaTimingFunctionLinear
        }
    }
    
    func switchToStage(_ stageIndex:Int)
    {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        if stageIndex == 0
        {
            self.doFlip2(0.0)
            self.animationView?.layer.insertSublayer(self.layerFacing!, above: self.layerReveal)
            self.animationView?.layer.insertSublayer(self.layerFront!, above: self.layerFacing)
            self.layerReveal?.addSublayer(self.layerRevealShadow!)
            
            self.layerBack?.removeFromSuperlayer()
            self.layerFacingShadow?.removeFromSuperlayer()
        }
        else
        {
            self.doFlip1(1.0)
            self.animationView?.layer.insertSublayer(self.layerReveal!, above: self.layerFacing)
            self.animationView?.layer.insertSublayer(self.layerBack!, above: self.layerReveal)
            self.layerFacing?.addSublayer(self.layerFacingShadow!)
            
            self.layerFront?.removeFromSuperlayer()
            self.layerRevealShadow?.removeFromSuperlayer()
        }
        CATransaction.commit()
    }
    
    func buildLayers()
    {
        if self.layersBuilt
        {
            return
        }
        
        let forwards = (self.style == .fowardHorizontalRegularPerspective || self.style == .fowardHorizontalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let vertical = (self.style == .backwardVerticalRegularPerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let inward = (self.style == .backwardHorizontalReversePerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalReversePerspective || self.style == .fowardHorizontalReversePerspective)
        
        let bounds = self.calculateRect()
        let scale = UIScreen.main.scale
        
        let inset = vertical ? UIEdgeInsets(top: 0.0, left: 1.0, bottom: 0.0, right: 1.0) : UIEdgeInsets(top: 1.0, left: 0.0, bottom: 1.0, right: 0.0)
        
        var upperRect = bounds
        
        if vertical
        {
            upperRect.size.height = bounds.size.height * 0.5
        }
        else
        {
            upperRect.size.width = bounds.size.height * 0.5
        }
        
        var lowerRect = upperRect
        
        let isOddSize = vertical ? upperRect.size.height != (round(upperRect.size.height * scale)/scale) : (upperRect.size.width != (round(upperRect.size.width * scale)/scale))
        if isOddSize
        {
            if vertical
            {
                upperRect.size.height = round(upperRect.size.height * scale)/scale
                lowerRect.size.height = bounds.size.height - upperRect.size.height
            }
            else
            {
                upperRect.size.width = round(upperRect.size.width * scale)/scale
                lowerRect.size.width = bounds.size.width - upperRect.size.width
            }
        }
        if vertical
        {
            lowerRect.origin.y += upperRect.size.height
        }
        else
        {
            lowerRect.origin.x += upperRect.size.width
        }
        
        if !self.dismissing
        {
            if self.presentedControllerIncludesStatusBarInFrame
            {
                self.destinationView.bounds = CGRect(x: 0.0, y: 0.0, width: bounds.size.width + bounds.origin.x, height: bounds.size.height + bounds.origin.y)
            }
            else
            {
                self.destinationView.bounds = CGRect(origin: CGPoint.zero, size: bounds.size)
            }
        }
        
        var destUpperRect = upperRect.offsetBy(dx: -upperRect.origin.x, dy: -upperRect.origin.y)
        var destLowerRect = lowerRect.offsetBy(dx: -upperRect.origin.x, dy: -upperRect.origin.y)
        
        if self.dismissing
        {
            let x  = self.destinationView.bounds.size.width - bounds.size.width
            let y = self.destinationView.bounds.size.height - bounds.size.height
            destUpperRect.origin.x += x
            destLowerRect.origin.x += x
            destLowerRect.origin.y += y
            destUpperRect.origin.y += y
            if !self.presentedControllerIncludesStatusBarInFrame
            {
                self.rect = self.rect.offsetBy(dx: x, dy: y)
            }
        }
        else if self.presentedControllerIncludesStatusBarInFrame
        {
            destUpperRect.origin.x += bounds.origin.x
            destLowerRect.origin.x += bounds.origin.x
            destUpperRect.origin.y += bounds.origin.y
            destLowerRect.origin.y += bounds.origin.y
        }
        
        let pageFrontImage = BGViewSnapShot.renderImageFromView(self.sourceView, rect: forwards ? lowerRect : upperRect, insets: inset)
        
        var actingSource = self.sourceView
        var containerView  = actingSource.superview
        if containerView == nil
        {
            actingSource = self.destinationView
            containerView = actingSource.superview
        }
        
        var isDestinationViewAbove = true
        let isModal = containerView is UIWindow
        var drawFacing = false
        var drawReveal = false
        
        switch self.completionAction{
        case .addRemove:
            if !isModal
            {
                self.destinationView.frame = self.sourceView.frame
            }
            containerView?.addSubview(self.destinationView)
            break
        case .showHide:
            self.destinationView.isHidden = false
            isDestinationViewAbove = self.destinationView.aboveSiblingView(self.sourceView)
            break
        case .none:
            if self.destinationView.superview == self.sourceView.superview
            {
                isDestinationViewAbove = self.destinationView.aboveSiblingView(self.sourceView)
                if self.destinationView.isHidden
                {
                    self.destinationView.isHidden = false
                    self.destinationViewShown = true
                }
            }
            else if self.sourceView.superview == nil
            {
                drawFacing = true
            }
            else
            {
                drawReveal = true
                if self.destinationView.isHidden
                {
                    self.destinationView.isHidden = false
                    self.destinationViewShown = true
                }
            }
            break
        }
        
        let pageFacingImage:UIImage? = drawFacing ? BGViewSnapShot.renderImageFromView(self.sourceView, rect: forwards ? upperRect: lowerRect):nil
        let pageBackImage = BGViewSnapShot.renderImageFromView(self.destinationView, rect: forwards ? destUpperRect : destLowerRect, insets: inset)
        let pageRevealImage:UIImage? = drawReveal ? BGViewSnapShot.renderImageFromView(self.destinationView, rect: forwards ? destLowerRect : destUpperRect):nil
        
        var transform = CATransform3DIdentity
        
        let width = vertical ? bounds.size.width : bounds.size.height
        let height = vertical ? bounds.size.height * 0.5 : bounds.size.width * 0.5
        let upperHeight = round(height * scale) / scale
        
        var mainRect = containerView?.convert(self.rect, from: actingSource)
        let center = CGPoint(x: mainRect!.midX, y: mainRect!.midY)
        if isModal
        {
            mainRect = actingSource.convert(mainRect!, from: nil)
        }
        
        self.animationView = UIView(frame: mainRect!)
        self.animationView?.backgroundColor = UIColor.clear
        self.animationView?.transform = actingSource.transform
        self.animationView?.autoresizingMask = [.flexibleTopMargin , .flexibleLeftMargin , .flexibleRightMargin , .flexibleBottomMargin]
        containerView?.addSubview(self.animationView!)
        
        if isModal
        {
            self.animationView?.layer.position = center
        }
        
        self.layerReveal = CALayer()
        self.layerReveal?.frame = CGRect(origin: CGPoint.zero, size: drawReveal ? pageRevealImage!.size : forwards ? destLowerRect.size :destUpperRect.size)
        self.layerReveal?.anchorPoint = CGPoint(x: vertical ? 0.5 : forwards ? 0 : 1, y: vertical ? forwards ? 0 : 1 : 0.5)
        self.layerReveal?.position = CGPoint(x: vertical ? width * 0.5 : upperHeight, y: vertical ? upperHeight : width * 0.5)
        if drawReveal
        {
            self.layerReveal?.contents = pageRevealImage?.cgImage
        }
        self.animationView?.layer.addSublayer(self.layerReveal!)
        
        self.layerFacing = CALayer()
        self.layerFacing?.frame = CGRect(origin: CGPoint.zero, size: drawFacing ? pageFacingImage!.size : forwards ? upperRect.size : lowerRect.size)
        self.layerFacing!.anchorPoint = CGPoint(x: vertical ? 0.5 : forwards ? 1 : 0, y: vertical ? forwards ? 1 : 0 : 0.5)
        self.layerFacing?.position = CGPoint(x: vertical ?  width * 0.5 : upperHeight, y: vertical ? upperHeight : width * 0.5)
        if drawFacing
        {
            self.layerFacing?.contents = pageFacingImage?.cgImage
        }
        self.animationView?.layer.addSublayer(self.layerFacing!)
        
        self.revealLayerMask = CAShapeLayer()
        let maskRect = (forwards == isDestinationViewAbove) ? destLowerRect : destUpperRect
        self.revealLayerMask?.path = UIBezierPath(rect: maskRect).cgPath
        let viewToMask = isDestinationViewAbove ? self.destinationView : self.sourceView
        viewToMask.layer.mask = self.revealLayerMask
        
        self.layerFront = CALayer()
        self.layerFront?.frame = CGRect(origin: CGPoint.zero, size: pageFrontImage.size)
        self.layerFront!.anchorPoint = CGPoint(x: vertical ? 0.5 : forwards ? 0 : 1, y: vertical ? forwards ? 0 : 1 : 0.5)
        self.layerFront?.position = CGPoint(x: vertical ? width * 0.5 : upperHeight, y: vertical ? upperHeight : width * 0.5)
        self.layerFront?.contents = pageFrontImage.cgImage
        self.animationView?.layer.addSublayer(self.layerFront!)
        
        self.layerBack = CALayer()
        self.layerBack?.frame = CGRect(origin: CGPoint.zero, size: pageBackImage.size)
        self.layerBack!.anchorPoint = CGPoint(x: vertical ? 0.5 : forwards ? 1 : 0, y: vertical ? forwards ? 1 : 0 : 0.5)
        self.layerBack?.position = CGPoint(x: vertical ? width * 0.5 : upperHeight, y: vertical ? upperHeight : width * 0.5)
        self.layerBack?.contents = pageBackImage.cgImage
        
        self.layerFrontShadow = CAGradientLayer()
        self.layerFront?.addSublayer(self.layerFrontShadow!)
        self.layerFrontShadow?.frame = self.layerFront!.bounds.insetBy(dx: inset.left, dy: inset.top)
        self.layerFrontShadow?.opacity = 0.0
        if forwards
        {
            self.layerFrontShadow?.colors = [self.flipShadowColor.withAlphaComponent(0.5).cgColor, self.flipShadowColor.cgColor, UIColor.clear]
        }
        else
        {
            self.layerFrontShadow?.colors = [UIColor.clear,self.flipShadowColor.cgColor,self.flipShadowColor.withAlphaComponent(0.5).cgColor]
        }
        self.layerFrontShadow?.startPoint = CGPoint(x: vertical ? 0.5 : forwards ? 0 : 0.5, y: vertical ? forwards ? 0 : 0.5 : 0.5)
        self.layerFrontShadow?.endPoint = CGPoint(x: vertical ? 0.5 : forwards ? 0.5 : 1, y: vertical ? forwards ? 0.5 : 1 : 0.5)
        self.layerFrontShadow?.locations = [0, forwards ? 0.1 : 0.9, 1]
        
        self.layerBackShadow = CAGradientLayer()
        self.layerBack?.addSublayer(self.layerBackShadow!)
        self.layerBackShadow?.frame = self.layerBack!.bounds.insetBy(dx: inset.left, dy: inset.top)
        self.layerBackShadow?.opacity = Float(self.flippingPageShadowOpacity)
        if forwards
        {
            self.layerBackShadow?.colors = [UIColor.clear.cgColor, self.flipShadowColor.cgColor,self.flipShadowColor.withAlphaComponent(0.5).cgColor]
        }
        else
        {
            self.layerBackShadow?.colors = [self.flipShadowColor.withAlphaComponent(0.5).cgColor,self.flipShadowColor.cgColor,UIColor.clear.cgColor]
        }
        self.layerBackShadow?.startPoint = CGPoint(x: vertical ? 0.5 : forwards ? 0.5 : 0, y: vertical ? forwards ? 0.5 : 0 : 0.5)
        self.layerBackShadow?.endPoint = CGPoint(x: vertical ? 0.5 :forwards ? 1 : 0.5, y: vertical ? forwards ? 1 : 0.5 : 0.5)
        self.layerBackShadow?.locations = [0, forwards ? 0.9 : 0.1, 1]
        
        if !inward
        {
            self.layerRevealShadow = CALayer()
            self.layerReveal?.addSublayer(self.layerRevealShadow!)
            self.layerRevealShadow?.frame = self.layerReveal!.bounds
            self.layerRevealShadow?.backgroundColor = self.flipShadowColor.cgColor
            self.layerRevealShadow?.opacity = Float(self.coveredPageShadowOpacity)
            
            self.layerFacingShadow = CALayer()
            self.layerFacingShadow?.frame = self.layerFacing!.bounds
            self.layerFacingShadow?.backgroundColor = self.flipShadowColor.cgColor
            self.layerFacingShadow?.opacity = 0.0
        }
        
        if self.m34 == HUGE
        {
            transform.m34 = -1.0/(height * 4.666666667)
        }
        else
        {
            transform.m34 = CGFloat(self.m34)
        }
        if inward
        {
            transform.m34 = -transform.m34
        }
        self.animationView?.layer.sublayerTransform = transform
        
        self.layersBuilt = true
    }
    
    func cleanupLayers()
    {
        if !self.layersBuilt
        {
            return
        }
        
        self.animationView?.removeFromSuperview()
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.revealLayerMask?.removeFromSuperlayer()
        CATransaction.commit()
        
        self.animationView = nil
        self.layerFront = nil
        self.layerBack = nil
        self.layerFacing = nil
        self.layerReveal = nil
        self.layerFrontShadow = nil
        self.layerBackShadow = nil
        self.layerFacingShadow = nil
        self.layerRevealShadow = nil
        self.revealLayerMask = nil
        
        self.layersBuilt = false
    }
    
    override func perform(_ completion: CompletionBlock?) {
        self.buildLayers()
        self.doFlip2(0)
        self.animateFlip1(false,fromProgress:0,completion:completion!)
    }
    
    func animateFlip1(_ isFallingBack:Bool,fromProgress:CGFloat,completion:CompletionBlock?)
    {
        var fromP = fromProgress
        let forwards = (self.style == .fowardHorizontalRegularPerspective || self.style == .fowardHorizontalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let vertical = (self.style == .backwardVerticalRegularPerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let inward = (self.style == .backwardHorizontalReversePerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalReversePerspective || self.style == .fowardHorizontalReversePerspective)
        
        let layer = isFallingBack ? self.layerBack : self.layerFront
        let flippingShadow = isFallingBack ? self.layerBackShadow : self.layerFrontShadow
        let coveredShadow = isFallingBack ? self.layerFacingShadow : self.layerRevealShadow
        
        if isFallingBack
        {
            fromP = 1 - fromP
        }
        
        let toProgress:CGFloat = 1
        
        let dur = self.duration * 0.5 * Double(toProgress - fromProgress)
        let frameCount:Int = Int(ceil(dur * 60))
        
        let rotationKey = vertical ? "transform.rotation.x" : "transform.rotation.y"
        let factor = (isFallingBack ? -1 : 1) * (forwards ? -1 : 1) * (vertical ? -1 : 1) * .pi / 180.0
        
        CATransaction.begin()
        CATransaction.setValue(dur, forKey: kCATransactionAnimationDuration)
        CATransaction.setValue(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn), forKey: kCATransactionAnimationTimingFunction)
        CATransaction.setCompletionBlock({
            self.flipStage = isFallingBack ? 0 : 1
            self.switchToStage(isFallingBack ? 0 : 1)
            
            self.animateFlip2(isFallingBack, fromProgress: isFallingBack ? 1 : 0, completion: completion)
        })
        
        var animation = CABasicAnimation(keyPath: rotationKey)
        animation.fromValue = 90.0 * factor * Double(fromProgress)
        animation.toValue = 90.0 * factor
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        layer?.add(animation, forKey: nil)
        layer?.transform = CATransform3DMakeRotation(90.0 * CGFloat(factor), vertical ? 1 : 0, vertical ? 0 : 1, 0)
        
        animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = self.flippingPageShadowOpacity * fromProgress
        animation.toValue = self.flippingPageShadowOpacity
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        flippingShadow?.add(animation, forKey: nil)
        flippingShadow?.opacity = Float(self.flippingPageShadowOpacity)
        
        if !inward
        {
            var arrayOpacity = [CGFloat]()
            var progress:CGFloat
            var cosOpacity:CGFloat
            for frame in 0...frameCount
            {
                progress = fromProgress + (toProgress - fromProgress) * CGFloat(frame) / CGFloat(frameCount)
                cosOpacity = cos(degreesToRadians(90.0 * progress)) * coveredPageShadowOpacity
                if frame == frameCount
                {
                    cosOpacity = 0
                }
                arrayOpacity.append(cosOpacity)
            }
            let keyAnimation = CAKeyframeAnimation(keyPath: "opacity")
            keyAnimation.values = arrayOpacity
            keyAnimation.fillMode = kCAFillModeForwards
            keyAnimation.isRemovedOnCompletion = false
            coveredShadow?.add(keyAnimation, forKey: nil)
            coveredShadow?.opacity = Float(arrayOpacity.last!)
            
            
        }
        CATransaction.commit()
    }
    
    func animateFlip2(_ isFallingBack:Bool,fromProgress:CGFloat,completion:CompletionBlock?)
    {
        var fromP = fromProgress
        let forwards = (self.style == .fowardHorizontalRegularPerspective || self.style == .fowardHorizontalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let vertical = (self.style == .backwardVerticalRegularPerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let inward = (self.style == .backwardHorizontalReversePerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalReversePerspective || self.style == .fowardHorizontalReversePerspective)
        
        let layer = isFallingBack ? self.layerFront : self.layerBack
        let flippingShadow = isFallingBack ? self.layerFrontShadow : self.layerBackShadow
        let coveredShadow = isFallingBack ? self.layerRevealShadow :self.layerFacingShadow
        
        let frameCount:Int = Int(ceil(self.duration * 0.5 * 60))
        
        let rotationKey = vertical ? "transform.rotation.x" : "transform.rotation.y"
        let factor = (isFallingBack ? -1 : 1) * (forwards ? -1 : 1) * (vertical ? -1 : 1) * .pi / 180.0

        if isFallingBack
        {
            fromP = 1 - fromP
        }
        
        let toProgress:CGFloat = 1
        
        CATransaction.begin()
        CATransaction.setValue(self.duration * 0.5, forKey: kCATransactionAnimationDuration)
        CATransaction.setValue(CAMediaTimingFunction(name: self.timingCurveFunctionNameSecondHalf()), forKey: kCATransactionAnimationTimingFunction)
        CATransaction.setCompletionBlock({
            self.cleanupLayers()
            self.transitionDidComplete()
            if completion != nil
            {
                completion!(true)
            }
        })
        var animation2 = CABasicAnimation(keyPath: rotationKey)
        animation2.fromValue = -90.0 * factor * Double(1-fromProgress)
        animation2.toValue = 0
        animation2.fillMode = kCAFillModeForwards
        animation2.isRemovedOnCompletion = false
        layer?.add(animation2, forKey: nil)
        layer?.transform = CATransform3DIdentity
        
        animation2 = CABasicAnimation(keyPath: "opacity")
        animation2.fromValue = self.flippingPageShadowOpacity * (1 - fromProgress)
        animation2.toValue = 0
        animation2.fillMode = kCAFillModeForwards
        animation2.isRemovedOnCompletion = false
        flippingShadow?.add(animation2, forKey: nil)
        flippingShadow?.opacity = Float(0)
        
        if !inward
        {
            var arrayOpacity = [CGFloat]()
            var progress:CGFloat
            var sinOpacity:CGFloat
            for frame in 0...frameCount
            {
                progress = fromProgress + (toProgress - fromProgress) * CGFloat(frame) / CGFloat(frameCount)
                sinOpacity = sin(degreesToRadians(90.0 * progress)) * coveredPageShadowOpacity
                if frame == 0
                {
                    sinOpacity = 0
                }
                arrayOpacity.append(sinOpacity)
            }
            let keyAnimation = CAKeyframeAnimation(keyPath: "opacity")
            keyAnimation.values = arrayOpacity
            keyAnimation.fillMode = kCAFillModeForwards
            keyAnimation.isRemovedOnCompletion = false
            coveredShadow?.add(keyAnimation, forKey: nil)
            coveredShadow?.opacity = Float(arrayOpacity.last!)
        }
        CATransaction.commit()
    }
    
    func doFlip1(_ progress:CGFloat)
    {
        var p = progress
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        if p < 0
        {
            p = 0
        }
        else if p > 1
        {
            p = 1
        }
        
        self.layerFront?.transform = self.flipTransform1(progress)
        self.layerFrontShadow?.opacity = Float(self.flippingPageShadowOpacity * progress)
        let cosOpacity = cos(degreesToRadians(90 * progress)) * self.coveredPageShadowOpacity
        self.layerRevealShadow?.opacity = Float(cosOpacity)
        
        CATransaction.commit()
    }
    
    func doFlip2(_ progress:CGFloat)
    {
        var p = progress
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        if p < 0
        {
            p = 0
        }
        else if p > 1
        {
            p = 1
        }
        self.layerBack?.transform = self.flipTransform2(progress)
        self.layerBackShadow?.opacity = Float(self.flippingPageShadowOpacity * (1 - progress))
        let sinOpacity = sin(degreesToRadians(90 * progress)) * self.coveredPageShadowOpacity
        self.layerFacingShadow?.opacity = Float(sinOpacity)
        
        CATransaction.commit()
    }
    
    func flipTransform1(_ progress:CGFloat) -> CATransform3D
    {
        var tHalf1 = CATransform3DIdentity
        
        let forwards = (self.style == .fowardHorizontalRegularPerspective || self.style == .fowardHorizontalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let vertical = (self.style == .backwardVerticalRegularPerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        tHalf1 = CATransform3DRotate(tHalf1, degreesToRadians(90.0 * progress * (forwards ? -1 : 1)), vertical ? -1 : 0, vertical ? 0 : 1, 0)
        return tHalf1
    }
    
    func flipTransform2(_ progress:CGFloat) ->CATransform3D
    {
        var tHalf2 = CATransform3DIdentity
        
        let forwards = (self.style == .fowardHorizontalRegularPerspective || self.style == .fowardHorizontalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        let vertical = (self.style == .backwardVerticalRegularPerspective || self.style == .backwardVerticalReversePerspective || self.style == .fowardVerticalRegularPerspective || self.style == .fowardVerticalReversePerspective)
        tHalf2 = CATransform3DRotate(tHalf2, degreesToRadians(90.0 * (1 - progress) * (forwards ? 1 : -1)), vertical ? -1 : 0, vertical ? 0 : 1, 0)
        return tHalf2
    }
    
    fileprivate func degreesToRadians(_ degrees:CGFloat) -> CGFloat
    {
        return degrees * CGFloat.pi / 180.0
    }
    
    /*override func transitionDidComplete() 
    {
        switch self.completionAction{
        case .AddRemove:
            self.sourceView.removeFromSuperview()
            break
        case .ShowHide:
            self.sourceView.hidden = true
            break
        case .None:
            if self.destinationViewShown
            {
                self.destinationView.hidden = true
            }
            break
        }
    }*/
    
    //MARK: - Class Methods
    
    class func transitionFromViewController(_ fromController:UIViewController, toController:UIViewController,dur:TimeInterval,sty:BGFlipStyle,completion:CompletionBlock?)
    {
        let flipTransation = BGFlipTransition(sourceView: fromController.view, destinationView: toController.view, duration: dur, style: sty, completionAction: .none)
        flipTransation.perform(completion)
    }
    
    class func transitionFromView(_ fromView:UIView,toView:UIView,dur:TimeInterval,sty:BGFlipStyle,act:BGTransitionAction,completion:CompletionBlock?)
    {
        let flipTransation = BGFlipTransition(sourceView: fromView, destinationView: toView, duration: dur, style: sty, completionAction: act)
        flipTransation.perform(completion)
    }
    
    class func presentViewController(_ viewControllerToPresent:UIViewController,presentingViewController:UIViewController,dur:TimeInterval,sty:BGFlipStyle,completion:CompletionBlock?)
    {
        let flipTransition = BGFlipTransition(sourceView: presentingViewController.view, destinationView: viewControllerToPresent.view, duration: dur, style: sty, completionAction: .none)
        
        flipTransition.setPresentingController(presentingViewController)
        flipTransition.setPresentedController(viewControllerToPresent)
        
        flipTransition.perform({(finished:Bool) in
            if finished
            {
                presentingViewController.modalPresentationStyle = .fullScreen
                presentingViewController.present(viewControllerToPresent, animated: false, completion: {
                    if completion != nil
                    {
                        completion!(true)
                    }
                })
            }
        })
    }
    
    class func dismissViewControllerFromPresentingController(_ presentingController:UIViewController,dur:TimeInterval,sty:BGFlipStyle,completion:CompletionBlock?)
    {
        let src = presentingController.presentedViewController
        if src == nil
        {
            return
        }
        var dest = presentingController
        
        while true
        {
            if dest.parent == nil
            {
                break
            }
            dest  = dest.parent!
        }
        let flipTransition = BGFlipTransition(sourceView: src!.view, destinationView: dest.view, duration: dur, style: sty, completionAction: .none)
        flipTransition.dismissing = true
        flipTransition.setPresentedController(src!)
        presentingController.dismiss(animated: false, completion: nil)
        flipTransition.perform({(Bool) in
            dest.view.isHidden = false
            if completion != nil
            {
                completion!(true)
            }
        })
    }
    
}



