//
//  IconCellCollectionViewCell.swift
//  PhotoMarker
//
//  Created by 朱慧平 on 2018/6/13.
//  Copyright © 2018年 朱慧平. All rights reserved.
//

import UIKit

class IconCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        imageView.contentMode = UIViewContentMode.scaleAspectFit
    }

}
