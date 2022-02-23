//
//  DragView.swift
//  DragAndDropManagerMain
//
//  Created by Pedro Ésli Vieira do Nascimento on 21/02/22.
//

import SwiftUI

/**
 A draging view that needs to be inside a `InteractiveDragDropContainer` to work properly
 */
public struct DragView<Content: View> : View{
    
    @EnvironmentObject private var manager: DragDropManager
    
    @State private var dragOffset: CGSize = CGSize.zero
    @State private var position: CGPoint = CGPoint.zero
    @State private var isDragging = false
    @State private var isDroped = false
    
    private let content: (DragInfo) -> Content
    private var dragginStoppedAction: ((Bool) -> Void)?
    private let elementID: UUID
    
    public struct DragInfo{
        public let didDrop: Bool
        public let isDragging: Bool
        public let isColliding: Bool
    }
    
    /**
        Initialize this view with its unique ID and custom view.
     
        - Parameters:
            - id: The unique id of this view.
            - dragging: A binding property to let you know if this view is being dragged (optional).
            - content: The custom content of this view and what will be dragged.
     */
    public init(id: UUID, @ViewBuilder content: @escaping (DragInfo) -> Content){
        self.elementID = id
        self.content = content
    }
    
    public var body: some View {
        if isDroped {
            content(DragInfo(didDrop: true, isDragging: false, isColliding: false)).hidden()
        }
        else{
            content(DragInfo(didDrop: isDroped, isDragging: isDragging, isColliding: manager.isColliding(with: elementID)))
                .offset(dragOffset)
                .overlay(GeometryReader(content: { geometry in
                    Color.clear
                        .onAppear {
                            self.manager.addFor(drag: elementID, frame: geometry.frame(in: CoordinateSpace.named("stack")))
                        }
                }))
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            withAnimation(.interactiveSpring()) {
                                dragOffset = value.translation
                            }
                        })
                        .simultaneously(with: DragGesture(coordinateSpace: CoordinateSpace.named("stack"))
                                            .onChanged({ value in
                                                manager.report(drag: elementID, offset: value.translation)
                                                
                                                if !isDragging{
                                                    isDragging = true
                                                }
                                            })
                                            .onEnded({ value in
                                                if manager.canDrop(id: elementID, offset: value.translation){
                                                    self.manager.dropedViewID = elementID
                                                    self.isDroped = true
                                                    dragginStoppedAction?(true)
                                                }
                                                else{
                                                    withAnimation(.spring()) {
                                                        dragOffset = CGSize.zero
                                                    }
                                                    dragginStoppedAction?(false)
                                                }
                                                isDragging = false
                                            })
                                       )
                )
                .zIndex(isDragging ? 1 : 0)
                .animation(.spring(), value: isDragging)
        }
    }
    
    /**
        An action indicating if the user has stopped dragging this view and indicates if it has dropped succesfuly on a `DropView` or not.
     
        - Parameters:
            - action: The action that will happen after the user has stopped dragging. (Also tell if it has dropped or not on a `DropView`) 
     */
    public func onDraggingEndedAction(action: @escaping (Bool) -> Void) -> DragView{
        var new = self
        new.dragginStoppedAction = action
        return new
    }
}
