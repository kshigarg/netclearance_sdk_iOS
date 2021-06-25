//
//  ScanningViewController.swift
//  Netclearance SDK Demo
//
//  Created by Rushabh Champaneri on 6/22/21.
//

import Foundation
import UIKit
import MBProgressHUD
import Netclearance_SDK
import CoreBluetooth

class ScanningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScanningObserver, UITextFieldDelegate {
    
    func scanningEvent(_ started: Bool) {
        if started {
            self.btnScanning.setTitle("Stop Scanning", for: .normal)
        } else {
            self.btnScanning.setTitle("Start Scanning", for: .normal)
        }
    }
    
    func deviceDiscovered(deviec: NCDevice) {
        
    }
    
    
    var uuids: [CBUUID] = []
    var devices: [NCDevice] = []
    var duration: TimeInterval = 20
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnScanning: UIButton!
    @IBOutlet weak var txtConnectionTimeout: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NCBluetoothManager.sharedInstance.register(scanningObserver: self)
        actionStartScan(self.btnScanning)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func actionStartScan(_ sender: Any) {
        if btnScanning.titleLabel?.text == "Start Scanning" {
            startScan()
            self.btnScanning.setTitle("Stop Scanning", for: .normal)
        } else {
            stopScan()
            self.btnScanning.setTitle("Start Scanning", for: .normal)
        }
    }
    
    @objc func actionConnect(_ sender: UIButton) {
        stopScan()
        let deviceObject = devices[sender.tag]
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let duration = TimeInterval.init(Int(self.txtConnectionTimeout.text ?? "20") ?? 20) 
        deviceObject.connect(timeout_seconds: duration) { [weak self] (CompleteCallback) in
            guard let weakSelf = self else {
                return
            }
            MBProgressHUD.hide(for: weakSelf.view, animated: true)
            switch CompleteCallback {
            case .successBlock:
                weakSelf.switchToDevicePage(device: deviceObject)
                break
            case .failure(let error):
                weakSelf.showMessage(msg: error.localizedDescription)
                break
            @unknown default:
                break
            }
        }
    }
    
    func startScan() {
        self.devices.removeAll()
        self.tblView.reloadData()
        NCBluetoothManager.sharedInstance.startScan(ServiceUUIDs: uuids, ActiveSearching: true, Duration: duration) { [weak self](ScanningCallback) in
            guard let weakSelf = self else {
                return
            }
            switch ScanningCallback {
            
            case .successBlock(let device):
                if (!weakSelf.devices.contains(device)) {
                    weakSelf.devices.append(device)
                    DispatchQueue.main.async{
                        weakSelf.tblView.reloadData()
                    }
                }
                break
            case .failure(let error):
                weakSelf.showMessage(msg: error.localizedDescription)
                break
            @unknown default:
                break
            }
        }
    }
    func stopScan(){
        NCBluetoothManager.sharedInstance.stopScan()
    }
    func showMessage(msg:String) {
        let mbprogressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        mbprogressHUD.label.text = msg
        mbprogressHUD.mode = .text
        mbprogressHUD.hide(animated: true, afterDelay: 3)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deviceDetailsCell = tableView.dequeueReusableCell(withIdentifier: "TblVw_Cell", for: indexPath) as! TblVw_Cell
        let deviceObject = devices[indexPath.row]
        deviceDetailsCell.lblDeviceName.text = deviceObject.device_name
        deviceDetailsCell.lblRSSI.text = "\(deviceObject.rssi.intValue) dbm"
        deviceDetailsCell.lblUUID.text = deviceObject.peripheral_uuid.uuidString
        deviceDetailsCell.lblAdvertisementData.text = deviceObject.advertisement_data.description
        deviceDetailsCell.btnConnect.tag = indexPath.row
        deviceDetailsCell.btnConnect.addTarget(self, action: #selector(actionConnect(_:)), for: .touchUpInside)
        return deviceDetailsCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func switchToDevicePage(device: NCDevice) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let deviceVC =
                mainStoryboard.instantiateViewController(withIdentifier: "DeviceOperationViewController") as? DeviceOperationViewController else { return }
        deviceVC.device = device
        self.navigationController?.pushViewController(deviceVC, animated: true)
    }
}

class TblVw_Cell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblRSSI: UILabel!
    @IBOutlet weak var lblAdvertisementData: UILabel!
    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var btnConnect: UIButton!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
