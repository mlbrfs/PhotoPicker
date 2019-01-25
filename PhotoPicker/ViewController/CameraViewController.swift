//
//  CameraViewController.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/23.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AVKit

class CameraViewController: UIViewController {
    
    fileprivate enum ShootState {
        
        case normal
        
        case done
        
    }
    /// 当前的录制类型
    fileprivate var currentRecordType: FileType
    /// 允许录制的类型
    let recordType: FileType
    private(set) var finishCallback: ((URL)->())?
    init(type: FileType = .all) {
        recordType = type
        currentRecordType = type
        super.init(nibName: nil, bundle: nil)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var shootState = ShootState.normal {
        didSet {
            
            recordButton.progress = 0.0
            
            let recordWH: CGFloat = 80
            let padding: CGFloat = (view.bounds.width - recordWH * 3) / 4
            switch shootState {
            case .normal:
                self.recordButton.isHidden = false
                self.cancelButton.isHidden = false
                self.recordButton.alpha = 0
                self.cancelButton.alpha = 0
                
                reset()
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.doneButton.frame.origin.x = recordWH + padding * 2
                    self.resetButton.frame.origin.x = recordWH + padding * 2
                    
                    self.recordButton.alpha = 1
                    self.cancelButton.alpha = 1
                    
                }) { (_) in
                    self.doneButton.isHidden = true
                    self.resetButton.isHidden = true
                    
                }
            case .done:
                doneButton.isHidden = false
                resetButton.isHidden = false

                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.doneButton.frame.origin.x = padding + (recordWH + padding) * 2
                    self.resetButton.frame.origin.x = padding
                    
                    self.recordButton.alpha = 0
                    self.cancelButton.alpha = 0
                }) { (_) in
                    self.recordButton.isHidden = true
                    self.cancelButton.isHidden = true
                }
            }
        }
    }
    
    //视频捕获会话。它是input和output的桥梁。它协调着intput到output的数据传输
    let captureSession = AVCaptureSession()
    
    //将捕获到的视频输出到文件
    let fileOutput = AVCaptureMovieFileOutput()
    //将捕获到的图片输出
    let pictureOutput = AVCaptureStillImageOutput()
    
    fileprivate var isRecording: Bool = false
    fileprivate var isCancelRecording: Bool = false
    
    var player: AVPlayer?
    
    //录制、保存、返回按钮
    let cancelButton: UIButton = UIButton().then {
        $0.layer.masksToBounds = true
        $0.setImage(UIImage.bundleImage(named: "VideoRecordCancel"), for: .normal)
    }
    
    let recordButton: CameraViewButton = CameraViewButton(frame: .zero).then {
        $0.backgroundColor = UIColor.color(255, 255, 255, 0.85)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 80 * 0.5
    }
    
    let doneButton = CameraViewDoneButton().then {
        $0.backgroundColor = UIColor.white
        $0.tintColor = PhotoPickerManager.shared.options.tintColor
        $0.setImage(UIImage.bundleImage(named: "camera_done")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        $0.layer.cornerRadius = 80 * 0.5

    }
    let resetButton = CameraViewDoneButton().then {
        $0.backgroundColor = UIColor.color(210, 210, 210, 0.9)
        $0.layer.cornerRadius = 80 * 0.5
        $0.layer.masksToBounds = true
        $0.tintColor = UIColor.black
        $0.setImage(UIImage.bundleImage(named: "camera_reset")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        $0.addSubview($0.blurView)
    }
    
    //保存所有的录像片段数组
    var videoAsset: AVAsset?
    //保存所有的录像片段url数组
    var assetURL: String?
    //单独录像片段的index索引
    var appendix: Int32 = 1
    
    var photoView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    
    //最大允许的录制时间（秒）
    let totalSeconds: Float64 = Float64(PhotoPickerManager.shared.options.allowVideoSize.max)
    //每秒帧数
    var framesPerSecond: Int32 = 30
    //剩余时间
    var remainingTime : TimeInterval = PhotoPickerManager.shared.options.allowVideoSize.max
    
    //剩余时间计时器
    var timer: Timer?
    //进度条计时器
    var progressBarTimer: Timer?
    let videoView = UIView()
    
    var videoLayer: CALayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            
            if let videoLayer = videoLayer {
                videoLayer.frame = videoView.bounds
                videoView.layer.addSublayer(videoLayer)
            }
        }
    }
    
    var info: PhotoPickerManagerMediaItem = [:]
    
    var isHidStatusBar: Bool = false
    
    //进度条计时器时间间隔
    var incInterval: TimeInterval = 0.05
    //当前进度条终点位置
    var currentRecordSecond: CGFloat = 0
    
    override func loadView() {
        super.loadView()
        

        view.addSubview(videoView)
        
        view.addSubview(photoView)
        
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.addSubview(resetButton)
        
        view.addSubview(recordButton)

        
        self.shootState = .normal
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCaptureSession()
        
        //设置按钮
        setupButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isHidStatusBar = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let recordWH: CGFloat = 80
        let padding: CGFloat = (view.bounds.width - recordWH * 3) / 4
        
        recordButton.frame = CGRect(x: recordWH + padding * 2, y: statusBarHeight > 20 ? (self.view.bounds.height - 125 - BottomSafeHeight) : (self.view.bounds.height - 125), width: recordWH, height: recordWH)
        cancelButton.frame = CGRect(x: padding + 20, y: recordButton.frame.minY + 20, width: 40, height: 40)
        
        videoView.frame = view.bounds
        videoLayer?.frame = view.bounds
        photoView.frame = view.bounds
        
        switch shootState {
        case .done:
            doneButton.frame = CGRect(x: view.bounds.width - padding - recordWH, y: recordButton.frame.minY, width: recordWH, height: recordWH)
            resetButton.frame = CGRect(x: padding, y: recordButton.frame.minY, width: recordWH, height: recordWH)
        case .normal:
            doneButton.frame = recordButton.frame
            resetButton.frame = recordButton.frame
        }

    }
    
    func createCaptureSession() {
        //视频输入设备
        if let videoDevice = AVCaptureDevice.default(for: AVMediaType.video), let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
            captureSession.addInput(videoInput)
        } else {
            AlertManager.alert(allowPhotos: self, title: LocalizableString.cameraReject) {
                self.navigationController?.dismiss(animated: true, completion: nil)
                PhotoPickerManager.shared.clear()
            }
        }
        //音频输入设备
        if let audioDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio), let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
            captureSession.addInput(audioInput)
        } else {
            AlertManager.alert(allowPhotos: self, title: LocalizableString.cameraReject) {
                self.navigationController?.dismiss(animated: true, completion: nil)
                PhotoPickerManager.shared.clear()
            }
        }
        
        //添加视频捕获输出
        let maxDuration = CMTimeMakeWithSeconds(totalSeconds, preferredTimescale: framesPerSecond)
        fileOutput.maxRecordedDuration = maxDuration
        captureSession.addOutput(fileOutput)
        
        captureSession.addOutput(pictureOutput)
        
        //使用AVCaptureVideoPreviewLayer可以将摄像头的拍摄的实时画面显示在ViewController上
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoLayer = videoLayer
        
        //启动session会话
        captureSession.startRunning()
    }
    
    //创建按钮
    func setupButton(){
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(ges:)))
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTap(ges:)))
        
        singleTap.require(toFail: longTap)
        recordButton.addGestureRecognizer(singleTap)
        recordButton.addGestureRecognizer(longTap)
        
        cancelButton.addTarget(self, action: #selector(onClickCancelButton(_:)), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(onClickResetButton(_:)), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(onClickDoneButton), for: .touchUpInside)
        
    }
    
    //剩余时间计时器
    func startTimer() {
        timer = Timer(timeInterval: remainingTime, target: self, selector: #selector(CameraViewController.timeout), userInfo: nil, repeats:true)
        RunLoop.current.add(timer!, forMode: .default)
    }
    
    //录制时间达到最大时间
    @objc func timeout() {
        stopShootVideo()
    }
    
    //进度条计时器
    func startProgressBarTimer() {
        progressBarTimer = Timer(timeInterval: incInterval, target: self, selector: #selector(CameraViewController.progress), userInfo: nil, repeats: true)
        RunLoop.current.add(progressBarTimer!, forMode: .default)
    }
    
    //修改进度条进度
    @objc func progress() {
        currentRecordSecond += CGFloat(incInterval)
        let progressProportion: CGFloat = CGFloat((currentRecordSecond) / CGFloat(totalSeconds))
        recordButton.progress = progressProportion
    }
    
    @objc func onClickCancelButton(_ sender: UIButton) {
        cancelRecord()
        navigationController?.dismiss(animated: true, completion: nil)
        PhotoPickerManager.shared.clear()
    }
    
    @objc func onClickResetButton(_ sender: UIButton) {
        shootState = .normal
    }
    
    @objc func onClickDoneButton(_ sender: UIButton) {
        
        if currentRecordType == .onlyPhoto {
            finish()
        } else {
            if let _ = assetURL {
                finish()
            } else {
                AlertView.show(LocalizableString.recordingFailed, inView: self.view)
            }
        }
        
    }
    
    func finish() {
        
        PhotoPickerManager.shared.delegate?.photoPickerManager(PhotoPickerManager.shared, didFinishPickingMediaWithInfo: [info])
        PhotoPickerManager.shared.selectedCallback?([info])
        
        navigationController?.dismiss(animated: true, completion: nil)
        PhotoPickerManager.shared.clear()
    }
    
    //录制之后片段
//    func mergeVideos() {
//
//        if currentRecordSecond < CGFloat(PhotoPickerManager.shared.options.allowVideoSize.min) {
//            reset()
//            AlertView.show("录制不得小于3秒", inView: self.view)
//            return
//        }
//
//        if let assetURL = assetURL {
//            let outputURL = URL(fileURLWithPath: assetURL)
//            exportDidFinish(outputURL)
//
//        }
//    }
//    //将合并后的视频保存到相册
//    func exportDidFinish(_ outputURL: URL) {
//
//        //将录制好的录像异步压缩
//        AlertView.showLoading("压缩中...", inView: self.view)
//        let outSession = AVAssetExportSession(asset: AVAsset(url: outputURL), presetName: AVAssetExportPresetMediumQuality)!
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
//                                                        .userDomainMask, true)
//        let documentsDirectory = paths[0] as String
//        let outputFilePath = "\(documentsDirectory)/output.mp4"
//        let exportURL = URL(fileURLWithPath: outputFilePath)
//        let fileManager = FileManager.default
//        if(fileManager.fileExists(atPath: outputFilePath)) {
//            do {
//                try fileManager.removeItem(atPath: outputFilePath)
//            } catch _ {
//            }
//        }
//        //设置导出路径
//        outSession.outputURL = exportURL
//        outSession.outputFileType = AVFileType.mov
//        outSession.shouldOptimizeForNetworkUse = true
//        outSession.exportAsynchronously { [weak self] in
//            guard let s = self else { return }
//            switch outSession.status {
//            case .completed:
//                DispatchQueue.main.async {
//                    AlertView.dismiss()
//                    //WARNING: 这里添加回调
//
//
//
////                    s.finishCallback?(exportURL)
////                    s.onClickCancelButton(s.cancelButton)
//                }
//            default: break
//            }
//        }
//    }
    
    //录像回看
    func reviewRecord(outputURL: URL) {
        //定义一个视频播放器，通过本地文件路径初始化
        let player = AVPlayer(url: outputURL)
        self.player = player
        let videoLayer = AVPlayerLayer(player: player)
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoLayer = videoLayer
        NotificationCenter.default.addObserver(self, selector: #selector(playerReplay), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.play()
        
    }
    @objc func playerReplay(no: NSNotification) {
        
        player?.seek(to: CMTimeMake(value: 0, timescale: 1), toleranceBefore: CMTimeMake(value: 1, timescale: 1), toleranceAfter: CMTimeMake(value: 1, timescale: 1))
        player?.play()
        
    }
    //MARK: 录制
    @objc private func longTap(ges: UIGestureRecognizer) {
        if recordType != .onlyVideo && recordType != .all {
            if ges.state == .ended {
                takePicture()
            }
            return
        }
        
        switch ges.state {
        case .began:
            shootVideo()
        case .cancelled:
            cancelShootVideo()
        case .ended:
            stopShootVideo()
        default: break
        }
    }
    
    func shootVideo() {
        currentRecordType = .onlyVideo
        if isRecording { return }
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let outputFilePath = "\(documentsDirectory)/ml-CameraViewController-recordput.mov"
        let outputURL = URL(fileURLWithPath: outputFilePath)
        let fileManager = FileManager.default
        if(fileManager.fileExists(atPath: outputFilePath)) {
            do {
                try fileManager.removeItem(atPath: outputFilePath)
            } catch _ {
            }
        }
        fileOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true
    }
    func stopShootVideo() {
        fileOutput.stopRecording()
        timer?.invalidate()
        progressBarTimer?.invalidate()
    }
    func cancelShootVideo() {
        isCancelRecording = true
        cancelRecord()
        stopShootVideo()
    }
    
    @objc private func singleTap(ges: UIGestureRecognizer) {
        if recordType == .onlyVideo { return } /// 如果只允许录制视频  那么拍照不可用
        switch ges.state {
        case .ended:
            takePicture()
        default: break
        }
    }
    
    //MARK: 拍照
    func takePicture() {
        currentRecordType = .onlyPhoto

        guard let connection = pictureOutput.connections.filter({ // 每一个connection里inputPorts是否存在 mediaType == .video
            return $0.inputPorts.reduce(false, {
                return $0 ? $0 : $1.mediaType == .video
            })
        }).first else { return }
        
        pictureOutput.captureStillImageAsynchronously(from: connection) { (imageBuffer, error) in
            guard let imageBuffer = imageBuffer else { return }
            if let _ = CMGetAttachment(imageBuffer, key: kCGImagePropertyExifDictionary, attachmentModeOut: nil) {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer)
                
                let image = UIImage(data: imageData!)
                // 这里将图片展示出来
                
                let smallImage = image?.jpegData(compressionQuality: CGFloat(PhotoPickerManager.shared.options.compressRate))
                
                self.photoView.image = image
                self.photoView.isHidden = false
                
                self.info = [:]
                self.info[.mediaType] = PHAssetMediaType.image
                self.info[.originalImage] = image
                self.info[.smallImage] = smallImage
                self.info[.metaData] = imageData
                
                self.shootState = .done
            }
            
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return isHidStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    deinit {
        
        isCancelRecording = true

        if isRecording {
            cancelRecord()
        }
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func reset() {
        
        photoView.image = nil
        photoView.isHidden = true
        
        if currentRecordType == .onlyVideo {
        //使用AVCaptureVideoPreviewLayer可以将摄像头的拍摄的实时画面显示在ViewController上
            let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoLayer = videoLayer
        }
        
        cancelRecord()
    }
    
    func cancelRecord() {
        
        timer?.invalidate()
        progressBarTimer?.invalidate()
        fileOutput.stopRecording()
        //进度条还原
        recordButton.progress = 0
        //删除视频片段
        if let assetURL = assetURL {
            if(FileManager.default.fileExists(atPath: assetURL)) {
                do {
                    try FileManager.default.removeItem(atPath: assetURL)
                } catch _ {
                }
                print("deletedVideo: \(assetURL)")
            }
        }
        
        //各个参数还原
        videoAsset = nil
        assetURL = nil
        appendix = 1
        currentRecordSecond = 0
        remainingTime = totalSeconds
        
    }
    
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    //录像开始的代理方法
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        startProgressBarTimer()
        startTimer()
    }
    //录像结束的代理方法
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        isRecording = false
        if isCancelRecording { return }
        
        let asset = AVURLAsset(url: outputFileURL, options: nil)
        var duration : TimeInterval = 0.0
        duration = CMTimeGetSeconds(asset.duration)
        videoAsset = asset
        assetURL = outputFileURL.path
        remainingTime = remainingTime - duration
        
        if currentRecordSecond < CGFloat(PhotoPickerManager.shared.options.allowVideoSize.min) {
            cancelRecord()
            AlertView.show(LocalizableString.lessThanRecordTime + "\(Int(PhotoPickerManager.shared.options.allowVideoSize.min))" + LocalizableString.second, inView: self.view)
            return
        }
        
        reviewRecord(outputURL: outputFileURL)
        
        info = [:]
        info[.mediaType] = PHAssetMediaType.video
        info[.mediaURL] = outputFileURL
        
        let imageGen = AVAssetImageGenerator.init(asset: asset)
        imageGen.appliesPreferredTrackTransform = true
        imageGen.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        if let image = try? imageGen.copyCGImage(at: CMTime(value: 0, timescale: 60), actualTime: nil) {
            info[.originalImage] = UIImage(cgImage: image)
        }
        
        shootState = .done
        
    }

}
