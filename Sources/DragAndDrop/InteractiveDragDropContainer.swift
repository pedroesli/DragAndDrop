//
//  InteractiveDragDropContainer.swift
//  DragAndDropManagerMain
//
//  Created by Pedro Ésli on 21/02/22.
//

import SwiftUI

/// Used as a container to place `DropView` and `DragView` views, where they will be able to work together properly.
///
/// - Example: This example shows the use of the interactive views inside the `InteractiveDragDropContainer`
///
///     let id = UUID()
///
///     InteractiveDragDropContainer {
///         DragView(id: id, dragging: nil) {
///             Text("Drag me 1")
///                 .padding()
///                 .frame(width: 120)
///                 .background{
///                     Color.mint
///                 }
///         }
///         DropView(receiveFrom: id) { dropInfo in
///             if !dropInfo.didDrop{
///                 Text("Drop Here 1")
///                     .padding()
///                     .background{
///                         dropInfo.isColliding ? Color.green : Color.red
///                     }
///             }
///             else{
///                 Text("Drag me 1")
///                     .padding()
///                     .frame(width: 120)
///                     .background{
///                         Color.mint
///                     }
///             }
///         }
///         .onViewReceived {
///             print("Dropped 1")
///         }
///     }
public struct InteractiveDragDropContainer<Content: View>: View {
    
    @StateObject var manager = DragDropManager()
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            content.environmentObject(manager)
        }
        .coordinateSpace(name: CoordinateSpace.dragAndDrop)
    }
    
}
