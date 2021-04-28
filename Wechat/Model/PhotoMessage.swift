//
//  PhotoMessage.swift
//  Wechat
//
//  Created by Max Wen on 12/27/20.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject,MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path:String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "logo")!
        self.size = CGSize(width: 200, height: 200)
        
    }
}
