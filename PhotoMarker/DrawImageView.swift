//
//  DrawImageView.swift
//  Building360
//
//  Created by 朱慧平 on 2018/6/5.
//  Copyright © 2018年 朱慧平. All rights reserved.
//

import UIKit
import SnapKit
import Photos
class DrawImageView: UIImageView {
    private lazy var drawView : DrawView = DrawView()
    public var editPointCallBack:(([[String:Any]])->(Void))?
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.image = image
        self.setUI()
    }
    public func changeImage(image:UIImage?) {
        self.image = image
        drawView.picture = image
        drawView.drawPointArray.removeAll()
        drawView.setNeedsDisplay()
        self.editPointCallBack!(drawView.drawPointArray)
    }
    func setUI() {
        drawView.picture = self.image
        addSubview(drawView)
        drawView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    public func changeTextColor(color: UIColor?) {
        drawView.textColor = color
        drawView.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func drawPoint(_ point : CGPoint, _ name : String, _ icon : String) {
        drawView.drawPointArray.append(["name": name,"precentX":point.x/drawView.frame.size.width,"precentY":point.y/drawView.frame.size.height,"icon":icon])
        drawView.setNeedsDisplay()
        self.editPointCallBack!(drawView.drawPointArray)
    }
    public func removePoint(_ editPoint : CGPoint) {
        for index in 0..<drawView.drawPointArray.count {
            let point = drawView.drawPointArray[index]
            let precentX = point["precentX"] as! CGFloat
            let precentY = point["precentY"] as! CGFloat
            if  CGPoint(x:precentX*drawView.frame.size.width,y:precentY*drawView.frame.size.height) == editPoint {
                drawView.drawPointArray.remove(at: index)
                break //循环体内遇到break语句,程序跳出循环
                //注意
                //return并不是专门用于结束循环结构的关键字眼
                //return是直接结束整个函数,不管这个return处于多少层循环之内
                //continue只是中止本次循环,接着开始下一次循环
            }
        }
        self.editPointCallBack!(drawView.drawPointArray)
        drawView.setNeedsDisplay()
    }
    public func updatePoint(_ originPoint : CGPoint,_ newPoint : CGPoint) {
        for index in 0..<drawView.drawPointArray.count {
            let point = drawView.drawPointArray[index]
            let precentX = point["precentX"] as! CGFloat
            let precentY = point["precentY"] as! CGFloat
            if  CGPoint(x:precentX*drawView.frame.size.width,y:precentY*drawView.frame.size.height) == originPoint {
                drawView.drawPointArray.remove(at: index)
                drawView.drawPointArray.append(["precentX" : newPoint.x/drawView.frame.size.width,"precentY":newPoint.y/drawView.frame.size.height,"name":point["name"] as! String,"icon":point["icon"] as! String])
                break
            }
        }
        self.editPointCallBack!(drawView.drawPointArray)
        drawView.setNeedsDisplay()
    }
    public func renamePoint(_ editPoint : CGPoint,_ name: String) {
        for index in 0..<drawView.drawPointArray.count {
            let point = drawView.drawPointArray[index]
            let precentX = point["precentX"] as! CGFloat
            let precentY = point["precentY"] as! CGFloat
            if  CGPoint(x:precentX*drawView.frame.size.width,y:precentY*drawView.frame.size.height) == editPoint {
                drawView.drawPointArray.remove(at: index)
                drawView.drawPointArray.append(["precentX" : precentX,"precentY":precentY,"name":name,"icon":point["icon"] as! String])
                break
            }
        }
        self.editPointCallBack!(drawView.drawPointArray)
        drawView.setNeedsDisplay()
    }
    public func addOriginPoints(_ points : NSArray){
        drawView.setNeedsDisplay()
    }
    public func updateDisplay(){
        drawView.setNeedsDisplay()//刷新 flag 和 文字 的大小，因为在屏幕发生旋转的时候 imageview的大小也会变化
    }
    public func getDrawViewSize() -> CGSize{
        return drawView.frame.size
    }
    public func saveEditImage(){
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)// 开始截取画图板
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img : UIImage = UIGraphicsGetImageFromCurrentImageContext()! // 截取到的图像
        UIGraphicsEndImageContext() // 结束截取
        /*
         void UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale);
         
         size——同UIGraphicsBeginImageContext
         
         opaque—透明开关,如果图形完全不用透明,设置为YES以优化位图的存储。
         
         scale—–缩放因子
         这里需要判断一下UIGraphicsBeginImageContextWithOptions是否为NULL,因为它是iOS 4.0才加入的
         scale 设置为0图片将不会模糊
         
         */
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: img)
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                showProgressHUD(text: "保存成功",view: self)
            } else{
                showProgressHUD(text: "保存失败",view: self)
                print("保存失败：", error!.localizedDescription)
            }
        }
    }
}
private class DrawView: UIView{
    var picture : UIImage?
    public var textColor :UIColor? = UIColor.green
    
    public var drawPointArray :[[String:Any]] = []
    
    override func draw(_ rect: CGRect) {
        picture?.draw(in: rect)
        self.drawView()
        
    }
    func drawView() {
        let attributesDict = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor : textColor!]
        for dic in self.drawPointArray {
            let text = dic["name"] as! NSString
            let precentX = dic["precentX"] as! CGFloat
            let precentY = dic["precentY"] as! CGFloat
            let icon = dic["icon"] as! String
            let flag = UIImage(named:"GPSMapIcons.bundle/\(icon).png")
            flag!.draw(in: CGRect(x:precentX*self.frame.size.width-(flag?.size.width)!*15/(flag?.size.height)!,y:precentY*self.frame.size.height-7.5,width:(flag?.size.width)!*15/(flag?.size.height)!,height:15))
            text.draw(at: CGPoint(x:precentX*self.frame.size.width+2,y:precentY*self.frame.size.height-7.5), withAttributes: attributesDict)
        }
    }
}
