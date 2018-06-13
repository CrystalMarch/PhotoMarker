//
//  PictureViewController.swift
//  Building360
//
//  Created by 朱慧平 on 2018/6/4.
//  Copyright © 2018年 朱慧平. All rights reserved.
//

import UIKit
import MBProgressHUD
import EFColorPicker

class PictureViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate,EFColorSelectionViewControllerDelegate {
    var SCALE_MAX:CGFloat = 3
    var SCALE_MIN:CGFloat = 1
    var imageView:DrawImageView!
    var editBar:EditBarView!
    var chosedFlagString:String! = "1"
    
    var lastScale:CGFloat = 1
    var addNodeAlert : UIAlertController!
    var editNodeAlert : UIAlertController!
    var renameNodeAlert : UIAlertController!
    
    var tapPoint : CGPoint?
    var tapPoints : [[String:Any]] = []
    var imageName:String!
    var isUpdateState : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        imageName = "picture"//之后这个值应该从别的controller中传过来
        
        let image = UIImage(named: imageName)!
        imageView = DrawImageView(image: image)
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)
        initImageView()
        initAlertView()
        initEditBar()
        
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(self.onPinch(sender:)))
        imageView.addGestureRecognizer(pinch)
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.onPan(sender:)))
        imageView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.onTap(sender:)))
        imageView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiverNotification), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    @objc func receiverNotification() {
        //旋转时，禁止操作
        addNodeAlert.dismiss(animated: true, completion: nil)
        editNodeAlert.dismiss(animated: true, completion: nil)
        renameNodeAlert.dismiss(animated: true, completion: nil)
        
        self.imageWithOrientationChange()
    }
    
    @objc func onPinch(sender: UIPinchGestureRecognizer) {
        lastScale *= sender.scale
        
        //禁止过大过小
        if lastScale > SCALE_MAX {
            lastScale = SCALE_MAX
        }else if lastScale < SCALE_MIN {
            lastScale = SCALE_MIN
        }
        
        self.imageView.transform = CGAffineTransform.init(scaleX: lastScale, y: lastScale)
        sender.scale = 1
        
        //平移后的位置
        var centerX = imageView.center.x
        var centerY = imageView.center.y
        let originCenterX = centerX
        let originCenterY = centerY
        boundCenter(centerX: &centerX, centerY: &centerY)
        if originCenterX != centerX || originCenterY != centerY {
            UIView.animate(withDuration: 0.2) {
                self.imageView.center = CGPoint(x:centerX,y:centerY)
            }
        }
    }
    @objc func onPan(sender: UIPanGestureRecognizer) {
        let translate = sender.translation(in: self.view)
        //平移后的位置
        var centerX = imageView.center.x + translate.x
        var centerY = imageView.center.y + translate.y
        let originCenterX = centerX
        let originCenterY = centerY
        boundCenter(centerX: &centerX, centerY: &centerY)
        if originCenterX != centerX || originCenterY != centerY {
            UIView.animate(withDuration: 0.2) {
                self.imageView.center = CGPoint(x:centerX,y:centerY)
            }
        }
        sender.setTranslation(CGPoint.zero, in: sender.view)
    }
    @objc func onTap(sender: UITapGestureRecognizer){
        addNodeAlert.textFields?.first?.text = nil
        let newPoint = sender.location(in: imageView) //point 相对于图片的位置，图片缩放以后，发现point点的坐标并没有随着图片的缩放比例而变化
        var isContain = false
        for index in 0..<tapPoints.count {
            let dic = tapPoints[index]
            let precentX = dic["precentX"] as! CGFloat
            let precentY = dic["precentY"] as! CGFloat
            let point = CGPoint(x:precentX*imageView.getDrawViewSize().width,y:precentY*imageView.getDrawViewSize().height)
            if fabsf(Float(point.x - newPoint.x)) < Float(20/lastScale) && fabsf(Float(point.y - newPoint.y)) < Float(20/lastScale) {
                isContain = true
                if !isUpdateState{
                     tapPoint = point
                }
            }
        }
        
        if isUpdateState {
            
            if isContain {
                showProgressHUD(text: "该位置已被占用，请重新选择",view: self.view)
            }else{
                isUpdateState = false
                imageView.updatePoint(tapPoint!, newPoint)
                tapPoint = newPoint
            }
        }else{
            
            if isContain {
                self.present(editNodeAlert, animated: true, completion: nil)
            }else{
                tapPoint = newPoint
                self.present(addNodeAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    func initAlertView() {
        addNodeAlert = UIAlertController.init(title: "采集点名称", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        addNodeAlert.addTextField { (textField) in
            
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (cancelAction) in
            
        }
        addNodeAlert.addAction(cancelAction)
        let addAction = UIAlertAction.init(title: "添加", style: UIAlertActionStyle.default) { (addAction) in
            print("tap point : \(self.tapPoint!)")
            self.imageView.drawPoint(self.tapPoint!, self.addNodeAlert.textFields!.first!.text!,self.chosedFlagString)
            
        }
        addNodeAlert.addAction(addAction)
        
        renameNodeAlert = UIAlertController.init(title: "修改采集点名称", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        renameNodeAlert.addTextField { (textField) in
            
        }
        let renameCancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (cancelAction) in
            
        }
        renameNodeAlert.addAction(renameCancelAction)
        let changeAction = UIAlertAction.init(title: "修改", style: UIAlertActionStyle.default) { (changeAction) in
          self.imageView.renamePoint(self.tapPoint!, self.renameNodeAlert.textFields!.first!.text!)
        }
        renameNodeAlert.addAction(changeAction)
        if isIPad() {
            editNodeAlert = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        }else{
         editNodeAlert = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        }
        let removeAction = UIAlertAction.init(title: "删除采集点", style: UIAlertActionStyle.default) { (removeAction) in
            self.imageView.removePoint(self.tapPoint!)
        }
        editNodeAlert.addAction(removeAction)
        let updateAction = UIAlertAction.init(title: "修改采集点位置", style: UIAlertActionStyle.default) { (updateAction) in
            self.isUpdateState = true
        }
        editNodeAlert.addAction(updateAction)
        let renameAction = UIAlertAction.init(title: "采集点重命名", style: UIAlertActionStyle.default) { (renameAction) in
            self.renameNodeAlert.textFields?.first?.text = nil
            self.present(self.renameNodeAlert, animated: true, completion: nil)
        }
        editNodeAlert.addAction(renameAction)
        let cancelEditAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (cancelEditAction) in
            
        }
        editNodeAlert.addAction(cancelEditAction)
    }
    func imageWithOrientationChange() {
        let image = imageView.image!
        //初始化imageView的大小
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        var mainWidth = self.view.frame.width
        var mainHeight = self.view.frame.height
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            mainWidth = max(self.view.frame.width, self.view.frame.height)
            mainHeight = min(self.view.frame.width, self.view.frame.height)
        }else if UIDevice.current.orientation == UIDeviceOrientation.portrait || UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            mainWidth = min(self.view.frame.width, self.view.frame.height)
            mainHeight = max(self.view.frame.width, self.view.frame.height)
        }
        
        var destX:CGFloat
        var destY:CGFloat
        var destWidth:CGFloat
        var destHeight:CGFloat
        
        if imageWidth * mainHeight > imageHeight * mainWidth {
            destWidth = mainWidth
            destHeight = imageHeight * mainWidth / imageWidth
            destX = 0
            destY = (mainHeight - destHeight)/2
        }else{
            destWidth = imageWidth * mainHeight / imageHeight
            destHeight = mainHeight
            destX = (mainWidth - destWidth)/2
            destY = 0
        }
        imageView.snp.updateConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(destY)
            make.left.equalTo(self.view.snp.left).offset(destX)
            make.width.equalTo(destWidth)
            make.height.equalTo(destHeight)
        }
        imageView.updateDisplay()
        
    }
    func initImageView(){
        imageView.editPointCallBack = { (points) -> Void in
            self.tapPoints = points
        }
    }
    func initEditBar() {
        editBar = EditBarView()
        self.view.addSubview(editBar)
        editBar.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.height.equalTo(64)
        }
        editBar.selectImageCallBack = { () -> Void in
            self.selectImage()
        }
        editBar.saveImageCallBack = {() -> Void in
            self.imageView.saveEditImage()
        }
        editBar.changeTextColorCallBack = { () -> Void in
            let colorSelectionController = EFColorSelectionViewController()
            let navCtrl = UINavigationController(rootViewController: colorSelectionController)
            navCtrl.navigationBar.backgroundColor = UIColor.white
            navCtrl.navigationBar.isTranslucent = false
            navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
            navCtrl.popoverPresentationController?.delegate = self
            navCtrl.popoverPresentationController?.sourceView = self.editBar
            navCtrl.popoverPresentationController?.sourceRect = self.editBar.bounds
            navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
                UILayoutFittingCompressedSize
            )
            
            colorSelectionController.delegate = self
            colorSelectionController.color = self.view.backgroundColor ?? UIColor.white
            
            if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
                let doneBtn: UIBarButtonItem = UIBarButtonItem(
                    title: NSLocalizedString("Done", comment: ""),
                    style: UIBarButtonItemStyle.done,
                    target: self,
                    action: #selector(self.ef_dismissViewController(sender:))
                )
                colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
            }
            self.present(navCtrl, animated: true, completion: nil)
        }
        editBar.changeFlagCallBack = { () -> Void in
            let iconView = IconSelectView()
            self.view.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.center.equalTo(self.view.snp.center)
                make.height.equalTo(self.view.snp.height).multipliedBy(0.5)
                make.width.equalTo(self.view.snp.width).multipliedBy(0.6)
            })
            iconView.selectedIconCallBack = { (icon) -> Void in
                self.chosedFlagString = icon
            }
        }
    }
    // MARK:- EFColorSelectionViewControllerDelegate
    func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        imageView.changeTextColor(color: color)
        // TODO: You can do something here when color changed.
        print("New color: " + color.debugDescription)
    }
    // MARK:- Private
    @objc func ef_dismissViewController(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            [weak self] in
            if let _ = self {
                // TODO: You can do something here when EFColorPicker close.
                print("EFColorPicker closed.")
            }
        }
    }
    func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        imageView.changeImage(image: image)
        self.imageWithOrientationChange()
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // 限制iamgeView中心的位置
    //当图片大于屏幕时,平移图片时防止平移过头
    func boundCenter( centerX:inout CGFloat, centerY:inout CGFloat){
        let mainFrame = self.view.frame
        let imageFrame = imageView.frame
        imageView.center = CGPoint(x:centerX,y:centerY)
        if imageFrame.width < mainFrame.width {
            centerX = mainFrame.width / 2
        }else{
            let xMin = mainFrame.width - imageFrame.size.width / 2
            let xMax = imageFrame.size.width / 2
            if centerX > xMax {
                centerX = xMax
            }else if centerX < xMin {
                centerX = xMin
            }
        }
        
        if imageFrame.height < mainFrame.height {
            centerY = mainFrame.height / 2
        }else{
            let yMin = mainFrame.height - imageFrame.size.height / 2
            let yMax = imageFrame.size.height / 2
            if centerY > yMax {
                centerY = yMax
            }else if centerY < yMin {
                centerY = yMin
            }
        }
        
    }
    func isIPad() -> Bool {
        if UIDevice.current.model == "iPad" {
            return true
        }
        return false
    }
}
