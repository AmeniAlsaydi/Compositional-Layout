//
//  ViewController.swift
//  Compositional-Layout
//
//  Created by Amy Alsaydi on 8/17/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit

class GridViewController: UIViewController {
    // 3.
    enum Section {
        case main
    }
    
    @IBOutlet weak var collectionView: UICollectionView! // layout by default is flow layout
    
    // 4. declare out data source which we will be using diffable data source
    // review: both the SectionIdentifier
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }

    // 2
    private func configureCollectionView() {
        // programatically
        // collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        
        
        // change the collectionView's layout
        // using storyboard
        collectionView.collectionViewLayout = createLayout() // no longer a flow layout -> compositional layout
        collectionView.backgroundColor = .systemBackground
    }
    
    // 1. Create layout
    // Item -> Group -> Section -> Layout
    public func createLayout() -> UICollectionViewLayout {
        // create and configure the item
        // item takes up 25% of the group's width and 100% of the group's height
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        // create and configure group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4) // count = number of columns
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // 3.
        // configure the section
        let section = NSCollectionLayoutSection(group: group)
        
        // 4 configure layout
        let layout = UICollectionViewCompositionalLayout(section: section)
       
        // return layout
        return layout
    }
    
    // 5. configure the dataSource
    private func configureDataSource() {
        // 1. set up the data source
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            // configure and return the cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
                fatalError("could not dequeue a LabelCell")
            }
            cell.textLabel.text = "\(item)"
            cell.backgroundColor = .systemPink
            return cell
        })
        
        // 2. set up the initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(1...100)) // data is
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}

