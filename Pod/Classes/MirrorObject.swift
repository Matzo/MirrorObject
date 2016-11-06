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
    @objc optional func identifier() -> String
    @objc optional func excludeProperties() -> [String]
    @objc optional func isMirrorDisabled() -> Bool
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
        if let identifier = self.identifier?(), let className = NSStringFromClass(Self).components(separatedBy: ".").last {
            return "MirrorObject_\(className)_\(identifier)"
        } else {
            return nil
        }
    }
    
    func receiveMirror(_ notification: Notification) {
        if self === (notification.object as? MirrorObject) {
            return
        }
        guard let fromObj = notification.object as? NSObject else { return }
        guard let keyPath = notification.userInfo?["keyPath"] as? String else { return }
        
        self.observer?.enabled = false
        (self as? NSObject)?.setValue(fromObj.value(forKeyPath: keyPath), forKeyPath: keyPath)
        self.observer?.enabled = true
    }
    
    func propertyNames() -> [String] {
        var count: UInt32 = 0
        var names: [String] = []
        let properties = class_copyPropertyList(Self.self, &count)
        let excludes = excludeProperties?() ?? []

        // use label for performance
        props: for i in 0..<Int(count) {
            let prop = properties?[i]
            if let name = NSString(utf8String: property_getName(prop)) as? String {
                
                // exlude specified properties
                for i in 0..<excludes.count {
                    if name == excludes[i] {
                        continue props
                    }
                }
                
                if let props = NSString(utf8String: property_getAttributes(prop))?.range(of: ",R"), props.location == NSNotFound
                {
                    names.append(name)
                }
            }
        }
        return names
    }
    
    // MARK: - Public Methods
    public func mirror(_ keyPath: String) {
        guard let notiName = self.mirrorNotificationName() else { return }
        if isMirrorDisabled?() ?? false { return }

        if let _ = self.observer {
            NotificationCenter.default.post(name: Notification.Name(rawValue: notiName), object: self, userInfo: ["keyPath": keyPath])
        }
    }
    
    public func startMirroring() {
        guard let notiName = self.mirrorNotificationName() else { return }

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: notiName), object: nil, queue: OperationQueue.main) { [weak self] (noti) -> Void in
            self?.receiveMirror(noti)
        }
        
        let observer = MirrorObserver()
        self.observeDynamicProperties(self, observer: observer, baseKeyPath: nil)
        self.observer = observer
    }

    public func stopMirroring() {
        self.removeDynamicPropertiesObserver()
        self.observer = nil
    }

    // MARK: - Private Methods
    fileprivate func observeDynamicProperties(_ obj:MirrorObject, observer: MirrorObserver, baseKeyPath: String?) {
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
            
            if let value = _self.value(forKeyPath: keyPath) as? MirrorObject {
                self.observeDynamicProperties(value, observer: observer, baseKeyPath: keyPath)
            } else {
                _self.addObserver(observer, forKeyPath: keyPath, options: [.new, .old], context: nil)
                observer.observingKeys.append(keyPath)
            }
        }
    }
    fileprivate func removeDynamicPropertiesObserver() {
        if let observer = self.observer, let _self = self as? NSObject {
            for keyPath in observer.observingKeys {
                _self.removeObserver(observer, forKeyPath: keyPath)
            }
            observer.observingKeys.removeAll()
        }
    }
}

class MirrorObserver: NSObject {
    var observingKeys: [String] = []
    var enabled: Bool = true
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard enabled else { return }

        if let object = object as? MirrorObject, let keyPath = keyPath {
            object.mirror(keyPath)
        }
    }
}
