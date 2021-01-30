//
//  PlayerVC.swift
//  ddmonitor
//
//  Created by apple on 1/18/21.
//

import Cocoa
import AVKit
class PlayerVC: NSViewController {
    
    let roomInfoBase: String = "https://api.live.bilibili.com/xlive/web-room/v1/index/getInfoByRoom?room_id="
    let streamURLBase: String = "https://api.live.bilibili.com/room/v1/Room/playUrl?platform=h5&qn="
    var biliRoomID: String = ""
    let qualityDict = [3: 1500, 2: 1000, 1: 800, 0: 500]
    var selectedQuality = 1
    private var loadOnViewReady: Bool = false
    
    @IBOutlet weak var infoLoadingIndicator: NSProgressIndicator!
    @IBOutlet weak var infoLoadingText: NSTextField!
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var player: AVPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.loadOnViewReady){
            self.requestRoomInfo()
        }
    }
    
    init(nibName: NSNib.Name?, bundle: Bundle?, biliRoomID: String, loadOnViewReady: Bool?){
        super.init(nibName: nibName, bundle: bundle)
        if(loadOnViewReady != nil) {
            self.loadOnViewReady = loadOnViewReady!
        }
        self.biliRoomID = biliRoomID
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setRoomID(biliRoomID: String, bitrate_preset: Int?) {
        self.biliRoomID = biliRoomID
        if(!self.isViewLoaded){
            return
        }
        if(bitrate_preset != nil){
            if(bitrate_preset! < 0 || bitrate_preset! > 3){
                self.selectedQuality = 1
            }
        }
        if(self.biliRoomID == "0" || self.biliRoomID == ""){
            self.infoLoadingIndicator.isHidden = true
            self.infoLoadingText.stringValue = "空闲中"
            return
        }
        self.requestRoomInfo()
    }
    
    public func setQuality(bitrate_preset: Int){
        if(bitrate_preset < 0 || bitrate_preset > 3){
            return
        }
        self.selectedQuality = bitrate_preset
        self.requestRoomInfo()
    }
    
    public func stop(){
        if(!self.isViewLoaded){
            return
        }
    }
    
    private func requestRoomInfo() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = false
            self.infoLoadingIndicator.startAnimation(self)
            self.infoLoadingText.stringValue = "加载房间信息中"
        }
        let url = URL(string: roomInfoBase + biliRoomID)!
        let task = URLSession.shared.dataTask(with: url){(data, response, error) in
            guard data != nil else {return}
            if(error != nil){
                DispatchQueue.main.async {
                    self.infoLoadingIndicator.stopAnimation(self)
                    self.infoLoadingText.stringValue = "加载房间信息中出错"
                }
                return
            }
            do{
                let roomInfo: RoomInfoResponse = try JSONDecoder().decode(RoomInfoResponse.self, from: data!)
                if(roomInfo.data.room_info.live_status != 1) {
                    DispatchQueue.main.async {
                        self.infoLoadingIndicator.isHidden = true
                        self.infoLoadingIndicator.stopAnimation(self)
                        self.infoLoadingText.stringValue = "主播不在线"
                        return
                    }
                }else{
                    self.requestStreamInfo(liveID: String(roomInfo.data.room_info.room_id))
                }
            }catch{
                DispatchQueue.main.async {
                    self.infoLoadingIndicator.stopAnimation(self)
                    self.infoLoadingText.stringValue = "加载房间信息中出错"
                }
            }
        }
        task.resume()
    }
    
    private func requestStreamInfo(liveID: String) {
        DispatchQueue.main.async {
            self.infoLoadingIndicator.startAnimation(self)
            self.infoLoadingText.stringValue = "加载直播信息中"
        }
        let url = URL(string: streamURLBase + String(qualityDict[self.selectedQuality]!)
                        + "&cid=" + liveID)!
        let task = URLSession.shared.dataTask(with: url){(data, response, error) in
            guard data != nil else {return}
            if(error != nil){
                DispatchQueue.main.async {
                    self.infoLoadingIndicator.stopAnimation(self)
                    self.infoLoadingText.stringValue = "加载直播信息中出错"
                }
                return
            }
            do{
                let streamInfo: StreamInfoResponse = try JSONDecoder().decode(StreamInfoResponse.self, from: data!)
                DispatchQueue.main.async {
                    let streamURL = URL(string: streamInfo.data.durl[0].url)
                    self.updatePlayer(streamURL: streamURL!)
                }
            }catch{
                DispatchQueue.main.async {
                    self.infoLoadingIndicator.stopAnimation(self)
                    self.infoLoadingText.stringValue = "加载直播信息中出错"
                }
            }
        }
        task.resume()
    }
    
    private func updatePlayer(streamURL: URL) {
        infoLoadingText.stringValue = "正在加载到播放器"
        let playerAsset = AVAsset(url: streamURL)
        let playerItem = AVPlayerItem(asset: playerAsset)
        let avPlayer = AVPlayer(playerItem: playerItem)
        self.player.player = avPlayer
        avPlayer.play()
        infoLoadingText.stringValue = "已请求播放，请稍后..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.loadingView.isHidden = true
        }
    }

    
}
