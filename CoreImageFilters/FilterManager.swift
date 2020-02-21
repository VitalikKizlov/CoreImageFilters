//
//  FilterManager.swift
//  CoreImageFilters
//
//  Created by Vitalii Kizlov on 2/19/20.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import CoreImage
import UIKit

protocol Filter {
    var filter: CIFilter { get }
    var filterName: String { get }
    var outputImage: UIImage? { get }
    init?(inputImage: CIImage, inputIntensity: CGFloat?)
    
    func applyFilter(inputImage: CIImage)
}

class BlurFilter: Filter {
    let filter: CIFilter
    let filterName: String
    var outputImage: UIImage?
    
    required init?(inputImage: CIImage, inputIntensity: CGFloat? = nil) {
        //let parameters: [String: Any] = ["inputImage": inputImage]
        //guard let filter = CIFilter(name: "CIVignette", parameters: parameters) else { return nil }
        let filter = CIFilter(name: "CIGaussianBlur")!
        self.filter = filter
        self.filterName = filter.name
    }
    
    public func applyFilter(inputImage: CIImage) {
        DispatchQueue.global(qos: .default).async {
            let context = CIContext()
            
            self.filter.setValue(inputImage, forKey: kCIInputImageKey)
            
            let result = self.filter.outputImage!
            let cgImage = context.createCGImage(result, from: result.extent)
            
            let uiimage = UIImage(cgImage: cgImage!)
            self.outputImage = uiimage
        }
    }
}

enum FilterError: Error {
    case instantiationError
}

protocol FilterManagerDelegate: AnyObject {
    func applyFiltersResult(_ result: Result<Bool, FilterError>)
}

class FilterManager {
    
    var filters: [CIFilter] = []
    var filteredImages: [UIImage] = []
    
    var filterObjects: [Filter] = []
    
    let kIntensity = 0.7
    
    var inputImage: UIImage
    
    weak var filterManagerDelegate: FilterManagerDelegate?
    
    init(with image: UIImage) {
        self.inputImage = image
        do {
            //filters = try configurePhotoFilters()
            try configureNewPhotoFilters()
        } catch {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.filterManagerDelegate?.applyFiltersResult(.failure(.instantiationError))
            }
        }
    }
    
    public func configurePhotoFilters() throws -> [CIFilter] {
        
        guard
        let blur            = CIFilter(name: "CIGaussianBlur"),
        let instant         = CIFilter(name: "CIPhotoEffectInstant"),
        let noir            = CIFilter(name: "CIPhotoEffectNoir"),
        let transfer        = CIFilter(name: "CIPhotoEffectTransfer"),
        let unsharpen       = CIFilter(name: "CIUnsharpMask"),
        let monochrome      = CIFilter(name: "CIColorMonochrome"),
        let colorControls   = CIFilter(name: "CIColorControls"),
        let sepia           = CIFilter(name: "CISepiaTone"),
        let composite       = CIFilter(name: "CIHardLightBlendMode"),
        let vignette        = CIFilter(name: "CIVignette")
        else { throw FilterError.instantiationError }
        
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)

        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, composite, vignette]
    }
    
    public func configureNewPhotoFilters() throws {
        if let ci = CIImage(image: inputImage) {
            for _ in 0..<3 {
                guard let blur = BlurFilter(inputImage: ci, inputIntensity: 1.0) else { throw FilterError.instantiationError }
                filterObjects.append(blur)
            }
            for object in 
            DispatchQueue.main.async {
                self.filterManagerDelegate?.applyFiltersResult(.success(true))
            }
        }
    }
    
    public func applyFilters() {
        DispatchQueue.global(qos: .default).async {
            for filter in self.filters {
                let context = CIContext()
                
                let ciImage = CIImage(image: self.inputImage)
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                
                let result = filter.outputImage!
                let cgImage = context.createCGImage(result, from: result.extent)
                
                let uiimage = UIImage(cgImage: cgImage!)
                self.filteredImages.append(uiimage)
            }
            print("applyFilters end with filters count: \(self.filteredImages.count)")
            DispatchQueue.main.async {
                self.filterManagerDelegate?.applyFiltersResult(.success(true))
            }
        }
    }
    
}
