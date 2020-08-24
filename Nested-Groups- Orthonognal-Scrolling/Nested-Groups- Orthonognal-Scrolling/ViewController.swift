//
//  ViewController.swift
//  Nested-Groups- Orthonognal-Scrolling
//
//  Created by Amy Alsaydi on 8/24/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit

enum SectionKind: Int, CaseIterable {
    case first
    case second
    case third
    
    // computed property will return the number of items to vertically stack
    var itemCount: Int {
        switch self { // self refers to the instance sectionKind
        case .first:
            return 2
        default:
            return 1
        }
    }
    
    var nestedGroupHeight: NSCollectionLayoutDimension {
        switch self {
        case .first:
            return .fractionalWidth(1.0)
        default:
            return .fractionalWidth(0.5)
        }
    }
}

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>

    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }

    private func configureCollectionView() {
        // collectionView.collectionViewLayout
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemGray
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    
    // will create the layout for the collection view
    private func createLayout() -> UICollectionViewLayout {
        // item -> group -> section -> layout
        
        // Two ways to create a layout
        // 1. use a given section
        // 2. user a section provider which takes a closure
                // - the section provider closure gets called for each section
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // figure out what section we are dealing with
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                fatalError("could not get section kind")
            }
            
            
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1.0))
            let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: sectionKind.itemCount )
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: sectionKind.nestedGroupHeight) // we want square so we want full width of 1/2 width
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])
            
            // section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            
            return section
        }
        
        return layout
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView,indexPath, item) -> UICollectionViewCell? in
            
             // configure cell and return cell
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
                fatalError("could not get downcast to label cell ")
            }
            cell.textLabel.text = "\(item)"
            cell.backgroundColor = .orange
            cell.layer.cornerRadius = 10
            return cell
        })
        
        // create initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Int>()
        snapshot.appendSections([.first, .second, .third])
        
        // populate the section (3)
        
        snapshot.appendItems(Array(1...20), toSection: .first)
        snapshot.appendItems(Array(21...40), toSection: .second)
        snapshot.appendItems(Array(41...60), toSection: .first)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    

}

