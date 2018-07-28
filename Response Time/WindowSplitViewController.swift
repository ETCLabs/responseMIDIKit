//
//  WindowSplitViewController.swift
//  Response Time
//
//  Created by Sam Smallman on 26/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Cocoa

class WindowSplitViewController: NSSplitViewController {
    
    private let timecode = TimecodeViewController()
    private let logs = LogsViewController()
    private var utilitiesSplitViewItem: NSSplitViewItem?
    private var logsSplitViewItem: NSSplitViewItem?
    private var utilitiesIndex = -1
    private var logsIndex = -1
    
    public enum UtilitiesTab {
        case collapsed
        case expanded
        
        static let menuItemTitles = [collapsed: "Show Utilities", expanded : "Hide Utilities"]
        
        func menuItemTitle() -> String {
            guard let title = UtilitiesTab.menuItemTitles[self] else {
                return "Invalid"
            }
            return title
        }
    }
    
    public enum LogsTab {
        case collapsed
        case expanded
        
        static let menuItemTitles = [collapsed: "Show Logs", expanded : "Hide Logs"]
        
        func menuItemTitle() -> String {
            guard let title = LogsTab.menuItemTitles[self] else {
                return "Invalid"
            }
            return title
        }
    }
    
    public var utilitiesTabVisibility: UtilitiesTab {
        get {
            guard let item = utilitiesSplitViewItem else { return .collapsed }
            if item.isCollapsed {
                return .collapsed
            } else {
                return .expanded
            }
        }
    }
    
    public var logsTabVisibility: LogsTab {
        get {
            guard let item = logsSplitViewItem else { return .collapsed }
            if item.isCollapsed {
                return .collapsed
            } else {
                return .expanded
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let server = ResponseServer(logs: logs, timecode: timecode)
        let utilities = UtilitiesViewController(server: server)
        // Set up the Splitview Items.
        self.addChildViewController(utilities)
        self.addChildViewController(timecode)
        self.addChildViewController(logs)
        
        // Keep hold of the Splitview Items for animating collapsing and expanding.
        utilitiesSplitViewItem = self.splitViewItem(for: utilities)
        logsSplitViewItem = self.splitViewItem(for: logs)
        
        // Keep hold of the Splitview Item Indexes that can collapse.
        guard let uItem = utilitiesSplitViewItem, let uIndex = self.splitViewItems.index(of: uItem) else { return }
        utilitiesIndex = uIndex
        guard let lItem = logsSplitViewItem, let lIndex = self.splitViewItems.index(of: lItem) else { return }
        logsIndex = lIndex
        
    }
    
    // MARK: - NSSplitview Delegate Method
    
    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        // Allow only the utilities tab and the logs tab to be collapsed.
        if subview == self.splitView.subviews[utilitiesIndex] || subview == self.splitView.subviews[logsIndex] {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func toggleUtilitiesVisibility(sender: AnyObject) {
        guard let item = utilitiesSplitViewItem else { return }
        item.animator().isCollapsed = utilitiesTabVisibility != .collapsed
    }
    
    @IBAction func toggleLogsVisibility(sender: AnyObject) {
        guard let item = logsSplitViewItem else { return }
         item.animator().isCollapsed = logsTabVisibility != .collapsed
    }
    
    @IBAction func clearTimecode(sender: AnyObject) {
        timecode.clearTimecode()
    }
    
    @IBAction func clearLogs(sender: AnyObject) {
        logs.clearLogs()
    }
    
    
}
