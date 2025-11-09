//
//  Untitled.swift
//  Notifio
//
//  Created by Davide Benini on 08/11/25.
//

import SwiftUI

import SwiftUI
internal import Combine

struct NoticeOverlayModifier: ViewModifier {
    let configuration: NoticeConfiguration
    @State private var manager = NoticeManager.shared
    @State private var currentNotice: Notice?

    // Timer to check for displayable notices every 30 seconds
    @State private var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    func body(content: Content) -> some View {
        ZStack {
            content

            if let notice = currentNotice {
                configuration.overlayColor
                    .ignoresSafeArea()

                VStack {
                    NoticeBanner(
                        notice: notice,
                        backgroundColor: configuration.bannerBackground,
                        textColor: configuration.textColor
                    ) {
                        currentNotice = nil
                        manager.markAsDisplayed(notice)
                    }
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: currentNotice)
            }
        }
        .onAppear {
            // Start the refresh loop
            manager.startAutoRefresh(configuration: configuration)
            
            // Initial notice check
            currentNotice = manager.displayableNotice()
        }
        .onChange(of: manager.notices) {
            // New notices fetched from remote
            let newNotice = manager.displayableNotice()
            if newNotice?.id != currentNotice?.id {
                currentNotice = newNotice
            }
        }
        .onReceive(timer) { _ in
            // Periodic check to display notices whose startDate has arrived
            let newNotice = manager.displayableNotice()
            if currentNotice == nil, newNotice?.id != currentNotice?.id {
                withAnimation {
                    currentNotice = newNotice
                }
            }
        }
    }
}




extension View {
    func noticeOverlay(configuration: NoticeConfiguration) -> some View {
        self.modifier(NoticeOverlayModifier(configuration: configuration))
    }
}
