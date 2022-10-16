# DragAndDrop

# Installation

In Xcode go to `File -> Add Packages... -> Search or Enter Package URL` and paste in the repo's url: [https://github.com/pedroesli/DragAndDrop](https://github.com/pedroesli/DragAndDrop)

## How to use

To use DragAndDrop first you must use `InteractiveDragDropContainer` to contain the `DragView` and `DropView` inside and give the proper functionality. `DragView` will have a unique `UUID` so that `DropView` will be able to identify what view it can receive.

```swift
let id = UUID()
    
var body: some View {
    InteractiveDragDropContainer{
        VStack{
            DragView(id: id) { dragInfo in
                Text(dragInfo.isDragging ? "Im being dragged" : "Drag me")
                    .padding()
                    .background{
                        Color.mint
                    }
            }
            Spacer()
            DropView(receiveFrom: id) { dropInfo in
                if !dropInfo.didDrop{
                    Text("Drop Here")
                        .padding()
                        .background{
                            dropInfo.isColliding ? Color.green : Color.red
                        }
                }
                else{
                    Text("Dropped")
                        .padding()
                        .background{
                            Color.mint
                        }
                }
            }
        }
    }
}
```

![example.gif](Previews/example1.gif)

# DragView

## onDraggingEndedAction

```swift
DragView(id: id) { dragInfo in
    Text(dragInfo.isDragging ? "Im being dragged" : "Drag me")
        .padding()
        .background{
            Color.mint
        }
}
.onDraggingEndedAction { isSuccessfullDrop in
    print("I stopped dragging and dropped: \(isSuccessfullDrop)")
}
```

# DropView

## onDragViewReceived
An action that is called when the drag view has been released on this DragView and has been recieved accordingly.

```swift
DropView(receiveFrom: id) { dropInfo in
    if !dropInfo.didDrop{
        Text("Drop Here")
            .padding()
            .background{
                dropInfo.isColliding ? Color.green : Color.red
            }
    }
    else{
        Text("Dropped")
            .padding()
            .background{
                Color.mint
            }
    }
}
.onDragViewReceived { receivingViewID in
    print(receivingViewID)
}
```

# Next Update
Replace the UUID to identify the views with the protocol Identifiable to be more generic.  
