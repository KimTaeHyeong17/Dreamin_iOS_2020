//
//  ViewController.swift
//  AVFoundationPractice
//
//  Created by TaeHyeong Kim on 2020/08/30.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import MediaPlayer
import Photos


class ViewController: UIViewController {
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    var mergingVideo = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionSelectAndPlay(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        mergingVideo = false
    }
    @IBAction func actionRecordAndSave(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    @IBAction func actionMerge(_ sender: Any) {
        mergingVideo = true
        
    }
    
    @IBAction func actionLoadVid1(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }
    @IBAction func actionLoadVid2(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }
    @IBAction func actionLoadMusic(_ sender: Any) {
        let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
        mediaPickerController.delegate = self
        mediaPickerController.prompt = "Select Audio"
        present(mediaPickerController, animated: true, completion: nil)
    }
    @objc func video(
        _ videoPath: String,
        didFinishSavingWithError error: Error?,
        contextInfo info: AnyObject
    ) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.cancel,
            handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
extension ViewController : UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        switch picker.sourceType {
        case .photoLibrary:
            if mergingVideo {
                dismiss(animated: true, completion: nil)
                
                guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                    mediaType == (kUTTypeMovie as String),
                    let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                    else { return }
                
                let avAsset = AVAsset(url: url)
                var message = ""
                if loadingAssetOne {
                    message = "Video one loaded"
                    firstAsset = avAsset
                } else {
                    message = "Video two loaded"
                    secondAsset = avAsset
                }
                let alert = UIAlertController(
                    title: "Asset Loaded",
                    message: message,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                present(alert, animated: true, completion: nil)
            }else{
                // 1
                guard
                    let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                    mediaType == (kUTTypeMovie as String),
                    let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                    else { return }
                
                // 2
                dismiss(animated: true) {
                    //3
                    let player = AVPlayer(url: url)
                    let vcPlayer = AVPlayerViewController()
                    vcPlayer.player = player
                    self.present(vcPlayer, animated: true, completion: nil)
                }
            }
            
        case .camera:
            dismiss(animated: true, completion: nil)
            
            guard
                let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                // 1
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                // 2
                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                else { return }
            
            // 3
            UISaveVideoAtPathToSavedPhotosAlbum(
                url.path,
                self,
                #selector(video(_:didFinishSavingWithError:contextInfo:)),
                nil)
        default:
            break
        }
    }
    
}
extension ViewController : UINavigationControllerDelegate {
    
}
extension ViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(
        _ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection
    ) {
        // 1
        dismiss(animated: true) {
            // 2
            let selectedSongs = mediaItemCollection.items
            guard let song = selectedSongs.first else { return }
            
            // 3
            let title: String
            let message: String
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                self.audioAsset = AVAsset(url: url)
                title = "Asset Loaded"
                message = "Audio Loaded"
            } else {
                self.audioAsset = nil
                title = "Asset Not Available"
                message = "Audio Not Loaded"
            }
            
            // 4
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // 5
        dismiss(animated: true, completion: nil)
    }
    
}
