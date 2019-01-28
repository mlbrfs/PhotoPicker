<p align="center">
<img src="https://github.com/121372288/PhotoPicker/blob/master/images/logo.jpg" alt="PhotoPickerKit" title="PhotoPickerKit" width="557"/>
</p>

PhotoPickerKit 是专门用于图片选择的选择器，支持相册选择，拍照，摄像等等。它提供了便捷的选择图片的方式，如果你想要的是图片选择器，那么PhotoPickerKit是你不二的选择。

## Features
- [x] 是否能选择图片
- [x] 是否支持拍照，摄像
- [x] 是否支持设置选择图片的数量
- [x] 是否可以预览图片
- [x] 是否支持多样式
- [x] 是否兼容横屏和iPad
- [x] 是否可以自定义UI
- [x] 是否支持多语言（简体中文和英文）

## Use

`pod 'PhotoPickerKit'`

## PhotoPickerKit
你能很简单的使用这个选择器，使用`PhotoPickerManager.shared`：
```swift
PhotoPickerManager.shared.selectImage(viewController: self) { infos in
    // 这里处理选择到的图片
}
```
<p align="center">
<img src="https://github.com/121372288/PhotoPicker/blob/master/images/PhotoPicker-1.jpg" alt="PhotoPickerKit" title="PhotoPickerKit" width="557"/>
</p>

或者你只需要使用相册时：
```swift
PhotoPickerManager.shared.showLibrary(viewController: self) { infos in
    // 这里处理选择到的图片
}
```
也可能你只想使用相机：
```swift
PhotoPickerManager.shared.showCamera(viewController: self) { infos in
    // 这里处理选择到的图片
}
```
PhotoPickerKit 能帮助你选择图片，你能设置你需要的属性（图片的最大数量，是否能选择视频，以及允许的视频长度等），你还可以定制你自己的主题色，以及选择框的样式。

### A More Advanced Example

如果默认的样式不是你想要的，那么你可以很大程度的自定义这个选择器，例如你的需求是这样的：
1.上面导航条背景色为 蓝色。
2. 主题色为红色。
3.选择框要求是正方形的外形，同时在图片的左上角。
4.不允许选择视频，只能选择图片。
5.图片最多只能选择3张。
6.只需要使用相册。

```swift
PhotoPickerManager.shared.showLibrary(viewController: self, options: [
    .allowType(.onlyPhoto),
    .barColor(UIColor.blue),
    .tintColor(UIColor.red),
    .photoIndicatorStyle(.square),
    .photoIndicatorPosition(.topLeft),
    .optionsAllowed(3)
    ]) { (infos) in
        // 这里处理选择到的图片
    }
```
## Requirements
- iOS 8.0+
- Swift 4.2+

## 关于相册返回`[PhotoPickerManagerMediaItem]` :

`PhotoPickerManagerMediaItem` 是一个 `[PhotoPickerManager.InfoKey: Any]` 集合
`PhotoPickerManagerMediaItem`存储着一个图片或者视频对象内容
```swift
public static let mediaType: PhotoPickerManager.InfoKey  // a PHAssetMediaType 当前对象类型

public static let originalImage: PhotoPickerManager.InfoKey // a UIImage 原图

public static let smallImage: PhotoPickerManager.InfoKey // a UIImage 缩略图

public static let mediaURL: PhotoPickerManager.InfoKey  // an URL 视频的URL

public static let metaData: PhotoPickerManager.InfoKey // an imageData 图片的Data

@available(iOS 9.1, *)
public static let livePhoto: PhotoPickerManager.InfoKey// a PHLivePhoto livePhoto才有

public static let phAsset: PhotoPickerManager.InfoKey  // a PHAsset 相册选择的时候会有asset
```
拿到内容可以只使用原图或者缩略图。如果是视频类型，那么图片就是当前视频的封面

