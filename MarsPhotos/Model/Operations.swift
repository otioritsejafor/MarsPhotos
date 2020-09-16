//
//  Operations.swift
//  MarsPhotos
//
//  Created by Oti Oritsejafor on 6/23/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation
import SDWebImage

class ImageDownloadOperation: Operation {
    var loadingCompleteHandler: ((Photo) -> Void)?
    let marsCell: MarsCell
    
    init(_ marsCell: MarsCell) {
        self.marsCell = marsCell
    }
    
    override func main() {
        if isCancelled { return }
        
        // TODO: Fetch Rover Image
        DispatchQueue.main.async {
            self.marsCell.cellImageView.sd_setImage(with: URL(string: self.marsCell.photoData!.imgSrc)!, placeholderImage: UIImage(named: "placeholder"), options: [.progressiveLoad]) { (image, _, _, _) in
                
                if image == nil {
                    self.marsCell.imageState = .failed
                }
            }
        }

        if isCancelled {
                 return
               }

    }
    
}

class PendingOperations {
  lazy var downloadsInProgress: [IndexPath: Operation] = [:]
  lazy var downloadQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "Download queue"
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
}

