public struct Cache<Key: Hashable, Value>: ~Copyable {
    private var nodes: [Key: Node]
    
    private unowned var head: Node? = nil
    private unowned var tail: Node? = nil
    private unowned var hand: Node? = nil
    
    private let capacity: Int
    
    public var count: Int {
        nodes.count
    }
    
    public var isEmpty: Bool {
        nodes.isEmpty
    }
    
    public init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than zero")
        nodes = Dictionary(minimumCapacity: capacity)
        self.capacity = capacity
    }
    
    public func contains(_ key: Key) -> Bool {
        nodes.keys.contains(key)
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let node = nodes[key] else {
            return nil
        }
        return self.removeNode(node)
    }
    
    public subscript(_ key: Key) -> Value? {
        mutating get {
            guard let node = nodes[key] else {
                return nil
            }
            node.visited = true
            return node.value
        }
        _modify {
            if let node = nodes[key] {
                var value: Value? = node.value
                yield &value
                if let value {
                    node.value = value
                    node.visited = true
                } else {
                    self.removeNode(node)
                }
            } else {
                var value: Value? = nil
                yield &value
                if let value {
                    self.addNode(forKey: key, value: value)
                }
            }
        }
        set {
            if let newValue {
                self.updateValue(newValue, forKey: key)
            } else {
                self.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(
        key: Key,
        default defaultValue: @autoclosure () -> Value
    ) -> Value {
        mutating get {
            self[key] ?? defaultValue()
        }
        _modify {
            if let node = nodes[key] {
                yield &node.value
                node.visited = true
            } else {
                var value = defaultValue()
                yield &value
                self.addNode(forKey: key, value: value)
            }
        }
    }
    
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        guard let node = nodes[key] else {
            self.addNode(forKey: key, value: value)
            return nil
        }
        let oldValue = node.value
        node.value = value
        node.visited = true
        return oldValue
    }
}

extension Cache {
    private class Node {
        let key: Key
        var value: Value
        
        unowned var prev: Node? = nil
        unowned var next: Node?
        
        var visited = false
        
        init(key: Key, value: Value, next: Node?) {
            self.key = key
            self.value = value
            self.next = next
        }
    }
    
    private mutating func addNode(forKey key: Key, value: Value) {
        if count == capacity {
            self.evict()
        }
        
        let node = Node(key: key, value: value, next: head)
        nodes[key] = node
        
        if let head {
            head.prev = node
        }
        head = node
        
        if tail == nil {
            tail = head
        }
    }
    
    private mutating func evict() {
        var evictee = hand ?? tail!
        
        while evictee.visited {
            evictee.visited = false
            evictee = evictee.prev ?? tail!
        }
        
        hand = evictee.prev
        self.removeNode(evictee)
    }
    
    @discardableResult
    private mutating func removeNode(_ node: Node) -> Value? {
        if let prev = node.prev {
            prev.next = node.next
        } else {
            head = node.next
        }
        if let next = node.next {
            next.prev = node.prev
        } else {
            tail = node.prev
        }
        return nodes.removeValue(forKey: node.key)!.value
    }
}
