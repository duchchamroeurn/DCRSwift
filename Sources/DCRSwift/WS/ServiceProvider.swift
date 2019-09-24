//
//  File.swift
//  
//
//  Created by iOSDev on 9/24/19.
//

import Foundation

struct ServiceProvider {
    
    /// MARK:- Initialize
    private init() {}
    /// Instant of WSManager
    private let ws = WSManager.share
    
    /// Instant of ServiceProvider
    public static var share: ServiceProvider {
        get { return ServiceProvider() }
    }
}
