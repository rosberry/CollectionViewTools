# CollectionViewTools

[![Platform](https://img.shields.io/cocoapods/p/CollectionViewTools.svg?style=flat)](http://cocoapods.org/pods/CollectionViewTools)
[![Swift Version](https://img.shields.io/badge/swift-3.0-orange.svg)](https://swift.org/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-blue.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CollectionViewTools.svg)](https://img.shields.io/cocoapods/v/CollectionViewTools.svg)
[![SPM Compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Effective framework, similar to [TableViewTools](https://github.com/rosberry/TableViewTools) for making your UICollectionView usage simple and comfortable. It allows you to move UICollectionView configuration and interaction logic to separated objects and simply register, add and remove cells from the collection view.

## Features

- Separate layer that synchronizes data with the cell appearance
- Full implementation of UICollectionViewDelegate and UICollectionViewDataSource under the hood
- Support of protocols and subclasses as data models
- No type casts and switches required

## Requirements

- iOS 8.0+
- Xcode 8.0+

## Installation

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "rosberry/CollectionViewTools"
```

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `Product Name` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!
pod 'CollectionViewTools'
```
#### Manually

Drag `Sources` folder from [last release](https://github.com/rosberry/CollectionViewTools/releases) into your project.

## Usage

#### Creating manager

```swift
manager = CollectionViewManager(collectionView: collectionView)
```

#### Creating section

```swift
let titles = ["Item 1", "Item 2", "Item 3"]
var cellItems = [ExampleCollectionViewCellItem]()
titles.forEach { title in
let cellItem = ExampleCollectionViewCellItem(title: title)
    cellItems.append(cellItem)
}

let sectionItem = CollectionViewSectionItem(cellItems: cellItems)
manager.sectionItems = [sectionItem]
```

#### Cell item implementation

```swift
class ExampleCollectionViewCellItem: CollectionViewCellItem {
    
    private let title: String
    
    var reuseType = ReuseType(cellClass: ExampleCollectionViewCell.self)
    
    init(title: String) {
        self.title = title
    }
    
    func size(for collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
    
    func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ExampleCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.titleLabel.text = title
        return cell
    }
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        return size(for: collectionView, at: indexPath)
    }
}
```

## Authors

* Dmitry Frishbuter, dmitry.frishbuter@rosberry.com
* Artem Novichkov, artem.novichkov@rosberry.com

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

Product Name is available under the MIT license. See the LICENSE file for more info.
