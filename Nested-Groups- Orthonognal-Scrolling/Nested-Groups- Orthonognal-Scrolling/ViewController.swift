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
}

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
                return
            }
            
            
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1.0))
            let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: <#T##Int#>)
            
            // section
        }
        
        return layou
    }
    

}

