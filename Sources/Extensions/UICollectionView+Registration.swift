//
//  UICollectionView+Registration.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

public enum ReuseType {
    case storyboardIdentifier(String)
    case nib(UINib, identifier: String)
    case `class`(UICollectionViewCell.Type)
    
    public var identifier: String {
        switch self {
            case let .storyboardIdentifier(identifier):
                return identifier
            case let .nib(_, identifier):
                return identifier
            case let .class(`class`):
                return NSStringFromClass(`class`)
        }
    }
}

public extension UICollectionView {
    
    func register(by type: ReuseType) {
        switch type {
            case let .nib(nib, identifier):
                register(nib, forCellWithReuseIdentifier: identifier)
            case let .class(`class`):
                register(`class`, forCellWithReuseIdentifier: type.identifier)
            default:
                break
        }
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(with type: ReusableViewType, at indexPath: IndexPath) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableSupplementaryView(ofKind: type.kind, withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
}
