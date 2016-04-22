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
    case AddRemove
    case ShowHide
    case None
}

class BGTransitions {
    var sourceView:UIView
    var destinationView:UIView
    var duration:NSTimeInterval
    var completionAction:BGTransitionAction
    var dismissing:Bool
    var rect:CGRect
    var timingCurve:UIViewAnimationCurve
    var m34:Float
    var presentedControllerIncludesStatusBarInFrame:Bool
    
    init(sourceView:UIView,destinationView:UIView,duration:NSTimeInterval,timingCurve:UIViewAnimationCurve,completionAction:BGTransitionAction)
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
        case .EaseOut:
            return kCAMediaTimingFunctionEaseOut
        case .EaseIn:
            return kCAMediaTimingFunctionEaseIn
        case .EaseInOut:
            return kCAMediaTimingFunctionEaseInEaseOut
        case .Linear:
            return kCAMediaTimingFunctionLinear
        }
    }
    
    func perform()
    {
        self.perform(nil)
    }
    
    func perform(completion:CompletionBlock?)
    {
        NSException.raise("Incomplete Implementation", format: "BGTransition must be subclassed and the perform method implemented.",arguments: CVaListPointer(_fromUnsafeMutablePointer: nil))
    }
    
    func transitionDidComplete()
    {
        switch self.completionAction
        {
        case .AddRemove:
            self.sourceView.superview?.addSubview(self.destinationView)
            self.sourceView.removeFromSuperview()
            self.sourceView.hidden = false
        case .ShowHide:
            self.destinationView.hidden = false
            self.sourceView.hidden = true
        case .None:
            self.sourceView.hidden = false
        }
    }
    
    func setPresentingController(presentingController:UIViewController)
    {
        var src = presentingController
        
        while true
        {
            if src.parentViewController == nil
            {
                break
            }
            
            src = src.parentViewController!
        }
        
        self.rect = src.view.bounds
    }
    
    func setPresentedController(presentedController:UIViewController)
    {
        self.presentedControllerIncludesStatusBarInFrame = presentedController is UINavigationController
    }
    
    func calculateRect() -> CGRect
    {
        var bounds = self.rect
        if self.dismissing && self.presentedControllerIncludesStatusBarInFrame
        {
            let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
            let statusBarWindowRect = self.destinationView.window?.convertRect(statusBarFrame, fromWindow: nil)
            let statusBarViewRect = self.destinationView.convertRect(statusBarWindowRect!, fromView: nil)
            bounds.origin.y += statusBarViewRect.size.height
            bounds.size.height -= statusBarViewRect.size.height
            self.rect = bounds
        }
        
        return bounds
    }
    
//MARK - Class methods
    class func defaultDuration() -> NSTimeInterval
    {
        return 0.3
    }
    
}









