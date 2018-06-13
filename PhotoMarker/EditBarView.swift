//
//  EditBarView.swift
//  PhotoMarker
//
//  Created by 朱慧平 on 2018/6/12.
//  Copyright © 2018年 朱慧平. All rights reserved.
//

import UIKit

class EditBarView: UIView {
    var selectImageCallBack:(()->(Void))?
    var saveImageCallBack:(()->(Void))?
    var changeTextColorCallBack:(()->(Void))?
    var changeFlagCallBack:(()->(Void))?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.3, alpha: 0.8)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.setUI()
    }
   
    func setUI() {
        let selectImageButton = SelectImageButton(view: self)
        self.addSubview(selectImageButton)
        
        let saveImageButton = SaveImageButton(view: self)
        self.addSubview(saveImageButton)
        
        let changeTextColorButton = ChangeTextColorButton(view: self)
        self.addSubview(changeTextColorButton)
        
        let changeFlagButton = ChangeFlagButton(view: self)
        self.addSubview(changeFlagButton)
        
        selectImageButton.snp.makeConstraints { (make) in
            make.height.equalTo(self.snp.height).offset(-14)
            make.width.equalTo(self.snp.width).multipliedBy(0.25).offset(-12.5)
            make.left.equalTo(self.snp.left).offset(10)
            make.top.equalTo(self.snp.top).offset(7)
        }
        saveImageButton.snp.makeConstraints { (make) in
            make.height.equalTo(self.snp.height).offset(-14)
            make.width.equalTo(self.snp.width).multipliedBy(0.25).offset(-12.5)
            make.left.equalTo(selectImageButton.snp.right).offset(10)
            make.top.equalTo(self.snp.top).offset(7)
        }
        changeTextColorButton.snp.makeConstraints { (make) in
            make.height.equalTo(self.snp.height).offset(-14)
            make.width.equalTo(self.snp.width).multipliedBy(0.25).offset(-12.5)
            make.left.equalTo(saveImageButton.snp.right).offset(10)
            make.top.equalTo(self.snp.top).offset(7)
        }
        changeFlagButton.snp.makeConstraints { (make) in
            make.height.equalTo(self.snp.height).offset(-14)
            make.width.equalTo(self.snp.width).multipliedBy(0.25).offset(-12.5)
            make.right.equalTo(self.snp.right).offset(-10)
            make.top.equalTo(self.snp.top).offset(7)
        }
        
    }
    final class SelectImageButton : UIButton{
        convenience init(view:EditBarView){
            self.init()
            setTitle("选择照片", for: UIControlState.normal)
             frame = CGRect(x: 0, y: 7, width: 120, height: 30)
            addTarget(view, action: #selector(view.selectImageButtonClick(sender:)), for: UIControlEvents.touchUpInside)
            setTitleColor(.green, for: .normal)
            setTitleColor(.red, for: .highlighted)
            layer.borderWidth = 1
            layer.borderColor = UIColor.green.cgColor
            layer.masksToBounds = true
            layer.cornerRadius = 5
        }
    }
    final class SaveImageButton : UIButton{
        convenience init(view:EditBarView){
            self.init()
            setTitle("保存照片", for: UIControlState.normal)
            addTarget(view, action: #selector(view.saveImageButtonClick(sender:)), for: UIControlEvents.touchUpInside)
            setTitleColor(.green, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.green.cgColor
            layer.masksToBounds = true
            layer.cornerRadius = 5
        }
    }
    final class ChangeTextColorButton : UIButton{
        convenience init(view:EditBarView){
            self.init()
            setTitle("字体颜色", for: UIControlState.normal)
            addTarget(view, action: #selector(view.changeTextColorButtonClick(sender:)), for: UIControlEvents.touchUpInside)
            setTitleColor(.green, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.green.cgColor
            layer.masksToBounds = true
            layer.cornerRadius = 5
        }
    }
    final class ChangeFlagButton : UIButton{
        convenience init(view:EditBarView){
            self.init()
            setTitle("标注图标", for: UIControlState.normal)
            addTarget(view, action: #selector(view.changeFlagButtonClick(sender:)), for: UIControlEvents.touchUpInside)
            setTitleColor(.green, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.green.cgColor
            layer.masksToBounds = true
            layer.cornerRadius = 5
        }
    }
    @objc func selectImageButtonClick(sender: UIButton) {
        print("select image button click")
        self.selectImageCallBack!()
    }
    @objc func saveImageButtonClick(sender: UIButton) {
        print("save image button click")
        self.saveImageCallBack!()
    }
    @objc func changeTextColorButtonClick(sender:UIButton) {
        print("change text color button click")
        self.changeTextColorCallBack!()
    }
    @objc func changeFlagButtonClick(sender:UIButton) {
        print("change flag button click")
        self.changeFlagCallBack!()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
