//
//  Untitled.swift
//  Notifio
//
//  Created by Davide Benini on 08/11/25.
//
import SwiftUI

struct NoticeBanner: View {
    let notice: Notice
    var backgroundColor: Color
    var textColor: Color
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                if let imageUrlString = notice.imageUrl,
                   let url = URL(string: imageUrlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            Color.gray.frame(width: 50, height: 50)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(notice.text)
                        .font(.body)
                        .foregroundColor(notice.textColor ?? textColor)
                        .lineLimit(nil)

                    if notice.urlString != nil {
                        Text("Tap for more")
                            .font(.footnote)
                            .foregroundColor(textColor.opacity(0.7))
                    }
                }

                Spacer()

                Button(action: {
                    onDismiss?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(textColor.opacity(0.7))
                        .font(.title2)
                }
            }
            .padding()
            .background((notice.backgroundColor ?? backgroundColor).gradient)
            .cornerRadius(12)
            .shadow(radius: 5)
            .onTapGesture {
                if let urlString = notice.urlString, let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                } else {
                    onDismiss?()
                }
            }
        }
        .padding(.horizontal)
    }
}
