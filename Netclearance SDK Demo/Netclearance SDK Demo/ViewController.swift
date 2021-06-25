//
//  ViewController.swift
//  Netclearance SDK Demo
//
//  Created by Rushabh Champaneri on 6/21/21.
//

import UIKit
import Netclearance_SDK
import MBProgressHUD
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtServiceUUIDs: UITextField!
    @IBOutlet weak var txtScanningTimeout: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func actionIsBLESupported(_ sender: Any) {
        if NCBluetoothManager.sharedInstance.isBLESupported {
            showMessage(msg: "Bluetooth is supported in this phone")
        } else {
            showMessage(msg:"Bluetooth is not supported in this phone")
        }
    }
    
    @IBAction func actionIsBTON(_ sender: Any) {
        if NCBluetoothManager.sharedInstance.isBluetoothON {
            showMessage(msg: "Bluetooth is ON")
        } else {
            showMessage(msg:"Bluetooth is OFF")
        }
    }
    
    @IBAction func actionIsBTGranted(_ sender: Any) {
        if NCBluetoothManager.sharedInstance.isBluetoothAccessGranted {
            showMessage(msg: "Bluetooth Permission Granted")
        } else {
            showMessage(msg: "Bluetooth Permission Denied")
        }
    }
    
    @IBAction func actionStartScan(_ sender: Any) {
        var uuids: [CBUUID] = []
        if self.txtServiceUUIDs.text!.count > 0 {
            if let array = self.txtServiceUUIDs.text?.components(separatedBy: ",") {
                for stringUUID in array {
                    let uuidObj = UUID(uuidString: stringUUID)
                    if uuidObj != nil {
                        let uuid = CBUUID.init(string: stringUUID)
                        uuids.append(uuid)
                    }
                }
            }
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let scanningVC =
                mainStoryboard.instantiateViewController(withIdentifier: "ScanningViewController") as? ScanningViewController else { return }
        let duration = TimeInterval.init(Int(self.txtScanningTimeout.text ?? "20") ?? 20)
        scanningVC.uuids = uuids
        scanningVC.duration = duration
        self.navigationController?.pushViewController(scanningVC, animated: true)
    }
    
    func showMessage(msg:String) {
        let mbprogressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        mbprogressHUD.label.text = msg
        mbprogressHUD.mode = .text
        mbprogressHUD.hide(animated: true, afterDelay: 3)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

