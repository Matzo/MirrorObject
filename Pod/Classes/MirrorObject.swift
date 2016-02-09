//
//  MirrorObject.swift
//  MirrorObject
//
//  Created by Matsuo Keisuke on 1/7/16.
//  Copyright © 2016 Keisuke Matsuo. All rights reserved.
//

import Foundation

private var MirrorObject_MirrorObserverKey = "MirrorObject_MirrorObserverKey"
@objc public protocol MirrorObject: NSObjectProtocol {
    optional func identifier() -> String
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
    func mirrorNotificationName() -> String? {
        if let identifier = self.identifier?(), className = NSStringFromClass(Self).componentsSeparatedByString(".").last {
            return "MirrorObject_\(className)_\(identifier)"
        } else {
            return nil
        }
    }
    
    func receiveMirror(notification: NSNotification) {
        if self === notification.object {
            return
        }
        guard let fromObj = notification.object as? NSObject else { return }
        guard let keyPath = notification.userInfo?["keyPath"] as? String else { return }
        
        let observer = self.observer
        self.observer = nil
        (self as? NSObject)?.setValue(fromObj.valueForKeyPath(keyPath), forKeyPath: keyPath)
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
    public func mirror(keyPath: String) {
        guard let notiName = self.mirrorNotificationName() else { return }

        if let _ = self.observer {
            NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: self, userInfo: ["keyPath": keyPath])
        }
    }
    
    public func startMirroring() {
        guard let notiName = self.mirrorNotificationName() else { return }

        NSNotificationCenter.defaultCenter().addObserverForName(notiName, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (noti) -> Void in
            self?.receiveMirror(noti)
        }
        
        let observer = MirrorObserver()
        self.observeDynamicProperties(self, observer: observer, baseKeyPath: nil)
        self.observer = observer
    }
    
    private func observeDynamicProperties(obj:MirrorObject, observer: MirrorObserver, baseKeyPath: String?) {
        guard let _self = self as? NSObject else {
            return
        }
        obj.propertyNames().forEach { (key) -> () in
            
            let keyPath: String
            if let base = baseKeyPath {
                keyPath = "\(base).\(key)"
            } else {
                keyPath = key
            }
            
            if let value = _self.valueForKeyPath(keyPath) as? MirrorObject {
                self.observeDynamicProperties(value, observer: observer, baseKeyPath: keyPath)
            } else {
                _self.addObserver(observer, forKeyPath: keyPath, options: [.New, .Old], context: nil)
                observer.observingKeys.append(keyPath)
            }
        }
    }
    private func removeDynamicPropertiesObserver() {
        if let observer = self.observer, _self = self as? NSObject {
            for keyPath in observer.observingKeys {
                _self.removeObserver(observer, forKeyPath: keyPath)
            }
            observer.observingKeys.removeAll()
        }
    }
    
    public func stopMirroring() {
        self.removeDynamicPropertiesObserver()
        self.observer = nil
    }
}

class MirrorObserver: NSObject {
    var observingKeys: [String] = []
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let object = object as? MirrorObject, keyPath = keyPath {
            object.mirror(keyPath)
        }
    }
}