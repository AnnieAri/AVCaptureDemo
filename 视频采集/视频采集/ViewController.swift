//
//  ViewController.swift
//  视频采集
//
//  Created by Ari on 2017/6/22.
//  Copyright © 2017年 com.Ari. All rights reserved.
//  如有雷同 你我师出同门或者你就是师傅

import UIKit
import AVFoundation
class ViewController: UIViewController {

    //创建捕捉会话
    fileprivate var session :AVCaptureSession? = AVCaptureSession()
//    fileprivate var videoconnection: AVCaptureConnection?
    fileprivate var videoOutput: AVCaptureOutput?
    fileprivate var previewLayer: CALayer?
    fileprivate var videoInput: AVCaptureDeviceInput?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化视频输入输出
        setupVideoInputOutput()
        //初始化音频输入输出
        setupAudioInputOutput()
        //初始化预览图层
        setupPreviewLayer()
    }



}
// MARK: - 对采集的控制方法
extension ViewController {
    @IBAction func startCapture(_ sender: Any) {
        if videoInput == nil {
            setupVideoInputOutput()
            setupAudioInputOutput()
            setupPreviewLayer()
        }
        session?.startRunning()
        
    }

    @IBAction func endCapture(_ sender: Any) {
        //移除图层
        previewLayer?.removeFromSuperlayer()
        session?.stopRunning()
        videoInput = nil
        previewLayer = nil
        session = nil
    }
    //切换摄像头
    @IBAction func chageCamera(_ sender: Any) {
        guard let session = session else { return }
        //0.添加动画效果
        let rotaionAnim = CATransition()
        rotaionAnim.type = "oglFlip"
        rotaionAnim.subtype = "fromLeft"
        rotaionAnim.duration = 0.5
        view.layer.add(rotaionAnim, forKey: nil)
        
        //1.取出之前镜头的方向
        guard let videoInput = videoInput else { return}
        let oritation: AVCaptureDevicePosition = videoInput.device.position == .front ? .back : .front
        guard let devices = AVCaptureDevice.devices() as?[AVCaptureDevice] else{return}
        guard let device = devices.filter({$0.position == oritation}).first else {return}
        guard let newInput = try? AVCaptureDeviceInput(device: device) else {return}
        
        let newOutput = AVCaptureVideoDataOutput()
        newOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        
        //移除之前的input 添加新的input
        session.removeInput(videoInput)
        session.removeOutput(videoOutput)
        addInputOutput2session(newInput, newOutput)
        self.videoInput = newInput
        videoOutput = newOutput
//        videoconnection = newOutput.connection(withMediaType: AVMediaTypeVideo)
        
    }
    
}
//初始化方法
extension ViewController {
    fileprivate func setupVideoInputOutput(){
        if session == nil {
            session = AVCaptureSession()
        }
        //1.添加视频的输入
        /**
         AVCaptureDevice.defaultDevice(withDeviceType: <#T##AVCaptureDeviceType!#>, mediaType: <#T##String!#>, position: <#T##AVCaptureDevicePosition#>)  --- 10.0以后的方法
         
         AVCaptureDevice.defaultDevice(withMediaType: <#T##String!#>)  -- 这个方法不适用因为不能选择前置还是后置摄像头
         */
        
        guard let devices = AVCaptureDevice.devices() as?[AVCaptureDevice] else{return}
        guard let device = devices.filter({$0.position == .front}).first else {return}
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        self.videoInput = input
        //2.添加视频的输出
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        addInputOutput2session(input, output)
        videoOutput = output
//        videoconnection = output.connection(withMediaType: AVMediaTypeVideo)
    }
    
    fileprivate func setupAudioInputOutput(){
        //1.创建输入
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) else { return }
        guard let input = try?AVCaptureDeviceInput(device:device) else { return }
        
        //2.创建输出
        let output = AVCaptureAudioDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        addInputOutput2session(input, output)
        
    }
    
    fileprivate func addInputOutput2session(_ input: AVCaptureInput ,_ output: AVCaptureOutput){
        guard let session = session else { return }
         session.beginConfiguration()
        //3.添加输入输出
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }

        //完成配置
        session.commitConfiguration()
    }
    
    fileprivate func setupPreviewLayer(){
        //创建预览图层
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: session) else { return }
        
        //设置previewLayer的属性
        previewLayer.frame = view.bounds
        self.previewLayer = previewLayer
        //将图层添加到控制器的view的layer中
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    
 
    //丢弃掉的
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
    
    //两个代理实际采集代理方法一致  所以要区分
    //实际输出的
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print(connection.output)
        
//        if videoOutput?.connection(withMediaType: AVMediaTypeVideo) == connection {
//             print("视频采集")
//        }else{
//            print("音频采集")
//        }
    }
}
