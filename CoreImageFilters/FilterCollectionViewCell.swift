//
//  FilterCollectionViewCell.swift
//  CoreImageFilters
//
//  Created by Vitalii Kizlov on 2/19/20.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    static var nib: UINib {
        return UINib(nibName: String(describing: FilterCollectionViewCell.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: FilterCollectionViewCell.self)
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func updateUI(with filteredImage: UIImage) {
        imageView.image = filteredImage
    }
    
    public func updateUI(with filter: Filter) {
        imageView.image = filter.outputImage
        filterNameLabel.text = filter.filterName
    }

}
