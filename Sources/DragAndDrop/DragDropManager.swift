//
//  DragDropManager.swift
//  DragAndDropManagerMain
//
//  Created by Pedro Ésli on 21/02/22.
//

import SwiftUI

/// Observable class responsible for maintaining the positions of all `DropView` and `DragView` views and checking if it is possible to drop
class DragDropManager: ObservableObject {
    
    @Published var droppedViewID: UUID? = nil
    @Published var currentDraggingViewID: UUID? = nil
    @Published var currentDraggingOffset: CGSize? = nil
    
    private var dragViewsMap: [UUID: CGRect] = [:]
    private var dropViewsMap: [UUID: CGRect] = [:]
    private var otherDropViewsMap: [UUID: CGRect] = [:]
    
    /// Register a new `DragView` to the drag list map.
    ///
    /// - Parameters:
    ///     - id: The id of the view to drag.
    ///     - frame: The frame of the drag view.
    func addFor(drag id: UUID, frame: CGRect) {
        dragViewsMap[id] = frame
    }
    
    /// Register a new `DropView` to the drop list map.
    ///
    /// - Parameters:
    ///     - id: The id of the drop view.
    ///     - frame: The frame of the drag view.
    ///     - canRecieveAnyDragView: Can this drop view recieve any drag view.
    func addFor(drop id: UUID, frame: CGRect, canRecieveAnyDragView: Bool) {
        if canRecieveAnyDragView {
            otherDropViewsMap[id] = frame
            return
        }
        dropViewsMap[id] = frame
    }
    
    /// Keeps track of the current dragging view id and offset
    ///
    /// - Parameters:
    ///     - id: The id of the drag view.
    ///     - frame: The offset of the dragging view.
    func report(drag id: UUID, offset: CGSize) {
        currentDraggingViewID = id
        currentDraggingOffset = offset
    }
    
    /// Check if the current dragging view is colliding with the current provided id of drop view
    ///
    /// - Parameter id: The id of the drop view to check if its colliding
    ///
    /// - Returns: `True` if the dragging  view is colliding with the current drop view.
    func isColliding(dropId: UUID) -> Bool {
        guard let currentDraggingOffset = currentDraggingOffset else { return false }
        guard let currentDraggingViewID = currentDraggingViewID else { return false }
        guard let dragRect = dragViewsMap[currentDraggingViewID] else { return false }
        guard let dropRect = dropViewsMap[currentDraggingViewID] ?? otherDropViewsMap[dropId] else { return false }
        
        let newFrame = dragRect.offsetBy(dx: currentDraggingOffset.width, dy: currentDraggingOffset.height)
        return dropRect.intersects(newFrame)
    }
    
    /// Check if the current dragging view is colliding.
    ///
    /// - Returns: `True` if the dragging view is colliding
    func isColliding(dragID: UUID) -> Bool {
        guard let currentDraggingOffset = currentDraggingOffset else { return false }
        guard let currentDraggingViewID = currentDraggingViewID, dragID == currentDraggingViewID else { return false }
        return canDrop(id: dragID, offset: currentDraggingOffset)
    }
    
    /// Checks if it is possible to drop a `DragView` in a certain position where theres a `DropView`.
    ///
    /// - Parameters:
    ///     - id: The id of the drag view from which to drop.
    ///     - offset: The current offset of the view you are dragging.
    ///
    /// - Returns: `True` if the view can be dropped at the position.
    func canDrop(id: UUID, offset: CGSize) -> Bool {
        guard let dragRect = dragViewsMap[id] else { return false }
        
        // if only one drop view can recieve this drag view then check if it can be dropped
        if let dropRect = dropViewsMap[id] {
            let newFrame = dragRect.offsetBy(dx: offset.width, dy: offset.height)
            return dropRect.intersects(newFrame)
        }
        // else find a drop view that can recieve this drag view
        for otherDropViewMap in otherDropViewsMap {
            let dropViewRect = otherDropViewMap.value
            let newFrame = dragRect.offsetBy(dx: offset.width, dy: offset.height)
            if dropViewRect.intersects(newFrame) {
                return true
            }
        }
        return false
    }
    
    /// Tells that the current `DragView` will be dropped;
    func dropDragView(of id: UUID, at offset: CGSize) {
        // If id exists dropViewsMap sets droppedViewID to id else find a suitable id
        if dropViewsMap[id] != nil {
            droppedViewID = id
            return
        }
        
        guard let dragRect = dragViewsMap[id] else { return }
        for otherDropViewMap in otherDropViewsMap {
            let dropViewRect = otherDropViewMap.value
            let newFrame = dragRect.offsetBy(dx: offset.width, dy: offset.height)
            if dropViewRect.intersects(newFrame) {
                droppedViewID = otherDropViewMap.key
                return
            }
        }
    }
}
