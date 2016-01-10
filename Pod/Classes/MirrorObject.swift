//
//  MirrorObject.swift
//  MirrorObject
//
//  Created by Matsuo Keisuke on 1/7/16.
//  Copyright © 2016 Keisuke Matsuo. All rights reserved.
//

import Foundation

private var MirrorObject_MirrorObserverKey = "MirrorObject_MirrorObserverKey"
public protocol MirrorObject: NSObjectProtocol {
    func identifier() -> String
//    func mirrorProperties() -> [String]
}
extension MirrorObject {
    
    // MARK: - KVO
    var observer: MirrorObserver? {
        get {
            return objc_getAssociatedObject(self, &MirrorObject_MirrorObserverKey) as? MirrorObserver
        }
        
        set {
            objc_setAssociatedObject(self, &MirrorObject_MirrorObserverKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // MARK: - Notification
    func mirrorNotificationName() -> String {
        return "MirrorObject_\(NSStringFromClass(Self))_\(self.identifier())".componentsSeparatedByString(".").last ?? self.identifier()
    }
    
    func receiveMirror(notification: NSNotification) {
        if self === notification.object {
            return
        }
        
        let observer = self.observer
        self.observer = nil
        
        if let obj = notification.object as? Self where obj.identifier() == self.identifier() {
            
            self.propertyNames().forEach({ (key) -> () in
                let newValue = (obj as? NSObject)?.valueForKey(key)
                let oldValue = (self as? NSObject)?.valueForKey(key)
                if "\(newValue)" != "\(oldValue)" {
                    (self as? NSObject)?.setValue(newValue, forKey: key)
                }
            })
            
        }
        
        self.observer = observer
    }
    
    func propertyNames() -> [String] {
        var count: UInt32 = 0
        var names: [String] = []
        let properties = class_copyPropertyList(Self.self, &count)
        for i in 0..<Int(count) {
            let prop = properties[i]
            if let name = NSString(UTF8String: property_getName(prop)) as? String {
                names.append(name)
            }
        }
        return names
    }
    
    // MARK: - Public Methods
    public func mirror() {
        if let _ = self.observer {
            NSNotificationCenter.defaultCenter().postNotificationName(mirrorNotificationName(), object: self, userInfo: nil)
        }
    }
    
    public func startMirroring() {
        NSNotificationCenter.defaultCenter().addObserverForName(mirrorNotificationName(), object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (noti) -> Void in
            self?.receiveMirror(noti)
        }
        
        let observer = MirrorObserver()
        self.propertyNames().forEach { (key) -> () in
            guard let obj = self as? NSObject else {
                return
            }
            obj.addObserver(observer, forKeyPath: key, options: [.New, .Old], context: nil)
        }
        self.observer = observer
    }
    
    public func stopMirroring() {
        if let observer = self.observer, object = self as? NSObject {
            self.propertyNames().forEach({ (key) -> () in
                object.removeObserver(observer, forKeyPath: key)
            })
            self.observer = nil
        }
    }
}

class MirrorObserver: NSObject {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let asObj = object as? MirrorObject {
            asObj.mirror()
        }
    }
}