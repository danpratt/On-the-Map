//
//  OTMActivityIndicator.swift
//  On the Map
//
//  Created by Daniel Pratt on 4/4/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import UIKit

// This class presents an activity view over an existing view
class OTMActivityIndicator: NSObject {
    
    enum Color {
        case white, blue, gray
    }
    
    var myActivityIndicator:UIActivityIndicatorView!
    
    func StartActivityIndicator(obj:UIViewController, color: Color) -> UIActivityIndicatorView
    {
        
        myActivityIndicator = UIActivityIndicatorView(frame:CGRect(x: 100, y: 100, width: 100, height: 100)) as UIActivityIndicatorView
        myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        switch color {
        case .white:
            myActivityIndicator.color = UIColor.white
        case .blue:
            myActivityIndicator.color = UIColor(colorLiteralRed: 1.0/255.0, green: 179.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        case .gray:
            fallthrough
        default:
            myActivityIndicator.color = UIColor.gray
        }
        
        myActivityIndicator.center = obj.view.center;
        
        // Add indicator to subview
        obj.view.addSubview(myActivityIndicator);
        
        self.myActivityIndicator.startAnimating();
        return myActivityIndicator;
    }
    
    func StopActivityIndicator(obj:UIViewController,indicator:UIActivityIndicatorView)-> Void
    {
        indicator.removeFromSuperview();
    }
    
    
}
