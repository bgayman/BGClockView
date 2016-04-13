//
//  BGViewSnapShot.swift
//  Clock
//
//  Created by Brad G. on 3/1/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit

class BGViewSnapShot {
    class func renderImageFromView(view:UIView) -> UIImage
    {
        return self.renderImageFromView(view, rect: view.bounds)
    }
    
    class func renderImageFromView(view:UIView,rect:CGRect) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y)
        
        view.layer.renderInContext(context!)
        
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return renderedImage
    }
    
    class func renderImageFromView(view:UIView,rect:CGRect,insets:UIEdgeInsets) -> UIImage
    {
        let imageSizeWithBorder = CGSize(width: rect.size.width + insets.left + insets.right, height: rect.size.height + insets.top + insets.bottom)
        UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, -rect.origin.x + insets.left, -rect.origin.y + insets.top)
        
        view.layer.renderInContext(context!)
        
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return renderedImage
    }
    
    class func renderImageForAntialiasing(image:UIImage, insets:UIEdgeInsets) -> UIImage
    {
        let imageSizeWithBorder = CGSize(width: image.size.width + insets.left + insets.right, height: image.size.height + insets.top + insets.bottom)
        
        UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0)
        
        image.drawInRect(CGRect(origin: CGPoint(x: insets.left, y: insets.top), size: image.size))
        
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return renderedImage
    }
    
    class func renderImageForAntialiasing(image:UIImage) -> UIImage
    {
        return self.renderImageForAntialiasing(image, insets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
    }
}