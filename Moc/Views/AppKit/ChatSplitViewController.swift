//
//  ChatSplitView.swift
//  Moc
//
//  Created by Егор Яковенко on 07.01.2022.
//

import AppKit

final class ChatSplitViewController: NSViewController, NSSplitViewDelegate {
    @IBOutlet weak var panelVisibilityChangedSegmentControl: NSSegmentedControl!
    @IBOutlet weak var splitView: NSSplitView!

    override func viewDidLoad() {
        super.viewDidLoad()

        splitView.delegate = self
    }

    @IBAction func panelVisibilityChanged(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
            case 0: break
            case 1: break
            default: break
        }
    }

    func changeLeftPanelVisibility(visible: Bool) {
        let newPosition: CGFloat = visible ? 100.0 : 0
        animatePanelChange(
            toPosition: newPosition,
            ofDividerAt: 0,
            to: visible
        )
    }

    func changeRightPanelVisibility(visible: Bool) {
        let newPosition: CGFloat = visible ? view.frame.width - 100 : view.frame.width
        animatePanelChange(
            toPosition: newPosition,
            ofDividerAt: 1,
            to: visible
        )
    }

    func animatePanelChange(
        toPosition position: CGFloat,
        ofDividerAt dividerIndex: Int,
        to visible: Bool
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = 0.75

            splitView.setPosition(position, ofDividerAt: dividerIndex)
            splitView.layoutSubtreeIfNeeded()
        }
    }

    func splitViewDidResizeSubviews(_ notification: Notification) {

        guard let resizedDivider = notification.userInfo?["NSSplitViewDividerIndex"] as? Int else {
            return
        }

        let panel = resizedDivider == 0 ? splitView.subviews[0] : splitView.subviews[2]
        let visible = panel.frame.size.width != 0

        panelVisibilityChangedSegmentControl.setSelected(visible, forSegment: resizedDivider)
    }
}
