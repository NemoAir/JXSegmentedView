//
//  JXSegmentedTitleImageMixCellDataSource.swift
//  JXSegmentedViewExample
//
//  Created by Nemo on 2023/12/13.
//  Copyright © 2023 jiaxin. All rights reserved.
//

import Foundation
import JXSegmentedView
import UIKit


public enum JXSegmentedTitleMixImageType {
    /// title
    case title(String)
    /// 普通、选中图片, 图片size
    case image(String, String, CGSize)
}

open class JXSegmentedTitleMixImageDataSource: JXSegmentedTitleDataSource {
    open var titleMixImageTypes: [JXSegmentedTitleMixImageType] = [] {
        didSet {
            titles = titleMixImageTypes.map({ item in
                switch item {
                case .title(let title):
                    return title
                case .image:
                    return ""
                }
            })
        }
    }
    
    /// 内部默认通过UIImage(named:)加载图片。如果传递的是图片网络地址或者想自己处理图片加载逻辑，可以通过该闭包处理。
    open var loadImageClosure: LoadImageClosure?

    /// 是否开启图片缩放
    open var isImageZoomEnabled: Bool = false
    /// 图片缩放选中时的scale
    open var imageSelectedZoomScale: CGFloat = 1.2
    
    open override func preferredItemCount() -> Int {
        return titleMixImageTypes.count
    }
    
    open override func preferredItemModelInstance() -> JXSegmentedBaseItemModel {
        return JXSegmentedTitleImageItemModel()
    }

    open override func preferredRefreshItemModel(_ itemModel: JXSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)

        guard let itemModel = itemModel as? JXSegmentedTitleImageItemModel else {
            return
        }
        
        let titleMixImage = titleMixImageTypes[index]
        switch titleMixImage {
            case .title(let title):
                itemModel.titleImageType = .onlyTitle
                itemModel.title = title
            
            case let .image(normal, selected, size):
                itemModel.titleImageType = .onlyImage
                itemModel.normalImageInfo = normal
                itemModel.selectedImageInfo = selected
                itemModel.imageSize = size
        }
        
        itemModel.loadImageClosure = loadImageClosure
        itemModel.isImageZoomEnabled = isImageZoomEnabled
        itemModel.imageNormalZoomScale = 1
        itemModel.imageSelectedZoomScale = imageSelectedZoomScale

        if index == selectedIndex {
            itemModel.imageCurrentZoomScale = itemModel.imageSelectedZoomScale
        }else {
            itemModel.imageCurrentZoomScale = itemModel.imageNormalZoomScale
        }
    }

    open override func preferredSegmentedView(_ segmentedView: JXSegmentedView, widthForItemAt index: Int) -> CGFloat {
        var width = super.preferredSegmentedView(segmentedView, widthForItemAt: index)
        if itemWidth == JXSegmentedViewAutomaticDimension {
            let itemModel = self.dataSource[index] as! JXSegmentedTitleImageItemModel
            switch itemModel.titleImageType {
            case .leftImage, .rightImage:
                width +=  itemModel.imageSize.width
            case .topImage, .bottomImage:
                width = max(itemWidth, itemModel.imageSize.width)
            case .onlyImage:
                width = itemModel.imageSize.width
            case .onlyTitle:
                break
            }
        }
        return width
    }


    //MARK: - JXSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(JXSegmentedTitleImageCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }

    open override func refreshItemModel(_ segmentedView: JXSegmentedView, leftItemModel: JXSegmentedBaseItemModel, rightItemModel: JXSegmentedBaseItemModel, percent: CGFloat) {
        super.refreshItemModel(segmentedView, leftItemModel: leftItemModel, rightItemModel: rightItemModel, percent: percent)

        guard let leftModel = leftItemModel as? JXSegmentedTitleImageItemModel, let rightModel = rightItemModel as? JXSegmentedTitleImageItemModel else {
            return
        }
        if isImageZoomEnabled && isItemTransitionEnabled {
            leftModel.imageCurrentZoomScale = JXSegmentedViewTool.interpolate(from: imageSelectedZoomScale, to: 1, percent: CGFloat(percent))
            rightModel.imageCurrentZoomScale = JXSegmentedViewTool.interpolate(from: 1, to: imageSelectedZoomScale, percent: CGFloat(percent))
        }
    }

    open override func refreshItemModel(_ segmentedView: JXSegmentedView, currentSelectedItemModel: JXSegmentedBaseItemModel, willSelectedItemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)

        guard let myCurrentSelectedItemModel = currentSelectedItemModel as? JXSegmentedTitleImageItemModel, let myWillSelectedItemModel = willSelectedItemModel as? JXSegmentedTitleImageItemModel else {
            return
        }

        myCurrentSelectedItemModel.imageCurrentZoomScale = myCurrentSelectedItemModel.imageNormalZoomScale
        myWillSelectedItemModel.imageCurrentZoomScale = myWillSelectedItemModel.imageSelectedZoomScale
    }
}
