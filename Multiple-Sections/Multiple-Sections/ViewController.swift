//
//  ViewController.swift
//  Multiple-Sections
//
//  Created by Amy Alsaydi on 8/18/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // step1 create enum to
    enum Section: Int, CaseIterable {
        case grid // rawvalue default 0
        case single // 1
        // TODO: add a 3rd section
        
        var columnCount: Int {
            switch self {
            case .grid:
                return 4 // 4 columns
            case .single:
                return 1 // 1 columns
            }
        }
    }
    // step 2
    @IBOutlet weak var collectionView: UICollectionView! // default layout is flow
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
    
    private var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()

    }
    
    private func configureCollectionView() {
        // override the default layout from the flow to compositional
        // programatically is diff

        collectionView.collectionViewLayout = creatLayout()
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
    }

    // step 3
    private func creatLayout() -> UICollectionViewLayout {
        // item -> group -> section
        // let layout = UICollectionViewCompositionalLayout(section: section)
        // return layout
        
        // closure
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // find out what section we are working with
            
            guard let sectionType = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            // how many columns
            let columns = sectionType.columnCount // 1 or 4 columns
            
            // create the layout: item -> group -> section -> layout
            // item container -> group
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // add content inset for item
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            // group container -> section
            let groupHeight = columns == 1 ? NSCollectionLayoutDimension.absolute(200) : NSCollectionLayoutDimension.fractionalWidth(0.25)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            
            let section = NSCollectionLayoutSection(group: group)
            
            // configure header view
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.01), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return layout
    }

    // step 5
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: {
            //1 set up data source
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            // configure the cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
                fatalError("could not dequeue a LabelCell")
            }
            cell.textLabel.text = "\(item)"
            
            if indexPath.section == 0 {
                cell.backgroundColor = .systemPink
            } else {
                cell.backgroundColor = .systemBlue
            }
            
            return cell
            
        })
        
        // 3
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
                fatalError("could not dequeue a HeaderView")
            }
            
            headerView.textLabel.text = "\(Section.allCases[indexPath.section])".capitalized
            return headerView
            
        }
        
        // 2 set up snap shot
        var snapshot = NSDiffableDataSourceSnapshot<Section,Int>()
        snapshot.appendSections([.grid, .single])
        snapshot.appendItems(Array(1...12), toSection: .grid)
        snapshot.appendItems(Array(13...20), toSection: .single) // duplicates
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

