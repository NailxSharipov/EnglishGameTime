//
//  ShareActivityView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 19.05.2022.
//

// https://support.jmango360.com/portal/en/kb/articles/get-app-url-app-stores
// let locale = Locale.current

#if os(iOS)
import UIKit
import SwiftUI

struct ShareActivityView: UIViewControllerRepresentable {

    let shareLink: URL
    let onSuccess: () -> ()

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [shareLink], applicationActivities: nil)
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .airDrop,
            .copyToPasteboard,
            .markupAsPDF,
            .openInIBooks,
            .saveToCameraRoll,
            .print
        ]
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if activityError == nil && completed {
                DispatchQueue.main.async {
                    onSuccess()
                }
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareActivityView>) {}
}
#endif
