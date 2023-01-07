//
//  ContentView.swift
//  FloorMeasureApp
//
//  Created by Yusuke Abiko on 2023/01/06.
//

import SwiftUI

struct ContentView: View {
    @State private var image = UIImage()
    @State private var isShowPhotoLibrary = false
    @State private var points: [CGPoint] = []
    @State private var area: Double = 0
    @State private var perimeter: Double = 0
    @State private var size = 4
    
    // 1畳分の面積
    let J1:Double = 1820.0 * 910.0
    
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    self.isShowPhotoLibrary = true
                    points.removeAll()
                }){
                    HStack{
                        Text("画像を選択")
                        Image(systemName: "photo")
                    }
                }
                Text("S:\(String(format:"%.0f",area)) L:\(String(format:"%.0f",perimeter))")
            }
            
            ZStack(alignment: .top){
                Image(uiImage: self.image)
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .top)
                Path{ path in
                    for( index, point) in points.enumerated(){
                        if index == 0 {
                            path.move(to: point)
                        }
                        else{
                            path.addLine(to: point)
                        }
                    }
                }
                .fill(.red)
                .opacity(0.3)
                ForEach(0..<points.count, id: \.self){ index in
                    Ellipse()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.red)
                        .position(x: points[index].x, y: points[index].y)
                    // Coodinate
//                    Text("(\(String(format: "%.0f",points[index].x)),\(String(format: "%.0f",points[index].y)))")
//                        .frame(alignment: .leading)
//                        .position(x: points[index].x, y: points[index].y)
//                        .offset(x:44, y:0)
                    
                    // Line Length
                    if(points.count > 1){
                        if((points.count - 1) <= index){
                            Text("\(String(format:"%.0f", getActualLength(p1: points[index], p2: points[0])))")
                                .position(getMiddlePoint(p1:points[index], p2:points[0]))
                                .foregroundColor(.red)
                        }
                        else{
                            Text("\(String(format:"%.0f", getActualLength(p1: points[index], p2: points[index+1])))")
                                .position(getMiddlePoint(p1:points[index], p2:points[index+1]))
                                .foregroundColor(.red)
                        }
                    }
                }
                                
                // Line Length
//                Text("\(String(format:"%.0f", getMiddlePoint(p1:points[index], p2:points[index+1])))")
            }
            .onTapGesture{location in
                points.append(location)
                calc()
            }
            
            // Select Size
            Picker("Size" ,selection: $size){
                Text("5畳").tag(5)
                Text("6畳").tag(6)
                Text("7畳").tag(7)
                Text("8畳").tag(8)
                Text("10畳").tag(10)
                Text("11畳").tag(11)
                Text("12畳").tag(12)
                Text("13畳").tag(13)
                Text("14畳").tag(14)
                Text("17畳").tag(17)
            }
            .pickerStyle(.menu)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShowPhotoLibrary, content: {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        })
    }
    
    private func calc() -> Void{
        let size: Int = points.count
        
        // Calc Area
        var s: Double = 0
        for( index,_) in points.enumerated(){
            if index >= (size - 1) {break}
            s += ((points[index].x - points[index+1].x) * (points[index].y + points[index+1].y))
        }
        s += (points[size - 1].x - points[0].x)*(points[size - 1].y + points[0].y)
        s /= 2
        
        area = abs(s)
        debugPrint("S:\(s)")

        // Calc Perimeter
        var l: Double = 0
        for(index, _) in points.enumerated(){
            if index >= (size - 1) {break}
            l += calcLength(p1: points[index], p2: points[index + 1])
        }
        l += calcLength(p1: points[size - 1], p2: points[0])
        
        perimeter = abs(l)
        debugPrint("L:\(l)")
    }
    
    private func calcLength(p1: CGPoint, p2: CGPoint) -> Double{
        return sqrt(pow((p1.x - p2.x),2.0) + pow((p1.y - p2.y), 2.0))
    }
    
    private func getMiddlePoint(p1: CGPoint, p2: CGPoint) -> CGPoint{
        var middlePoint = CGPoint()
        
        middlePoint.x = (p1.x + p2.x)/2
        middlePoint.y = (p1.y + p2.y)/2
        return middlePoint
    }
    
    private func getActualLength(p1: CGPoint, p2: CGPoint) -> Double{
        // Actual Size
        let actual = J1 * Double(size)
        let R = actual / area
        let lineLength = calcLength(p1: p1, p2: p2)
        return lineLength * R
    }
}

extension CGPoint: Hashable{
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
