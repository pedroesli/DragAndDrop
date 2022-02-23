//
//  DropView.swift
//  DragAndDropManagerMain
//
//  Created by Pedro Ésli Vieira do Nascimento on 21/02/22.
//

import SwiftUI

/**
 A drop view that needs to be inside a `InteractiveDragDropContainer` to work properly
 */
public struct DropView<Content: View>: View{
    
    @EnvironmentObject private var manager: DragDropManager
    
    @State private var isDropped = false
    
    private let elementID: UUID
    private let content: (DropInfo) -> Content
    private var receivedAction: (() -> Void)?
    
    public struct DropInfo{
        public let didDrop: Bool
        public let isColliding: Bool
    }
    
    /**
        Initializer for the drop view that uses the id of the receiving drag view.
     
        - Parameters:
            - id: The id of the drop view which this drop view will be able to accept.
            - content: The view and area that will be able to be dropped.
     */
    public init(receiveFrom id: UUID, @ViewBuilder content: @escaping (DropInfo) -> Content){
        self.elementID = id
        self.content = content
    }
    
    public var body: some View{
        content(DropInfo(didDrop: isDropped, isColliding: manager.isColliding(with: elementID)))
            .overlay(GeometryReader(content: { geometry in
                Color.clear
                    .onAppear {
                        self.manager.addFor(drop: elementID, frame: geometry.frame(in: CoordinateSpace.named("stack")))
                    }
            }))
            .onChange(of: manager.dropedViewID) { newValue in
                if newValue == elementID {
                    isDropped = true
                    receivedAction?()
                }
            }
    }
    
    
    /// - Parameter action: An action when this `DropView` has received its `DragView`
    public func onViewReceived(action: @escaping () -> Void) -> DropView{
        var new = self
        new.receivedAction = action
        return new
    }
}
