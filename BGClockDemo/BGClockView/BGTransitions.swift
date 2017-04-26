//
//  BGTransitions.swift
//  Clock
//
//  Created by Brad G. on 3/1/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit

enum BGTransitionAction
{
    case addRemove
    case showHide
    case none
}

class BGTransitions {
    var sourceView:UIView
    var destinationView:UIView
    var duration:TimeInterval
    var completionAction:BGTransitionAction
    var dismissing:Bool
    var rect:CGRect
    var timingCurve:UIViewAnimationCurve
    var m34:Float
    var presentedControllerIncludesStatusBarInFrame:Bool
    
    init(sourceView:UIView,destinationView:UIView,duration:TimeInterval,timingCurve:UIViewAnimationCurve,completionAction:BGTransitionAction)
    {
        self.sourceView = sourceView
        self.destinationView = destinationView
        self.duration = duration
        self.rect = sourceView.bounds
        self.timingCurve = timingCurve
        self.completionAction = completionAction
        self.m34 = HUGE
        self.presentedControllerIncludesStatusBarInFrame = false
        self.dismissing = false
    }
    
    func timingCurveFunctionName() -> String
    {
        switch self.timingCurve {
        case .easeOut:
            return kCAMediaTimingFunctionEaseOut
        case .easeIn:
            return kCAMediaTimingFunctionEaseIn
        case .easeInOut:
            return kCAMediaTimingFunctionEaseInEaseOut
        case .linear:
            return kCAMediaTimingFunctionLinear
        }
    }
    
    func perform()
    {
        self.perform(nil)
    }
    
    func perform(_ completion:CompletionBlock?)
    {
        fatalError("should be implemented by subclasss")
    }
    
    func transitionDidComplete()
    {
        switch self.completionAction
        {
        case .addRemove:
            self.sourceView.superview?.addSubview(self.destinationView)
            self.sourceView.removeFromSuperview()
            self.sourceView.isHidden = false
        case .showHide:
            self.destinationView.isHidden = false
            self.sourceView.isHidden = true
        case .none:
            self.sourceView.isHidden = false
        }
    }
    
    func setPresentingController(_ presentingController:UIViewController)
    {
        var src = presentingController
        
        while true
        {
            if src.parent == nil
            {
                break
            }
            
            src = src.parent!
        }
        
        self.rect = src.view.bounds
    }
    
    func setPresentedController(_ presentedController:UIViewController)
    {
        self.presentedControllerIncludesStatusBarInFrame = presentedController is UINavigationController
    }
    
    func calculateRect() -> CGRect
    {
        var bounds = self.rect
        if self.dismissing && self.presentedControllerIncludesStatusBarInFrame
        {
            let statusBarFrame = UIApplication.shared.statusBarFrame
            let statusBarWindowRect = self.destinationView.window?.convert(statusBarFrame, from: nil)
            let statusBarViewRect = self.destinationView.convert(statusBarWindowRect!, from: nil)
            bounds.origin.y += statusBarViewRect.size.height
            bounds.size.height -= statusBarViewRect.size.height
            self.rect = bounds
        }
        
        return bounds
    }
    
//MARK - Class methods
    class func defaultDuration() -> TimeInterval
    {
        return 0.3
    }
    
}









