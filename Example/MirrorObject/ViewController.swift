//
//  ViewController.swift
//  MirrorObject
//
//  Created by Matzo on 01/09/2016.
//  Copyright (c) 2016 Matzo. All rights reserved.
//

import UIKit
import MirrorObject

class ViewController: UIViewController {
    
    let obj1 = Foo(id: "1", name: "Jack",  followers: 10, location: "Yamato City")
    let obj2 = Foo(id: "2", name: "Smith", followers: 28, location: "Yokohama City")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("before")
        for obj in [obj1, obj2] {
            print(obj.id, obj.name, obj.followers, obj.location)
        }
        print("after")
        let o1 = Foo(id: "1", name: "Jack", followers: 10, location: "Yamato City")
        o1.name = "Jack.H"
        o1.followers += 1
        o1.location = "Chiba"
        for obj in [obj1, obj2] {
            print(obj.id, obj.name, obj.followers, obj.location)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


class Foo: NSObject, MirrorObject {
    var id: String
    dynamic var name: String
    dynamic var followers: Int
    dynamic var location: String
    
    init(id: String, name: String, followers: Int, location: String) {
        self.id        = id
        self.name      = name
        self.followers = followers
        self.location  = location
        
        super.init()
        self.startMirroring()
    }
    
    deinit {
        self.stopMirroring()
    }
    
    func identifier() -> String {
        return id
    }
}
