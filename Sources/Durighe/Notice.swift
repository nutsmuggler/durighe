//
//  Noticd.swift
//  Notifio
//
//  Created by Davide Benini on 08/11/25.
//
import Foundation
import SwiftUI

struct Notice: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let startDate: Date
    let endDate: Date
    let urlString: String?
    let imageUrl: String?
    let textColorHex: String?
    let backgroundColorHex: String?
    let minimumAppVersion: String?

    init(
        id: UUID = UUID(),
        text: String,
        startDate: Date,
        endDate: Date,
        urlString: String? = nil,
        imageUrl: String? = nil,
        textColorHex: String? = nil,
        backgroundColorHex: String? = nil,
        minimumAppVersion: String? = nil

    ) {
        self.id = id
        self.text = text
        self.startDate = startDate
        self.endDate = endDate
        self.urlString = urlString
        self.imageUrl = imageUrl
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
        self.minimumAppVersion = minimumAppVersion
    }
    
    var textColor: Color? {
        guard let textColorHex, textColorHex.hasPrefix("#") else {
            return nil
        }
        return Color.color(hexString: textColorHex)
    }
    
    var backgroundColor: Color? {
        guard let backgroundColorHex, backgroundColorHex.hasPrefix("#") else {
            return nil
        }
        return Color.color(hexString: backgroundColorHex)
    }
}

