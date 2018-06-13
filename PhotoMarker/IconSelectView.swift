//
//  IconSelectView.swift
//  PhotoMarker
//
//  Created by 朱慧平 on 2018/6/13.
//  Copyright © 2018年 朱慧平. All rights reserved.
//

import UIKit

class IconSelectView: UIView {
    public var selectedIconCallBack : ((_ icon : String)->(Void))!
    var iconCollectionView : UICollectionView!
    convenience init(){
        self.init(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.size.width*0.7,height:UIScreen.main.bounds.size.height*0.6))
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.green.cgColor
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width:80/1.063 , height: 80)
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
       
        iconCollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        iconCollectionView.backgroundColor = UIColor.clear
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        iconCollectionView.showsVerticalScrollIndicator = false
        iconCollectionView.register(UINib.init(nibName: "IconCellCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "IconCell")
        self.addSubview(iconCollectionView)
        
        let headerLabel = UILabel()
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.textAlignment = .center
        headerLabel.text = "选择标注点图标"
        headerLabel.textColor = UIColor.green
        headerLabel.layer.masksToBounds = true
        headerLabel.layer.cornerRadius = 5
        headerLabel.layer.borderWidth = 1
        headerLabel.layer.borderColor = UIColor.green.cgColor
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.height.equalTo(70)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
        iconCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(80, 10, 10, 10))
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.3, alpha: 0.8)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
private typealias collectionViewDelegate = IconSelectView
extension collectionViewDelegate : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIconCallBack("\(indexPath.row + 1)")
        self.removeFromSuperview()
    }
}
private typealias collectionViewDateSource = IconSelectView
extension collectionViewDateSource : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCellCollectionViewCell
        cell.imageView.image = UIImage(named:"GPSMapIcons.bundle/\(indexPath.row+1).png")
        return cell
        
    }
    
    
}
