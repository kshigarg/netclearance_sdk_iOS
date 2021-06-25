//
//  DeviceOperationViewController.swift
//  Netclearance SDK Demo
//
//  Created by Rushabh Champaneri on 6/22/21.
//

import Foundation
import UIKit
import MBProgressHUD
import Netclearance_SDK
import CoreBluetooth

class DeviceOperationViewController: UIViewController, LogObserver, UITextFieldDelegate {
    
    @IBOutlet weak var txtServiceUUIDs: UITextField!
    @IBOutlet weak var txtCharacteristicUUID: UITextField!
    
    @IBOutlet weak var switchSubscribe: UISwitch!
    @IBOutlet weak var txtDescriptorUUID: UITextField!
    @IBOutlet weak var switchDebug: UISwitch!
    
    @IBOutlet weak var txtWriteData: UITextField!
    
    @IBOutlet weak var textViewLogs: UITextView!
    var device:NCDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NCBluetoothManager.sharedInstance.register(logObserver: self)
        
    }
    
    @IBAction func actionDiscoverAll(_ sender: Any) {
        device?.discover(discoverCallback: { [weak self] (DiscoverServicesCallback) in
            guard let weakSelf = self else {
                return
            }
            switch DiscoverServicesCallback {
            case .successBlock(_):
                weakSelf.showMessage(msg: "Discovery completed")
                break
            case .failure(let error):
                weakSelf.showMessage(msg: error.localizedDescription)
                break
            @unknown default:
                break
            }
        })
    }
    
    @IBAction func actionDiscoverServices(_ sender: Any) {
        let results = getUUIDs()
        
        device?.discoverServices(serviceUUIDs: results.services, discoverCallback: { [weak self] (DiscoverServicesCallback) in
            guard let weakSelf = self else {
                return
            }
            switch DiscoverServicesCallback {
            case .successBlock(_):
                weakSelf.showMessage(msg: "Service Discovery completed")
                break
            case .failure(let error):
                weakSelf.showMessage(msg: error.localizedDescription)
                break
            @unknown default:
                break
            }
        })
    }
    
    @IBAction func actionDisconnect(_ sender: Any) {
        device?.disconnect(disconnectCallback: { [weak self] (CompleteCallback) in
            guard let weakSelf = self else {
                return
            }
            switch CompleteCallback {
            case .successBlock:
                DispatchQueue.main.async{
                    weakSelf.navigationController?.popViewController(animated: true)
                }
                break
            case .failure(let error):
                weakSelf.showMessage(msg: error.localizedDescription)
                break
            @unknown default:
                break
            }
        })
    }
    
    @IBAction func actionDiscoverCharacteristics(_ sender: Any) {
        let results = getUUIDs()
        if results.services.count > 0 {
            device?.discoverChannels(serviceUUID: results.services.first!, discoverCharacteristicCallback: { [weak self]  (DiscoverCharacteristicCallback) in
                guard let weakSelf = self else {
                    return
                }
                switch DiscoverCharacteristicCallback {
                case .successBlock(_):
                    weakSelf.showMessage(msg: "Characteristics Discovery completed")
                    break
                case .failure(let error):
                    weakSelf.showMessage(msg: error.localizedDescription)
                    break
                @unknown default:
                    break
                }
            })
        } else {
            showMessage(msg: "Please enter valid Service UUID")
        }
        
    }
    
    @IBAction func actionDiscoverDescriptors(_ sender: Any) {
        let results = getUUIDs()
        if results.characteristics.count > 0 {
            device?.discoverDescriptors(characteristicUUID: results.characteristics.first!, discoverDescriptorCallback: { [weak self] (DiscoverDescriptorCallback) in
                guard let weakSelf = self else {
                    return
                }
                switch DiscoverDescriptorCallback {
                case .successBlock(_):
                    weakSelf.showMessage(msg: "Descriptor Discovery completed")
                    break
                case .failure(let error):
                    weakSelf.showMessage(msg: error.localizedDescription)
                    break
                @unknown default:
                    break
                }
            })
        } else {
            showMessage(msg: "Please enter valid Characteristic UUID")
        }
    }
    
    @IBAction func actionRead(_ sender: Any) {
        let results = getUUIDs()
        if results.services.count > 0 && results.characteristics.count > 0 {
            device?.readValue(serviceUUID: results.services.first!, characteristicUUID: results.characteristics.first!, getValueCallback: {[weak self] (ReadValueCallback) in
                guard let weakSelf = self else {
                    return
                }
                switch ReadValueCallback {
                case .successBlock(let data):
                    weakSelf.showMessage(msg: "Data read: \(data)")
                    break
                case .failure(let error):
                    weakSelf.showMessage(msg: error.localizedDescription)
                    break
                @unknown default:
                    break
                }
            })
        } else {
            showMessage(msg: "Please enter valid Serivce/Characteristic UUID")
        }
    }
    
    @IBAction func actionWrite(_ sender: Any) {
        let results = getUUIDs()
        if self.txtWriteData.text?.count ?? 0 > 0 {
            if let data = self.txtWriteData.text?.data(using: .ascii) {
                if results.services.count > 0 && results.characteristics.count > 0 {
                    device?.writeValue(serviceUUID: results.services.first!, characteristicUUID: results.characteristics.first!, value: data, writeWithResponse: true, completeCallback: { [weak self] (CompleteCallback) in
                        guard let weakSelf = self else {
                            return
                        }
                        switch CompleteCallback {
                        case .successBlock:
                            weakSelf.showMessage(msg: "Data written successfully")
                            break
                        case .failure(let error):
                            weakSelf.showMessage(msg: error.localizedDescription)
                            break
                        @unknown default:
                            break
                        }
                    })
                } else {
                    showMessage(msg: "Please enter valid Serivce/Characteristic UUID")
                }
            } else {
                showMessage(msg: "Please enter valid data to write")
            }
        }
        else {
            showMessage(msg: "Please enter valid data to write")
        }
    }
    
    @IBAction func actionReadDescriptor(_ sender: Any) {
        let results = getUUIDs()
        if results.services.count > 0 && results.characteristics.count > 0 && results.descriptor.count > 0 {
            device?.readDescriptorValue(serviceUUID: results.services.first!, characteristicUUID: results.characteristics.first!, descUUID: results.descriptor.first!, getValueCallback: {[weak self] (ReadValueCallback) in
                guard let weakSelf = self else {
                    return
                }
                switch ReadValueCallback {
                case .successBlock(let data):
                    weakSelf.showMessage(msg: "Data read: \(data)")
                    break
                case .failure(let error):
                    weakSelf.showMessage(msg: error.localizedDescription)
                    break
                @unknown default:
                    break
                }
            })
        } else {
            showMessage(msg: "Please enter valid Serivce/Characteristic/Descriptor UUID")
        }
    }
    
    @IBAction func actionWriteDescriptor(_ sender: Any) {
        let results = getUUIDs()
        if self.txtWriteData.text?.count ?? 0 > 0 {
            if let data = self.txtWriteData.text?.data(using: .ascii) {
                if results.services.count > 0 && results.characteristics.count > 0 && results.descriptor.count > 0{
                    device?.writeDescriptorValue(serviceUUID: results.services.first!, characteristicUUID: results.characteristics.first!, descUUID: results.descriptor.first!, value: data, completeCallback: {  [weak self] (CompleteCallback) in
                        guard let weakSelf = self else {
                            return
                        }
                        switch CompleteCallback {
                        case .successBlock:
                            weakSelf.showMessage(msg: "Data written successfully")
                            break
                        case .failure(let error):
                            weakSelf.showMessage(msg: error.localizedDescription)
                            break
                        @unknown default:
                            break
                        }
                    })
                } else {
                    showMessage(msg: "Please enter valid Serivce/Characteristic/Descriptor UUID")
                }
            } else {
                showMessage(msg: "Please enter valid data to write")
            }
        } else {
            showMessage(msg: "Please enter valid data to write")
        }
    }
    
    @IBAction func actionSubscribe(_ sender: Any) {
        let results = getUUIDs()
        if results.services.count > 0 && results.characteristics.count > 0 {
            device?.subscribe(serviceUUID: results.services.first!, characteristicUUID: results.characteristics.first!, enable: self.switchSubscribe.isOn, completeCallback: { [weak self] (CompleteCallback) in
                guard let weakSelf = self else {
                    return
                }
                switch CompleteCallback {
                case .successBlock:
                    if weakSelf.switchSubscribe.isOn {
                        weakSelf.showMessage(msg: "Subscribe successfully")
                    } else {
                        weakSelf.showMessage(msg: "Unsubscribe successfully")
                    }
                    break
                case .failure(let error):
                    weakSelf.showMessage(msg: error.localizedDescription)
                    break
                @unknown default:
                    break
                }
            })
        } else {
            showMessage(msg: "Please enter valid Serivce/Characteristic")
        }
        
    }
    
    @IBAction func actionDebug(_ sender: Any) {
        if self.switchDebug.isOn {
            NCBluetoothManager.sharedInstance.register(logObserver: self)
        } else {
            NCBluetoothManager.sharedInstance.unregister(logObserver: self)
        }
    }
    
    func debug(_ text: String) {
        self.textViewLogs.text = "\(self.textViewLogs.text ?? "")\n \(text)"
    }
    
    func showMessage(msg:String) {
        let mbprogressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        mbprogressHUD.label.text = msg
        mbprogressHUD.mode = .text
        mbprogressHUD.hide(animated: true, afterDelay: 3)
    }
    
    func getUUIDs() -> (services: [CBUUID], characteristics: [CBUUID], descriptor: [CBUUID]) {
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
        
        var charuuids: [CBUUID] = []
        if self.txtCharacteristicUUID.text!.count > 0 {
            if let array = self.txtCharacteristicUUID.text?.components(separatedBy: ",") {
                for stringUUID in array {
                    let uuidObj = UUID(uuidString: stringUUID)
                    if uuidObj != nil {
                        let uuid = CBUUID.init(string: stringUUID)
                        charuuids.append(uuid)
                    }
                }
            }
        }
        
        var desuuids: [CBUUID] = []
        if self.txtDescriptorUUID.text!.count > 0 {
            if let array = self.txtDescriptorUUID.text?.components(separatedBy: ",") {
                for stringUUID in array {
                        let uuid = CBUUID.init(string: stringUUID)
                        desuuids.append(uuid)
                }
            }
        }
        
        return (uuids,charuuids,desuuids)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
