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
            return .fractionalWidth(0.9)
        default:
            return .fractionalWidth(0.45)
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .first:
            return "First Section"
        case .second:
            return "Second Section"
        case .third:
            return "Third Section"
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
        navigationItem.title = "Nested Groups and Orthogonal Scrolling"
    }

    private func configureCollectionView() {
        // collectionView.collectionViewLayout
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemGray
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
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
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            
            // group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1.0))
            let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: sectionKind.itemCount )
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: sectionKind.nestedGroupHeight) // we want square so we want full width of 1/2 width
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])
            
            // section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            section.orthogonalScrollingBehavior = .continuous // no paging behavorial
            
            // section header
            // steps to add a section header to a section
            // 1. define the size and add to section
            // 2. register
            // 3. deuque the supplmentary view 
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
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
        
        // deqeueu the header supplementaty view
        dataSource.supplementaryViewProvider = {
            (collectionView, kind, indexPath) in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView, let sectionKind = SectionKind(rawValue: indexPath.section) else {
                fatalError("could not dequeu header view")
            }
            
            // congure header view
            headerView.textLabel.text = sectionKind.sectionTitle
            headerView.textLabel.textAlignment = .left
//            headerView.textLabel.font =
            
            return headerView
        }
        
        // create initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Int>()
        snapshot.appendSections([.first, .second, .third])
        
        // populate the section (3)
        
        snapshot.appendItems(Array(1...20), toSection: .first)
        snapshot.appendItems(Array(21...40), toSection: .second)
        snapshot.appendItems(Array(41...60), toSection: .third)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    

}


