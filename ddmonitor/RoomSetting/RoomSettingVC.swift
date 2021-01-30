//
//  RoomSettingVC.swift
//  ddmonitor
//
//  Created by apple on 1/30/21.
//

import Cocoa

class RoomSettingVC: NSViewController {

    var totalRooms: Int = 0
    var biliRooms: [String] = []
    var roomInputArr: [RoomInputComponent] = []
    weak var delegate: ViewController!
    
    @IBOutlet weak var inputContainer: NSView!
    init(nibName: NSNib.Name?, bundle: Bundle?,totalRooms: Int, roomIDs: [String]){
        super.init(nibName: nibName, bundle: bundle)
        self.totalRooms = totalRooms
        self.biliRooms = roomIDs
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for i in 0...self.totalRooms - 1{
            var roomID = ""
            if(i > biliRooms.count - 1){
                roomID = ""
            }else{
                roomID = biliRooms[i]
            }
            let roomInputComp = RoomInputComponent(nibName: "RoomInputComponent", bundle: nil, roomID: roomID, playerSeq: i+1)
            self.roomInputArr.append(roomInputComp)
        }
        self.initInputLayout()
    }
    
    func initInputLayout() -> Void {
        let vertStackView = NSStackView()
        var horiStackViewArr: [NSStackView] = []
        vertStackView.translatesAutoresizingMaskIntoConstraints = false
        vertStackView.orientation = NSUserInterfaceLayoutOrientation.vertical
        vertStackView.distribution = NSStackView.Distribution.fillEqually
        
        for i in 0...roomInputArr.count-1{
            if(i % 2 == 0){
                let horiStackView = NSStackView()
                horiStackView.translatesAutoresizingMaskIntoConstraints = false
                horiStackView.orientation = NSUserInterfaceLayoutOrientation.horizontal
                horiStackView.distribution = NSStackView.Distribution.fillEqually
                horiStackViewArr.append(horiStackView)
            }
            let horiStackViewIdx = Int(i / 2)
            horiStackViewArr[horiStackViewIdx].addView(roomInputArr[i].view, in: NSStackView.Gravity.leading)
        }
        for stackView in horiStackViewArr{
            vertStackView.addView(stackView, in: NSStackView.Gravity.leading)
        }
        self.inputContainer.addSubview(vertStackView)
        NSLayoutConstraint.activate([
            vertStackView.topAnchor.constraint(equalTo: self.inputContainer.topAnchor, constant: 0),
            vertStackView.leftAnchor.constraint(equalTo: self.inputContainer.leftAnchor, constant: 0),
            vertStackView.rightAnchor.constraint(equalTo: self.inputContainer.rightAnchor, constant: 0),
            vertStackView.bottomAnchor.constraint(equalTo: self.inputContainer.bottomAnchor, constant: 0),
        ])
    }
    
    @IBAction func handleApply(_ sender: Any) {
        var tempBiliRooms: [String] = []
        for comp in self.roomInputArr{
            tempBiliRooms.append(comp.getRoomID())
        }
        self.biliRooms = tempBiliRooms
        self.delegate?.handleRoomSettingInput(roomIDs: self.biliRooms)
        self.dismiss(self)
    }
    @IBAction func handleDismiss(_ sender: Any) {
        self.dismiss(self)
    }
    
}
