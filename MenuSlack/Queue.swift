//
//  Queue.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

protocol QueueObserver: class {
    func queueAddedObject()
}

class Queue<T> {
    private var items: Array<T>
    weak var observer: QueueObserver?
    
    init() {
        items = []
    }
    
    func addItem(newItem : T) {
        items.append(newItem)
        observer?.queueAddedObject()
    }
    
    func popTopItem() -> T? {
        let topItem = items.first
        items.removeAtIndex(0)
        return topItem
    }
    
    func isEmpty() -> Bool
    {
        return items.count == 0
    }
}
