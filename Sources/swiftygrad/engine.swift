import Foundation

public class Value {
    
    // MARK: - Public properties
    
    public let data: Double
    public let operation: String
    public private(set) var grad: Double = 0
    public let prev: Set<Value>
    
    // MARK: - Private properties
    
    private var _backward: (() -> Void)?
    
    // MARK: - Public init
    
    public init(_ data: Double,
                children: Set<Value> = [],
                operation: String = "") {
        self.data = data
        self.operation = operation
        self.prev = children
    }
    
    // MARK: - Public methods
    
    // MARK: Addition
    
    public static func + (lhs: Value, rhs: Value) -> Value {
        let out = Value(lhs.data + rhs.data, children: [lhs, rhs], operation: "+")
        
        out._backward = {
            lhs.grad += out.grad
            rhs.grad += out.grad
        }
        
        return out
    }
    
    public static func + (lhs: Value, rhs: Double) -> Value {
        return lhs + Value(rhs)
    }
    
    public static func + (lhs: Double, rhs: Value) -> Value {
        return Value(lhs) + rhs
    }
    
    // MARK: Subtraction
    
    public static func - (lhs: Value, rhs: Value) -> Value {
        return lhs + (-rhs)
    }
    
    public static func - (lhs: Value, rhs: Double) -> Value {
        return lhs + (-rhs)
    }
    
    public static func - (lhs: Double, rhs: Value) -> Value {
        return lhs + (-rhs)
    }
    
    // MARK: Multiplication
    
    public static func * (lhs: Value, rhs: Value) -> Value {
        let out = Value(lhs.data * rhs.data, children: [lhs, rhs], operation: "*")
        
        out._backward = {
            lhs.grad += rhs.data * out.grad
            rhs.grad += lhs.data * out.grad
        }
        
        return out
    }
    
    public static func * (lhs: Value, rhs: Double) -> Value {
        return lhs * Value(rhs)
    }
    
    public static func * (lhs: Double, rhs: Value) -> Value {
        return Value(lhs) * rhs
    }
    
    // MARK: Division
    
    public static func / (lhs: Value, rhs: Value) -> Value {
        return lhs * rhs.pow(with: -1)
    }
    
    public static func / (lhs: Value, rhs: Double) -> Value {
        return lhs / Value(rhs)
    }
    
    public static func / (lhs: Double, rhs: Value) -> Value {
        return Value(lhs) / rhs
    }
    
    // MARK: Power
    
    public func pow(with rhs: Double) -> Value {
        let out = Value(Foundation.pow(self.data, rhs),
                        children: [self],
                        operation: "**\(rhs)")
        out._backward = {
            self.grad += (rhs * Foundation.pow(self.data, rhs - 1)) * out.grad
        }
        
        return out
    }
    
    // MARK: RELU
    
    public func relu() -> Value {
        let out = Value(self.data < 0 ? 0 : self.data,
                        children: [self],
                        operation: "ReLU")
        out._backward = {
            self.grad += (out.data > 0 ? 1 : 0) * out.grad
        }
        
        return out
    }
    
    // MARK: Backward
    
    public func backward() {
        var topo = [Value]()
        var visited = Set<Value>()
        func buildTopo(value: Value) {
            if !visited.contains(value) {
                visited.insert(value)
                for child in value.prev {
                    buildTopo(value: child)
                }
                topo.append(value)
            }
        }
        buildTopo(value: self)
        
        self.grad = 1
        for value in topo.reversed() {
            if let back = value._backward {
                back()
            }
        }
    }
    
    // MARK: Prefix
    
    static prefix func - (value: Value) -> Value {
        return value * -1
    }
    
}

extension Value: Hashable {
    
    public static func == (lhs: Value, rhs: Value) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(grad)
        hasher.combine(data)
        hasher.combine(operation)
        hasher.combine(prev)
    }
    
}
