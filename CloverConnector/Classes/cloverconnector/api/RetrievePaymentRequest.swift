//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

/**
 options for retrieving payment information
 */
public class RetrievePaymentRequest {
    /// the external id passed in to the Sale, Auth or PreAuth request
    public var externalPaymentId:String
    
    public init(_ externalPaymentId:String) {
        self.externalPaymentId = externalPaymentId
    }
}
