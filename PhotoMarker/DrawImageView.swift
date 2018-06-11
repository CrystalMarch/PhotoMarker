//
//  DrawImageView.swift
//  Building360
//
//  Created by 朱慧平 on 2018/6/5.
//  Copyright © 2018年 朱慧平. All rights reserved.
//

import UIKit
import SnapKit
class DrawImageView: UIImageView {
    private lazy var drawView : DrawView = DrawView()
    public var editPointCallBack:(([[String:Any]])->(Void))?
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.image = image
        self.setUI()
    }
    func setUI() {
        drawView.picture = self.image
        addSubview(drawView)
        drawView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func drawPoint(_ point : CGPoint, _ name : String) {
        drawView.drawPointArray.append(["name": name,"precentX":point.x/drawView.frame.size.width,"precentY":point.y/drawView.frame.size.height])
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
                drawView.drawPointArray.append(["precentX" : newPoint.x/drawView.frame.size.width,"precentY":newPoint.y/drawView.frame.size.height,"name":point["name"] as! String])
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
                drawView.drawPointArray.append(["precentX" : precentX,"precentY":precentY,"name":name])
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

}
private class DrawView: UIView{
    var picture : UIImage?
    public var drawPointArray :[[String:Any]] = []
    let attributesDict = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor : UIColor.green]
    let redFlag = UIImage.init(named: "flag_red")
    let greenFlag = UIImage.init(named: "flag_green")
    override func draw(_ rect: CGRect) {
        let picture = UIImage.init(named: "picture")
        picture?.draw(in: rect)
        self.drawView()
    }
    func drawView() {
        for dic in self.drawPointArray {
            let text = dic["name"] as! NSString
            let precentX = dic["precentX"] as! CGFloat
            let precentY = dic["precentY"] as! CGFloat
            greenFlag!.draw(in: CGRect(x:precentX*self.frame.size.width-6,y:precentY*self.frame.size.height-5,width:6,height:9))
            text.draw(at: CGPoint(x:precentX*self.frame.size.width,y:precentY*self.frame.size.height-5), withAttributes: attributesDict)
        }
    }
}
