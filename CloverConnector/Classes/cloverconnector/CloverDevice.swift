//
//  CloverDevice.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
    public typealias ImageClass = UIImage
    func ImagePNGRepresentation(image: ImageClass) -> NSData? {
        return UIImagePNGRepresentation(image)
    }
#else
    import AppKit
    public typealias ImageClass = NSImage
    func ImagePNGRepresentation(image: ImageClass) -> NSData? {
        if let imageData = image.TIFFRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData) {
            return imageRep.representationUsingType(NSBitmapImageFileType.PNG, properties: [:])
        }
        return nil
    }
#endif


class CloverDevice {
    var deviceObservers:NSMutableArray = NSMutableArray()
    
    weak var cloverConnector: ICloverConnector?
    
    var transport:CloverTransport
    var packageName:String? = nil
    
    init (packageName:String, transport:CloverTransport) {
        self.transport = transport
        self.packageName = packageName
    }
    
    func subscribe(_ observer:CloverDeviceObserver) {
        deviceObservers.addObject(observer)
    }
    
    func unsubscribe(_ observer:CloverDeviceObserver) {
        deviceObservers.removeObject(observer)
    }
    
    deinit {
        debugPrint("deinit CloverDevice")
    }
    
    func initialize() {}
    
    func doDiscoveryRequest() {}
    
    func doTxStart(_ payIntent:PayIntent, order:CLVModels.Order.Order?, suppressTipScreen:Bool, requestInfo:String?) {}
    
    func doKeyPress(_ keyPress:KeyPress) {}
    
    func doVoidPayment(_ payment:CLVModels.Payments.Payment, reason:String) {}
    
    func doCaptureAuth(_ paymentID:String, amount:Int, tipAmount:Int) {}
    
    func doOrderUpdate(_ displayOrder:DisplayOrder, orderOperation operation:DisplayOrderModifiedOperation?) {}
    
    func doSignatureVerified(_ payment:CLVModels.Payments.Payment, verified:Bool) {}
    
    func doTerminalMessage(_ text:String) {}
    
    func doPaymentRefund(_ orderId:String, paymentId:String, amount:Int, fullRefund:Bool) {} // manual refunds are handled via doTxStart
    
    func doTipAdjustAuth(_ orderId:String, paymentId:String, amount:Int) {}
    
    func doBreak() {}
    
    @available(*, deprecated, message="use doPrint(_ request:PrintRequest) instead")
    func doPrintText(_ textLines:[String], printRequestId: String?, printDeviceId: String?) {}
    
    func doShowWelcomeScreen() {}
    
    func doShowPaymentReceiptScreen(_ orderId:String, paymentId:String) {}
    
    func doShowThankYouScreen() {}
    
    func doOpenCashDrawer(_ reason:String, deviceId: String?) {}
    
    @available(*, deprecated, message="use doPrint(_ request:PrintRequest) instead")
    func doPrintImage(_ img:ImageClass, printRequestId: String?, printDeviceId: String?) {}
    
    @available(*, deprecated, message="use doPrint(_ request:PrintRequest) instead")
    func doPrintImage(_ url:String, printRequestId: String?, printDeviceId: String?) {}
    
    func doPrint(_ request:PrintRequest) {}
    
    func doRetrievePrinters(_ request:RetrievePrintersRequest) {}
    
    func doRetrievePrintJobStatus(_ request: PrintJobStatusRequest) {}
    
    func dispose() {
        deviceObservers.removeAllObjects()
//        transport
    }
    
    func doCloseout(_ allowOpenTabs:Bool, batchId:String?) {}
    
    func doVaultCard(_ cardEntryMethods:Int) {}
    
    func doAcceptPayment( _ payment:CLVModels.Payments.Payment) {}
    
    func doRejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge) {}
    
    func doRetrievePendingPayments() {}
    
    func doReadCardData(_ payIntent:PayIntent) {}
    
    func doStartActivity( action a:String, payload p:String?, nonBlocking:Bool) {}
    
    func doSendMessageToActivity( action a:String, payload p:String?) {}
    
    func doRetrievePayment(_ externalPaymentId:String) {}
    
    func doRetrieveDeviceStatus(_ sendLast:Bool) {}
    
}
