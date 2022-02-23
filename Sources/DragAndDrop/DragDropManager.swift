//
//  DragDropManager.swift
//  DragAndDropManagerMain
//
//  Created by Pedro Ésli Vieira do Nascimento on 21/02/22.
//

import SwiftUI

/// Observable class responsible for maintaining the positions of all `DropView` and `DragView` views and checking if it is possible to drop
class DragDropManager: ObservableObject{
    
    @Published var dropedViewID: UUID? = nil
    @Published var currentDraggingViewID: UUID? = nil
    @Published var currentDraggingOffset: CGSize? = nil
    
    private var dragViewsMap: [UUID: CGRect] = [:]
    private var dropViewsMap: [UUID: CGRect] = [:]
    
    /**
        Register a new `DragView` to the drag list map.
     
        - Parameters:
            - id: The id of the view to drag.
            - frame: The frame of the drag view.
     */
    func addFor(drag id: UUID, frame: CGRect) {
        dragViewsMap[id] = frame
    }
    
    /**
        Register a new `DropView` to the drop list map.
     
        - Parameters:
            - id: The id of the drop view.
            - frame: The frame of the drag view.
     */
    func addFor(drop id: UUID, frame: CGRect) {
        dropViewsMap[id] = frame
    }
    
    /**
        Keeps track of the current dragging view id and offset
        
        - Parameters:
            - id: The id of the drag view.
            - frame: The offset of the dragging view.
     */
    func report(drag id: UUID, offset: CGSize) {
        currentDraggingViewID = id
        currentDraggingOffset = offset
    }
    
    func isColliding(with id: UUID) -> Bool{
        guard let currentDraggingOffset = currentDraggingOffset else { return false }
        return id == currentDraggingViewID ? canDrop(id: id, offset: currentDraggingOffset) : false
    }
    
    /**
        Checks if it is possible to drop a view in a certain position where theres a `DropView`.
     
        - Parameters:
            - id: The id of the view from which to drop.
            - offset: The current offset of the view you are dragging.
        
        - Returns: `True` if the view can be dropped at the position.
     */
    func canDrop(id: UUID, offset: CGSize) -> Bool {
        guard let dropRect = dropViewsMap[id],
              let dragRect = dragViewsMap[id]
        else { return false }
        
        let newFrame = dragRect.offsetBy(dx: offset.width, dy: offset.height)
        return dropRect.intersects(newFrame)
    }
}
