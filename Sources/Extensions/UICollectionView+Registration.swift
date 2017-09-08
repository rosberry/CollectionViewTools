//
//  UICollectionView+Registration.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

public enum ReuseType {
    case byStoryboardIdentifier(String)
    case byNib(UINib, identifier: String)
    case byClass(UICollectionViewCell.Type, identifier: String)
    
    public var identifier: String {
        switch self {
        case let .byStoryboardIdentifier(identifier):   return identifier
        case let .byNib(_, identifier: identifier):     return identifier
        case let .byClass(_, identifier: identifier):   return identifier
        }
    }
    
    public init(cellClass: UICollectionViewCell.Type) {
        self = .byClass(cellClass, identifier: NSStringFromClass(cellClass))
    }
}

public extension UICollectionView {
    
    func register(by type: ReuseType) {
        switch type {
        case let .byNib(nib, identifier: identifier):          register(nib, forCellWithReuseIdentifier: identifier)
        case let .byClass(cellClass, identifier: identifier):  register(cellClass, forCellWithReuseIdentifier: identifier)
        default: break
        }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: NSStringFromClass(T.self), for: indexPath) as! T
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(with type: ReusableViewType, at indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: type.kind,
                                                withReuseIdentifier: "\(T.self)",
            for: indexPath) as! T // swiftlint:disable:this force_cast
    }
}
