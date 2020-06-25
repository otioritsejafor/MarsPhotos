//
//  MainCollectionViewController.swift
//  MarsPhotos
//
//  Created by Oti Oritsejafor on 6/23/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    
    var roverPhotos: [Photo]?
    var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }
    var downloadError = false
    
    let pendingOperations = PendingOperations()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionView.backgroundColor = .purple

        self.collectionView.register(MarsCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        getImages()

    }
    
    // MARK: Helpers
    
    func getImages() {
        NasaClient.shared.getOpportunityPhotos(page: 0) { (roverData, error) in
                guard error == nil else {
                    print("Failed to pull photo data")
                    self.downloadError = true
                    DispatchQueue.main.async {
                        self.reloadView()
                    }
                    return
                }
                
                self.roverPhotos = roverData!.photos
             
                DispatchQueue.main.async {
                    print("reloaded")
                    self.reloadView()
                }
            }
        }
    
    func reloadView() {
        //collectionView.reloadData()
        
        collectionView.performBatchUpdates({
            print("Done")
        }) { (_ ) in
            
        }
        
    }
    
    
    
    func configureUI() {
        configureNavBar(withTitle: "Opportunity", prefersLargeTitles: true, color: .purple, titleColor: .white)
    }
    
    
    // MARK: Operations
    func startOperations(for marsCell: MarsCell, at indexPath: IndexPath) {
      switch (marsCell.imageState) {
      case .new:
        startDownload(for: marsCell, at: indexPath)
      default:
        NSLog("do nothing")
      }
    }
    
    func startDownload(for marsCell: MarsCell, at indexPath: IndexPath) {
      guard pendingOperations.downloadsInProgress[indexPath] == nil else {
        return
      }
          
      let downloader = ImageDownloadOperation(marsCell)
      
      downloader.completionBlock = {
        if downloader.isCancelled {
          return
        }

        DispatchQueue.main.async {
            self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
            
        }
      }
        
      pendingOperations.downloadsInProgress[indexPath] = downloader
      pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    
    // MARK: Collection View Properties

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roverPhotos?.count ?? 25
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MarsCell
        
            if downloadError == true {
                cell.imageState = .failed
                cell.infoLabel.text = "Failed to load"
            }
            
            guard roverPhotos?[indexPath.row] == nil else {
                let photoData = roverPhotos![indexPath.row]
                cell.photoData = photoData
                
                // Asynchronous Tasks
                switch cell.imageState {
                case .failed:
                    cell.infoLabel.text = "Failed to load"
                case .new:
                    startOperations(for: cell, at: indexPath)
                    //collectionView.upda
                }
                return cell
            }

            collectionView.reloadItems(at: [indexPath])
            return cell

    }

}
//
extension MainCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (contentWidth / 2) - 6
        let height = CGFloat(200)

           return CGSize(width: width, height: height)
       }
}
