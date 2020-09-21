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
    
    enum Section {
        case main
    }
    
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
    var dataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionView.backgroundColor = .black

        self.collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
        getImages()
        configureDataSource()
    }
    
    // MARK: Helpers
    
    func getImages() {
        NasaClient.shared.getOpportunityPhotos(page: 0) { [weak self] (roverData, error) in
            guard let self = self else { return }
                guard error == nil else {
                    print("Failed to pull photo data")
                    self.downloadError = true
                    return
                }
                
            self.roverPhotos = roverData!.photos
            self.updateData()
            
            }
        }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Photo>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, photo) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
            cell.photoData = photo
            
            if self.downloadError == true {
                cell.imageState = .failed
                cell.infoLabel.text = "Failed to load"
            }
            
            // Asynchronous Tasks
            switch cell.imageState {
            case .failed:
                cell.infoLabel.text = "Failed to load"
            case .new:
                self.startOperations(for: cell, at: indexPath)
            }
            
            return cell
        })
    }
    
    func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(roverPhotos!)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil) }
        
    }
    
    
    func configureUI() {
        configureNavBar(withTitle: "Opportunity", prefersLargeTitles: true, color: .black, titleColor: .white)
    }
    
    
    // MARK: Operations
    func startOperations(for marsCell: PhotoCell, at indexPath: IndexPath) {
      switch (marsCell.imageState) {
      case .new:
        startDownload(for: marsCell, at: indexPath)
      default:
        NSLog("do nothing")
      }
    }
    
    func startDownload(for marsCell: PhotoCell, at indexPath: IndexPath) {
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

}
//
extension MainCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (contentWidth / 2) - 6
        let height = CGFloat(200)

           return CGSize(width: width, height: height)
       }
}
