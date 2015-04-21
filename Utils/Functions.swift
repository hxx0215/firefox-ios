/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// Pipelining.
infix operator |> { associativity left }
public func |> <T, U>(x: T, f: T -> U) -> U {
    return f(x)
}

// Basic currying.
public func curry<A, B>(f: (A) -> B) -> A -> B {
    return { a in
        return f(a)
    }
}

public func curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C {
    return { a in
        return { b in
            return f(a, b)
        }
    }
}

public func curry<A, B, C, D>(f: (A, B, C) -> D) -> A -> B -> C -> D {
    return { a in
        return { b in
            return { c in
                return f(a, b, c)
            }
        }
    }
}

public func curry<A, B, C, D>(f: (A, B, C) -> D) -> (A, B) -> C -> D {
    return { (a, b) in
        return { c in
            return f(a, b, c)
        }
    }
}

// Function composition.
infix operator • {}

public func •<T, U, V>(f: T -> U, g: U -> V) -> T -> V {
    return { t in
        return g(f(t))
    }
}
public func •<T, V>(f: T -> (), g: () -> V) -> T -> V {
    return { t in
        f(t)
        return g()
    }
}
public func •<V>(f: () -> (), g: () -> V) -> () -> V {
    return {
        f()
        return g()
    }
}

// Why not simply provide an override for ==? Well, that's scary, and can accidentally recurse.
// This is enough to catch arrays, which Swift will delegate to element-==.
public func optArrayEqual<T: Equatable>(lhs: [T]?, rhs: [T]?) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None):
        return true
    case (.None, _):
        return false
    case (_, .None):
        return false
    default:
        // This delegates to Swift's own array '==', which calls T's == on each element.
        return lhs! == rhs!
    }
}

public func optDictionaryEqual<K: Equatable, V: Equatable>(lhs: [K: V]?, rhs: [K: V]?) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None):
        return true
    case (.None, _):
        return false
    case (_, .None):
        return false
    default:
        return lhs! == rhs!
    }
}

/**
 * Return members of `a` that aren't nil, changing the type of the sequence accordingly.
 */
public func optFilter<T>(a: [T?]) -> [T] {
    return a.filter { $0 != nil }.map { $0! }
}

/**
 * Return a new map with only key-value pairs that have a non-nil value.
 */
public func optFilter<K, V>(source: [K: V?]) -> [K: V] {
    var m = [K: V]()
    for (k, v) in source {
        if let v = v {
            m[k] = v
        }
    }
    return m
}

/**
 * Map a function over the values of a map.
 */
public func mapValues<K, T, U>(source: [K: T], f: (T -> U)) -> [K: U] {
    var m = [K: U]()
    for (k, v) in source {
        m[k] = f(v)
    }
    return m
}

/**
 * Find the first matching item in the array and return it.
 * Unlike map/filter approaches, this is lazy.
 */
public func find<T>(arr: [T], f: (T) -> Bool) -> T? {
    for (x) in arr {
        if f(x) {
            return x
        }
    }
    return nil
}

/**
 * Take a JSON array, returning the String elements as an array.
 * It's usually convenient for this to accept an optional.
 */
public func jsonsToStrings(arr: [JSON]?) -> [String]? {
    if let arr = arr {
        return optFilter(arr.map { j in
            return j.asString
            })
    }
    return nil
}