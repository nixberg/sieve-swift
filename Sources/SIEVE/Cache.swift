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
    
    public subscript(_ key: Key) -> Value? {
        mutating get {
            guard let node = nodes[key] else {
                return nil
            }
            node.visited = true
            return node.value
        }
        mutating set {
            if let newValue {
                self.updateValue(newValue, forKey: key)
            } else {
                self.removeValue(forKey: key)
            }
        }
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
    
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        if let node = nodes[key] {
            defer { node.value = value }
            return node.value
        }
        
        if count == capacity {
            self.evict()
        }
        
        self.addNode(forKey: key, value: value)
        
        return nil
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
