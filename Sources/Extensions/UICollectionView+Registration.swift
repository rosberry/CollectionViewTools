//
//  UICollectionView+Registration.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

public enum ReuseType {
    case storyboardIdentifier(String)
    case nib(UINib, identifier: String)
    case `class`(UICollectionReusableView.Type)
    
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
    
    func registerCell(by type: ReuseType) {
        switch type {
            case let .nib(nib, identifier):
                register(nib, forCellWithReuseIdentifier: identifier)
            case let .class(`class`):
                register(`class`, forCellWithReuseIdentifier: type.identifier)
            default:
                break
        }
    }

    func registerView(with type: ReuseType, kind: String) {
        switch type {
        case let .nib(nib, identifier):
            register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        case let .class(`class`):
            register(`class`, forSupplementaryViewOfKind: kind, withReuseIdentifier: type.identifier)
        default:
            break
        }
    }
}
