//
//  PDExtention.swift
//  Chat App Upwork
//
//  Created by iParth on 11/16/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


class MyExtention: NSObject {
    //
}

let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)

//extension FileManager.SearchPathDirectory {
//    func createSubFolder(named: String, withIntermediateDirectories: Bool = false) -> Bool {
//        guard let url = FileManager.default.urls(for: self, in: .userDomainMask).first else { return false }
//        do {
//            try FileManager.default.createDirectory(at: url.appendingPathComponent(named), withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
//            return true
//        } catch let error as NSError {
//            print(error.description)
//            return false
//        }
//    }
//}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
extension UIView {
    public func setBorder(width:CGFloat = 1, color: UIColor = UIColor.darkGrayColor())
    {
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = width
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    public func setCornerRadious(radious:CGFloat = 4)
    {
        self.layer.cornerRadius = radious ?? 4
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    public func animateShakeEffect(radious:CGFloat = 20)
    {
        self.transform = CGAffineTransformMakeTranslation(20, 0);
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0, options:.CurveEaseInOut , animations: {
            self.transform = CGAffineTransformIdentity
            })
        { (complete) in
            //print("Finish shaking..")
        }
    }
}


extension NSObject {
    
    func callSelectorAsync(selector: Selector, object: AnyObject?, delay: NSTimeInterval) -> NSTimer {
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: selector, userInfo: object, repeats: false)
        return timer
    }
    
    func callSelector(selector: Selector, object: AnyObject?, delay: NSTimeInterval) {
        
        let delay = delay * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            NSThread.detachNewThreadSelector(selector, toTarget:self, withObject: object)
        })
    }
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.rangeOfString(find, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil
    }
}


extension String {
    
    var convertToDictionary: [String:AnyObject]? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    var utf8StringEncodedData: NSData? {
        return dataUsingEncoding(NSUTF8StringEncoding)
    }
    var base64DecodedData: NSData? {
        return NSData(base64EncodedString: self, options: .IgnoreUnknownCharacters)
    }
}

extension Dictionary where Value: AnyObject {
    
    var clean: [Key: Value] {
        //let tup = filter { !($0.1 is NSNull) }
        //return tup.reduce([Key: Value]()) { (var r, e) in r[e.0] = e.1; return r }
        
        var dict  = self
        let keysToRemove = dict.keys.filter { isNull(dict[$0]) == true }
        for key in keysToRemove {
            dict.removeValueForKey(key)
        }
        return dict
        
        //        self.reduce([String : AnyObject]()) { (var dict, e) in
        //            guard let value = e.1 else { return dict }
        //            dict[e.0] = value
        //            return dict
        //        }
    }
}

func isNull(someObject: AnyObject?) -> Bool {
    guard let someObject = someObject else {
        return true
    }
    
    return (someObject is NSNull)
}


extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}

extension NSDate {
    struct Formatter {
        //user_upload_time : Format (YYYY-MM-DD HH:MM:SS) 2016-08-02 11:22:11 (24 hours)
        static let custom = NSDateFormatter(dateFormat: "yyyy-MM-dd, HH:mm:ss")
        static let customUTC = NSDateFormatter(dateFormat: "yyyy-MM-dd, HH:mm:ss")
    }
    var strDateInLocal: String {
        //formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)  // you can set GMT time
        //formatter.timeZone = NSTimeZone.localTimeZone()        // or as local time
        return Formatter.custom.stringFromDate(self)
    }
    var strDateInUTC: String {
        Formatter.customUTC.timeZone = NSTimeZone(name: "UTC")
        return Formatter.customUTC.stringFromDate(self)
    }
    var customFormatted: String {
        return Formatter.custom.stringFromDate(self)
    }
}

extension String {
    var asDate: NSDate? {
        return NSDate.Formatter.custom.dateFromString(self)
    }
    func asDateFormatted(with dateFormat: String) -> NSDate? {
        return NSDateFormatter(dateFormat: dateFormat).dateFromString(self)
    }
}

extension NSDate {
    
    func getElapsedInterval() -> String {
        
        var interval = NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "year ago" :
                "\(interval)" + " " + "years ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: NSDate(), options: []).month
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "month ago" :
                "\(interval)" + " " + "months ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Day, fromDate: self, toDate: NSDate(), options: []).day
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "day ago" :
                "\(interval)" + " " + "days ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Hour, fromDate: self, toDate: NSDate(), options: []).hour
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour ago" :
                "\(interval)" + " " + "hours ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Minute, fromDate: self, toDate: NSDate(), options: []).minute
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute ago" :
                "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}


