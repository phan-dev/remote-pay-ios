//
//  RegisterViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class RegisterViewController:UIViewController, POSOrderListener, POSStoreListener, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var currentOrderListItems: UITableView!
    @IBOutlet weak var currentOrderView: UIView!
    @IBOutlet weak var storeView: UIView!
    var startingPoint:CGRect?
    private var store:POSStore?
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var discountsLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    private var signatureVerifyRequest:VerifySignatureRequest?
    
    @IBOutlet weak var currentOrderBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var currentOrderHeight: NSLayoutConstraint!
    @IBOutlet weak var storeViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var currentView: UIView!
    @IBOutlet var parentView: UIView!
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        store = (UIApplication.sharedApplication().delegate as! AppDelegate).store!
        ((UIApplication.sharedApplication()).delegate as! AppDelegate).cloverConnectorListener?.parentViewController = self
    
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchCurrentOrderView))
        currentOrderView.addGestureRecognizer(gesture);
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(panCurrentOrderView))
        currentOrderView.addGestureRecognizer(dragGesture)
        
        store?.addCurrentOrderListener(self)
        store?.addStoreListener(self)
        
        startingPoint = currentOrderView.frame
        
        //UILongPressGestureRecognizer(target: currentOrderListItems, action: #selector(handleLongPress))
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnectorListener?.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnectorListener?.viewController = self
    }
    
    @IBAction func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        var cgPoint = sender.locationInView(self.currentOrderListItems)
        
        var indexPath = currentOrderListItems.indexPathForRowAtPoint(cgPoint)
        
        if indexPath == nil {
            // not on a row..
        } else if sender.state == UIGestureRecognizerState.Ended {
            if let data = store?.currentOrder?.items[indexPath!.row] {
                store?.currentOrder?.removeLineItem(data)
            }
        }
    }
    /*func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        var cgPoint = gestureRecognizer.locationInView(self.currentOrderListItems)
        
        var indexPath = currentOrderListItems.indexPathForRowAtPoint( cgPoint)
        
        if indexPath == nil {
            // not on a row..
        } else if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            if let data = store?.currentOrder?.items.objectAtIndex((indexPath! as NSIndexPath).row) as? POSLineItem {
                store?.currentOrder?.removeLineItem(data)
            }
        }
    }*/
    
    var startPan:CGPoint?
    var startOffset:CGFloat = 0.0
    
    func panCurrentOrderView(_ sender:UIPanGestureRecognizer) {
        
        
        //var p:CGPoint = currentOrderView.locationInView(parentView)
        var center:CGPoint = CGPoint.zero
        center = sender.locationInView(currentOrderView)
        
        
        switch sender.state {
        case .Began:
            debugPrint("began")
            startPan = sender.locationInView(currentOrderView)
            startOffset = self.storeViewTop.constant
            debugPrint("Starting at " + String(self.startPan!.x) + ", " + String(self.startPan!.y))
            //self.selectedView = view.hitTest(p, withEvent: nil)
            //if self.selectedView != nil {
            //    self.view.bringSubviewToFront(self.selectedView!)
        //}
        case .Changed:
            debugPrint("Changed..")
            debugPrint("Y-Offset: " + String(center.y-self.startPan!.y))
            debugPrint("Center: " + String(self.startPan!.x) + ", " + String(self.startPan!.y))
            let yOffset = center.y-self.startPan!.y
            var currentConstant = self.storeViewTop.constant;
            currentConstant = yOffset + startOffset; // needs to be offset..
            if(currentConstant > self.parentView.frame.height) {
                currentConstant = self.parentView.frame.height
            }
            if(currentConstant < 120) {
                currentConstant = 120
            }
            
            self.storeViewTop.constant = currentConstant
            
        case .Ended:
            let lastOffset = self.storeViewTop.constant
            let halfWay = (self.parentView.frame.height - 120) / 2.0 + 120
            if(lastOffset < (halfWay)) {
                // close
                UIView.animateWithDuration( 0.1, animations: {
                    self.storeViewTop.constant = 120
                    self.currentOrderBottomOffset.constant = -500
                    self.parentView.layoutIfNeeded()
                    self.currentView.layoutIfNeeded()
                    
                    debugPrint(String(self.payButton.frame.minX) + " x " + String(self.payButton.frame.minY))
                    debugPrint(String(self.currentOrderView.frame.height))
                    
                    self.payButton.layoutIfNeeded()
                    self.currentView.layoutSubviews()
                })
            } else {
                UIView.animateWithDuration( 0.1, animations: {
                    self.storeViewTop.constant = self.parentView.frame.height
                    self.currentOrderBottomOffset.constant = 0
                    self.parentView.layoutIfNeeded()
                    self.currentView.layoutIfNeeded()
                    
                    debugPrint(String(self.payButton.frame.minX) + " x " + String(self.payButton.frame.minY))
                    debugPrint(String(self.currentOrderView.frame.height))
                    
                    self.payButton.layoutIfNeeded()
                    self.currentView.layoutSubviews()
                })
            }
        case .Cancelled:
            debugPrint("cancelled")
        case .Failed:
            debugPrint("failed")
        default:
            debugPrint("Default")
        }
    }
    
    @objc func touchCurrentOrderView(_ sender:UITapGestureRecognizer) {
        if(true) {
            return
        }
        let orientation = UIApplication.sharedApplication().statusBarOrientation;
        if (orientation != UIInterfaceOrientation.Portrait && orientation != UIInterfaceOrientation.PortraitUpsideDown) {
            return;
        }
        
        
        if self.storeViewTop.constant == self.parentView.frame.height {
            
            UIView.animateWithDuration( 0.5, animations: {
                self.storeViewTop.constant = 120
                self.currentOrderBottomOffset.constant = -800
                self.parentView.layoutIfNeeded()
            });
        } else {
            startingPoint = currentOrderView.frame
            
            debugPrint(String(self.payButton.frame.minX) + " x " + String(self.payButton.frame.minY))
            debugPrint(String(self.currentOrderView.frame.height))
            
            UIView.animateWithDuration(0.5, animations: {
                self.storeViewTop.constant = self.parentView.frame.height
                self.currentOrderBottomOffset.constant = 0
                self.parentView.layoutIfNeeded()
                self.currentView.layoutIfNeeded()
                
                debugPrint(String(self.payButton.frame.minX) + " x " + String(self.payButton.frame.minY))
                debugPrint(String(self.currentOrderView.frame.height))
                
                self.payButton.layoutIfNeeded()
                self.currentView.layoutSubviews()
                }
            );
        }
    }
    
    var currentDisplayOrder:DisplayOrder = DisplayOrder()
    var itemsToDi = NSMutableDictionary()
    
    // POSOrderListener
    func itemAdded(_ item:POSLineItem) {
        
        let displayLineItem = DisplayLineItem(id: String(arc4random()), name:item.item.name!, price: String(CurrencyUtils.IntToFormat(item.item.price)!), quantity: String(item.quantity))
        currentDisplayOrder.lineItems.append(displayLineItem)
        itemsToDi.setObject(displayLineItem, forKey: item.item.id as NSCopying)

        updateTotals()

        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showDisplayOrder(currentDisplayOrder)
    }
    func itemRemoved(_ item:POSLineItem) {
        updateTotals()
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showDisplayOrder(currentDisplayOrder)
    }
    func itemModified(_ item:POSLineItem) {
        if let displayLineItem = itemsToDi.objectForKey(item.item.id) as? DisplayLineItem {
            displayLineItem.quantity = String(item.quantity)
            displayLineItem.name = item.item.name
            displayLineItem.price = String(CurrencyUtils.IntToFormat(item.item.price)!)
        }
        updateTotals()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showDisplayOrder(currentDisplayOrder)

    }
    func discountAdded(_ item:POSDiscount) {
        updateTotals()
    }
    func paymentAdded(_ item:POSPayment) {
        updateTotals()
    }
    func refundAdded(_ refund: POSRefund) {
        updateTotals()
    }
    func paymentChanged(_ item:POSPayment) {
        updateTotals()
    }
    // POSOrderListener.End
    
    // POSStoreListener
    func newOrderCreated(_ order:POSOrder) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.removeDisplayOrder(currentDisplayOrder)
        currentDisplayOrder = DisplayOrder()
        currentDisplayOrder.id = String(arc4random())
        itemsToDi.removeAllObjects() // cleanup
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.currentOrderListItems.reloadData()
        }
        updateTotals()
    }
    
    func preAuthAdded(_ payment: POSPayment) {
        // not needed in register
    }
    
    func preAuthRemoved(_ payment: POSPayment) {
        // not needed in register
    }
    
    func vaultCardAdded(_ card: POSCard) {
        // not needed in register
    }
    
    func manualRefundAdded(credit: POSNakedRefund) {
        // not needed in register
    }
    // POSStoreListener.End
    
    
    func updateTotals() {
        if let store = self.store,
            let currentOrder = store.currentOrder
        {
            dispatch_async(dispatch_get_main_queue()){ [unowned self] in
                self.subTotalLabel.text = CurrencyUtils.IntToFormat(currentOrder.getSubtotal())
                self.taxLabel.text = CurrencyUtils.IntToFormat(currentOrder.getTaxAmount())
                self.totalLabel.text = CurrencyUtils.IntToFormat(currentOrder.getTotal())
                
                self.currentOrderListItems.reloadData()
            }
            
            // update DisplayOrder..

            self.currentDisplayOrder.total = String(CurrencyUtils.IntToFormat(currentOrder.getTotal())!)
            self.currentDisplayOrder.subtotal = String(CurrencyUtils.IntToFormat(currentOrder.getSubtotal())!)
            self.currentDisplayOrder.tax = String(CurrencyUtils.IntToFormat(currentOrder.getTaxAmount())!)
        }
        
    }
    
    // TableView
    
    
    func tableView(tv: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let store = store,
            let currentOrder = store.currentOrder {
            if indexPath.row < currentOrder.items.count {
                let data = currentOrder.items[indexPath.row]
                
                if let cell:CurrentOrderListItemTableCell = tv.dequeueReusableCellWithIdentifier( "OrderItemCell", forIndexPath: indexPath) as? CurrentOrderListItemTableCell {
                    cell.item = data
                    return cell
                }
            }
        }

        return tv.dequeueReusableCellWithIdentifier( "OrderItemCell", forIndexPath: indexPath)

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let store = store,
            let currentOrder = store.currentOrder {
            return currentOrder.items.count;
        }
        return 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    // Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (store?.availableItems.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier( "AvailableItemCell", forIndexPath: indexPath)
        
        if let store = store,
            let cell = cell as? AvailableItemCollectionViewCell {
            if let posItem:POSItem = store.availableItems[indexPath.row] {
                cell.item = posItem
            }
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let store = store {
            if let item:POSItem = store.availableItems[(indexPath as NSIndexPath).row] {
                store.currentOrder?.addLineItem(POSLineItem(item: item))
                //currentOrderListItems.reloadData()
            }
        }
    }
    

    /*func collectionView(_:layout:sizeForItemAtIndexPath:NSIndexPath) {
    
    }*/
    
    func verifySignature(_ signatureVerifyRequest:VerifySignatureRequest) {
        self.signatureVerifyRequest = signatureVerifyRequest
        self.performSegueWithIdentifier( "ShowSignature", sender: self)
//        ivc.showViewController(SignatureViewController(), sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as? SignatureViewController)?.signatureVerifyRequest = self.signatureVerifyRequest
    }
    
    @IBAction func saleButtonClicked(_ sender: UIButton) {
        guard let cloverConnector = (UIApplication.sharedApplication().delegate as? AppDelegate)?.cloverConnector else { return }
        
        if let currentOrder = store?.currentOrder {
            currentOrder.pendingPaymentId = String(arc4random())
            let sr = SaleRequest(amount:currentOrder.getTotal(), externalId: currentOrder.pendingPaymentId!)
            // below are all optional
            sr.allowOfflinePayment = store?.transactionSettings.allowOfflinePayment
            sr.approveOfflinePaymentWithoutPrompt = store?.transactionSettings.approveOfflinePaymentWithoutPrompt
            sr.autoAcceptSignature = store?.transactionSettings.autoAcceptSignature
            sr.autoAcceptPaymentConfirmations = store?.transactionSettings.autoAcceptPaymentConfirmations
            sr.cardEntryMethods = store?.transactionSettings.cardEntryMethods ?? cloverConnector.CARD_ENTRY_METHODS_DEFAULT
            sr.disableCashback = store?.transactionSettings.disableCashBack
            sr.disableDuplicateChecking = store?.transactionSettings.disableDuplicateCheck
            if let enablePrinting = store?.transactionSettings.cloverShouldHandleReceipts {
                sr.disablePrinting = !enablePrinting
            }
            sr.disableReceiptSelection = store?.transactionSettings.disableReceiptSelection
            sr.disableRestartTransactionOnFail = store?.transactionSettings.disableRestartTransactionOnFailure
            if let tm = store?.transactionSettings.tipMode {
                sr.disableTipOnScreen = tm != .ON_SCREEN_BEFORE_PAYMENT
            }

            sr.forceOfflinePayment = store?.transactionSettings.forceOfflinePayment
            sr.cardNotPresent = store?.cardNotPresent

            sr.tipAmount = nil
            sr.tippableAmount = currentOrder.getTippableAmount()
            sr.tipMode = SaleRequest.TipMode.ON_SCREEN_BEFORE_PAYMENT
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.sale(sr)
        }
    }
    @IBAction func authButtonClicked(_ sender: UIButton) {
        guard let cloverConnector = (UIApplication.sharedApplication().delegate as? AppDelegate)?.cloverConnector else { return }
        
        if let currentOrder = store?.currentOrder {
            currentOrder.pendingPaymentId = String(arc4random())
            let ar = AuthRequest(amount: currentOrder.getTotal(), externalId: currentOrder.pendingPaymentId!)
            // below are all optional
            ar.allowOfflinePayment = store?.transactionSettings.allowOfflinePayment
            ar.approveOfflinePaymentWithoutPrompt = store?.transactionSettings.approveOfflinePaymentWithoutPrompt
            ar.autoAcceptSignature = store?.transactionSettings.autoAcceptSignature
            ar.autoAcceptPaymentConfirmations = store?.transactionSettings.autoAcceptPaymentConfirmations
            ar.cardEntryMethods = store?.transactionSettings.cardEntryMethods ?? cloverConnector.CARD_ENTRY_METHODS_DEFAULT
            ar.disableCashback = store?.transactionSettings.disableCashBack
            ar.disableDuplicateChecking = store?.transactionSettings.disableDuplicateCheck
            if let enablePrinting = store?.transactionSettings.cloverShouldHandleReceipts {
                ar.disablePrinting = !enablePrinting
            }
            ar.disableReceiptSelection = store?.transactionSettings.disableReceiptSelection
            ar.disableRestartTransactionOnFail = store?.transactionSettings.disableRestartTransactionOnFailure
            
            ar.forceOfflinePayment = store?.transactionSettings.forceOfflinePayment
            ar.cardNotPresent = store?.cardNotPresent
            
            ar.tippableAmount = currentOrder.getTippableAmount()
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.auth(ar)
        }
    }
    @IBAction func newOrderButtonClicked(_ sender: UIButton) {
        if let store = store {
            store.newOrder()
            updateTotals()
        }
    }
}
