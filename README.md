# CollectionViewTools

[![Platform](https://img.shields.io/cocoapods/p/CollectionViewTools.svg?style=flat)](http://cocoapods.org/pods/CollectionViewTools)
[![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-blue.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CollectionViewTools.svg)](https://img.shields.io/cocoapods/v/CollectionViewTools.svg)
[![SPM Compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Effective framework, similar to [TableViewTools](https://github.com/rosberry/TableViewTools) for making your UICollectionView usage simple and comfortable. It allows you to move UICollectionView configuration and interaction logic to separated objects and simply register, add and remove cells from the collection view.

---

<p align="center">
	<img src="cvt_example.gif" width="300" height="517">
</p>
	
---

## Features

- Separate layer that synchronizes data with the cell appearance
- Full implementation of UICollectionViewDelegate and UICollectionViewDataSource under the hood
- Support of protocols and subclasses as data models

## Requirements

- iOS 8.2+
- Xcode 8.0+

## Installation

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "rosberry/CollectionViewTools"
```

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `CollectionViewTools` by adding it to your `Podfile`:

```ruby
platform :ios, '8.2'
use_frameworks!
pod 'CollectionViewTools'
```
#### Manually

Drag `Sources` folder from [last release](https://github.com/rosberry/CollectionViewTools/releases) into your project.

## Usage

#### Creating manager

```swift
let manager = CollectionViewManager(collectionView: collectionView)
```

#### Creating section

```swift
let titles = ["Item 1", "Item 2", "Item 3"]
var cellItems = titles.map { title in
    return ExampleCollectionViewCellItem(title: title)
}
let sectionItem = GeneralCollectionViewSectionItem(cellItems: cellItems)
manager.sectionItems = [sectionItem]
```

#### Cell item implementation

```swift
class ExampleCollectionViewCellItem: CollectionViewCellItem {
    
    typealias Cell = ExampleCollectionViewCell
    private(set) var reuseType: ReuseType = .class(Cell.self)
    
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }
        cell.titleLabel.text = title
    }
    
    func size() -> CGSize {
        return CGSize(width: 100, height: 40)
    }
}
```

## Diffs

CollectionViewTools support "diffs". It means that `CollectionViewManager` can calculate difference between old and new section items and animate collection view sections and cells accordingly. 

To work with diffs all cell items must conform `DiffItem` protocol: 

```swift
public protocol DiffItem {
    var diffIdentifier: String { get }
    func isEqual(to item: DiffItem) -> Bool
}
```

`diffIdentifier` is used to identify items to find out which items should be inserted, deleted or moved (note that it must be unique(!!!), otherwise diff algorithm can work incorrectly).
`isEqual` is used to compare items with same `diffIdentifier` to find out which items should be updated.
 

#### Cell item implementation
```swift
class ExampleCollectionViewCellItem: CollectionViewCellItem, DiffItem {
        
    // MARK: - DiffItem
    
    var diffIdentifier: String = ""

    func isEqual(to item: DiffItem) -> Bool {
        guard let item = item as? ExampleCollectionViewCellItem else {
            return false
        }
        return title == item.title
    }

    // implementation...
}
```

For section items you can use `GeneralCollectionViewDiffSectionItem` or create your own section items that conforms `DiffSectionItem` protocol.

#### Creating section
```
struct Object {
    let id: UInt
    let title: String
}

let objects = [Object(id: 1, title: "Item 1"),
               Object(id: 2, title: "Item 2"), 
               Object(id: 3, title: "Item 3")]
               
var cellItems = objects.map { object -> ExampleCollectionViewCellItem in
    let cellItem = ExampleCollectionViewCellItem(title: object.title)
    cellItem.diffIdentifier = "\(object.id)"
    return cellItem
}

let sectionItem = GeneralCollectionViewDiffSectionItem(cellItems: cellItems)
sectionItem.diffIdentifier = "main" 

let manager = CollectionViewManager(collectionView: collectionView)
manager.update(with: [sectionItem], animated: true)
```

#### Diff adaptors
`CollectionViewManager` uses [DeepDiff](https://github.com/onmyway133/DeepDiff) to calculate difference between items. But if you want to use other diff libraries (for example [IGListKit](https://github.com/Instagram/IGListKit), [Dwifft](https://github.com/jflinter/Dwifft), etc.) or your own diff algorithm you can create adaptor that conforms `CollectionViewDiffAdaptor` protocol.

```
let adaptor = CollectionViewIGListKitDiffAdaptor()
manager.update(with: [sectionItem], diffAdaptor: adaptor, animated: true)
```

## Authors

* Anton Kovalev, anton.kovalev@rosberry.com
* Dmitry Frishbuter, dmitry.frishbuter@rosberry.com
* Artem Novichkov, artem.novichkov@rosberry.com
* Evgeny Mikhaylov, evgeny.mikhaylov@rosberry.com

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

Product Name is available under the MIT license. See the LICENSE file for more info.
