//
//  ViewController.swift
//  Compositional-Layout-with-Combine
//
//  Created by Amy Alsaydi on 8/25/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit
import Combine // asynchrous programing framework introduced in iOS 13

class PhotoSearchViewController: UIViewController {
    enum SectionKind: Int, CaseIterable {
        case main
    }
    private var collectionView: UICollectionView!
    
    // declare datasoure
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Photo>
    
    // declare a search controller
    private var searchController: UISearchController!
    
    // declare searchText property that will be the publisher that emits changes from the searchBAr on the search controller
    // inorder to make any property a publisher you need to append the @Published propterty wrapper
    // publisher emits values
    // to subscribe to the searchText's publisher a $ needs to be prefixed to searchText => $searchText
    @Published private var searchText = ""
    
    // store subscriptions
    private var subscriptions: Set<AnyCancellable> = []
   
    private var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Photo Search"
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        
        $searchText  // subscribe to the searchText Publisher
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { (text) in
                print(text)
                // call the api client for the photo search queue
        }
    .store(in: &subscriptions)
    }
    
    private func searchPhotos(for query: String) {
        // searchPhotos is a publisher
        APIClient().searchPhotos(for: query)
            .sink(receiveCompletion: { (completion) in
                print(completion)
            }) { (photos) in
                dump(photos)
            }
    .store(in: &subscriptions)
    }
    
    private func updateSnapShot(with photos: [Photo]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
//        snapshot.appendItems(<#T##identifiers: [Int]##[Int]#>, toSection: <#T##SectionKind?#>)
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self // think of this like a delegate
//        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
    }
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironmnet) -> NSCollectionLayoutSection? in
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            
            // group (leadingGroup, trailingGroup, nestedGroup)
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 2)
            let trailingGroup =  NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 3)
            let nestGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1000))
            
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestGroupSize, subitems: [leadingGroup, trailingGroup])
            
            // section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            return section
        }
        //layout
        
        return layout
    }
    
    private func configureDataSource() {
        // initializing the data source and configure cell
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, int) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
                fatalError("could not down cast to ImageCell")
            }
            
            cell.backgroundColor = .systemTeal
            return cell
        })
        
        // set up initial snapshot
        var snapshot = dataSource.snapshot() // gets current snapshot
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension PhotoSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // this gets called every time something is typed
//        print(searchController.searchBar.text ?? "")
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            return
        }
        searchText = text
        // upon assigning a new value to the searchText
        // the subscriber in the viewDidLoad will receive that value
    }
}
