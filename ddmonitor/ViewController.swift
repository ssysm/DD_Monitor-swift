//
//  ViewController.swift
//  ddmonitor
//
//  Created by apple on 1/10/21.
//

import Cocoa
import AVKit

class ViewController: NSViewController {
    
    private var playerViewArr: [PlayerVC] = []
    private var videoStackView = NSStackView()
    private let settings = UserDefaults.standard
    
    private var playerRoomIDs: [String] = []
    private var gridLayout: [Int] = [2,2]
    private var globalVolume: Int = 30
    private var quality: Int = 1

    @IBOutlet weak var videoContainer: NSView!
    
    @IBOutlet weak var rowNumber: NSTextField!
    @IBOutlet weak var colNumber: NSTextField!
    @IBOutlet weak var rowStepper: NSStepper!
    @IBOutlet weak var colStepper: NSStepper!
        
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Settings
        self.initUserSetting()
        self.playerRoomIDs = settings.object(forKey:"playerRoomIDs") as? [String] ?? [String]()
        self.globalVolume = settings.integer(forKey: "globalVolume")
        self.gridLayout = settings.object(forKey:"gridLayout") as? [Int] ?? self.gridLayout
        self.quality = settings.integer(forKey: "quality")
        // Steppers
        self.rowStepper.minValue = 1
        self.rowStepper.maxValue = 3
        self.colStepper.minValue = 1
        self.colStepper.maxValue = 3
        self.rowNumber.stringValue = String(self.gridLayout[0])
        self.colNumber.stringValue = String(self.gridLayout[1])
        // Table
        
        // Set Players
        for _ in 0...8 {
            let player = PlayerVC(nibName: "PlayerView", bundle: nil, biliRoomID: "0", loadOnViewReady: false)
            self.playerViewArr.append(player)
        }
        self.updateVideoViews(biliRooms: self.playerRoomIDs, totalRow: self.gridLayout[0], totalCol: self.gridLayout[1])
    }
    
    func initUserSetting(){
        if(settings.integer(forKey: "_macos") == 11){
            return
        }
        let playerRoomIDs: [String] = [],
            globalVolume: Int = 25,
            grid: [Int] = [2,2],
            quality:Int =  1,
            _macos: Int = 11
        settings.set(playerRoomIDs, forKey: "playerRoomIDs")
        settings.set(globalVolume, forKey: "globalVolume")
        settings.set(quality, forKey: "quality")
        settings.set(grid, forKey: "gridLayout")
        settings.set(_macos, forKey: "_macos")
    }
    
    func updateVideoViews(biliRooms: [String], totalRow: Int, totalCol: Int){
        self.videoStackView.removeFromSuperview()
        let vertStackView = NSStackView()
        vertStackView.translatesAutoresizingMaskIntoConstraints = false
        vertStackView.orientation = NSUserInterfaceLayoutOrientation.vertical
        vertStackView.distribution = NSStackView.Distribution.fillEqually
        // Loop player array and set horizontal view
        for row in 0...totalRow-1 {
            let rowStackView = NSStackView()
            rowStackView.orientation = NSUserInterfaceLayoutOrientation.horizontal
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
            rowStackView.distribution = NSStackView.Distribution.fillEqually
            for col in 0...totalCol-1{
                let idxNum = (row * totalRow) + col
                var roomID = "0"
                if(idxNum > biliRooms.count - 1){
                    roomID = "0"
                }else{
                    roomID = biliRooms[idxNum]
                }
                DispatchQueue.main.async {
                    self.playerViewArr[idxNum].setRoomID(biliRoomID: roomID, bitrate_preset: self.quality)
                }
                rowStackView.addView(self.playerViewArr[idxNum].view, in: NSStackView.Gravity.leading)
            }
            vertStackView.addView(rowStackView, in: NSStackView.Gravity.leading)
        }
        // set stack view in container and set anchor
        self.videoStackView = vertStackView
        self.videoContainer.addSubview(self.videoStackView)
        NSLayoutConstraint.activate([
            vertStackView.topAnchor.constraint(equalTo: videoContainer.topAnchor, constant: 5),
            vertStackView.leftAnchor.constraint(equalTo: videoContainer.leftAnchor, constant: 5),
            vertStackView.rightAnchor.constraint(equalTo: videoContainer.rightAnchor, constant: -5),
            vertStackView.bottomAnchor.constraint(equalTo: videoContainer.bottomAnchor, constant: -5),
        ])
    }

    func handleRoomSettingInput(roomIDs: [String]){
        self.updateVideoViews(biliRooms: roomIDs, totalRow: self.gridLayout[0], totalCol: self.gridLayout[1])
    }
    
    @IBAction func handleRelayout(_ sender: Any) {
        self.updateVideoViews(biliRooms: self.playerRoomIDs, totalRow: self.gridLayout[0], totalCol: self.gridLayout[1])
    }
    @IBAction func handleRowStepper(_ sender: NSStepper) {
        if(sender.intValue > 3 || sender.intValue < 1){
            return;
        }
        self.rowNumber.stringValue = sender.stringValue
        self.gridLayout[0] = Int(sender.intValue)
    }
    @IBAction func handleColStepper(_ sender: NSStepper) {
        if(sender.intValue > 3 || sender.intValue < 1){
            return;
        }
        self.colNumber.stringValue = sender.stringValue
        self.gridLayout[1] = Int(sender.intValue)
    }
    @IBAction func handleOpenRoomSetting(_ sender: Any) {
        let roomSetting = RoomSettingVC(nibName: "RoomSettingView", bundle: nil, totalRooms: self.gridLayout[0] * self.gridLayout[1], roomIDs: self.playerRoomIDs)
        roomSetting.delegate = self
        self.presentAsSheet(roomSetting)
    }
    
    
}
