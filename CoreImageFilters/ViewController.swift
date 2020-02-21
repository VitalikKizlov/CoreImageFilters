//
//  ViewController.swift
//  CoreImageFilters
//
//  Created by Vitalii Kizlov on 2/19/20.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import UIKit
import CoreImage

enum Filters: String {
    case sepia = "CISepiaTone"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Internal Properties
    
    var filterManager: FilterManager!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureContent()
    }
    
    private func configureContent() {
        configureCollectionView()
        configureFilterManager()
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FilterCollectionViewCell.nib, forCellWithReuseIdentifier: FilterCollectionViewCell.reuseIdentifier)
    }
    
    private func configureFilterManager() {
        filterManager = FilterManager(with: imageView.image!)
        filterManager.filterManagerDelegate = self
        //filterManager.applyFilters()
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterManager.filterObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.reuseIdentifier, for: indexPath) as? FilterCollectionViewCell else { return UICollectionViewCell() }
        //let item = filterManager.filteredImages[indexPath.item]
        let newItem = filterManager.filterObjects[indexPath.item]
        //cell.updateUI(with: item)
        cell.updateUI(with: newItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

extension ViewController: FilterManagerDelegate {
    func applyFiltersResult(_ result: Result<Bool, FilterError>) {
        switch result {
        case .success:
            collectionView.reloadData()
            collectionView.isHidden = false
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

