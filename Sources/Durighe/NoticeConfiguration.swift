//
//  Untitled.swift
//  Notifio
//
//  Created by Davide Benini on 08/11/25.
//

import SwiftUI
import Foundation

public struct NoticeConfiguration {
    /// URL to fetch the notices JSON
    public let remoteURL: URL
    
    /// Background color for the notice banner
    public let bannerBackground: Color
    
    /// Text color for the notice banner
    public let textColor: Color
    
    /// Optional semi-transparent overlay color
    public let overlayColor: Color

    /// Interval for auto-refresh
    public let refreshInterval: TimeInterval

    public init(
        remoteURL: URL,
        bannerBackground: Color = Color.blue,
        textColor: Color = Color.white,
        overlayColor: Color = Color.black.opacity(0.4),
        refreshInterval: TimeInterval = 3600

    ) {
        self.remoteURL = remoteURL
        self.bannerBackground = bannerBackground
        self.textColor = textColor
        self.overlayColor = overlayColor
        self.refreshInterval = refreshInterval
    }
}
