//
//  ContentView.swift
//  Motion Demo
//
//  Created by Anthony Li on 2/26/24.
//

import SwiftUI

struct ContentView: View {
    @State var angleType = AngleType.degrees
    
    var body: some View {
        TabView {
            MotionView<DeviceMotionViewModel>(title: "Device", angleType: $angleType)
                .tabItem {
                    Label("Device", systemImage: "iphone")
                }
            MotionView<HeadphoneMotionViewModel>(title: "Headphones", angleType: $angleType)
                .tabItem {
                    Label("Headphones", systemImage: "airpodspro")
                }
        }
    }
}

struct MotionView<TViewModel: MotionViewModel>: View {
    var title: LocalizedStringKey
    @Binding var angleType: AngleType
    @StateObject var viewModel = TViewModel()
    
    func angleDatapoint<Background: ShapeStyle>(title: LocalizedStringKey, angle: Double?, background: Background) -> some View {
        let content: LocalizedStringKey
        if let angle {
            switch angleType {
            case .degrees:
                content = "\(angle / .pi * 180, format: .number.precision(.fractionLength(0)))°"
            case .radians:
                content = "\(angle, format: .number.precision(.fractionLength(2))) rad"
            }
        } else {
            switch angleType {
            case .degrees:
                content = "--°"
            case .radians:
                content = "-- rad"
            }
        }
        
        return DatapointView(title: title, content: content, background: background)
    }
    
    func doubleDatapoint<Background: ShapeStyle>(title: LocalizedStringKey, double: Double?, precision: Int = 0, unit: String = "", background: Background) -> some View {
        let content: LocalizedStringKey
        if var double {
            if precision == 0 && double > -1 && double < 0 {
                double = 0
            }
            
            if unit.isEmpty {
                content = "\(double, format: .number.precision(.fractionLength(precision)))"
            } else {
                content = "\(double, format: .number.precision(.fractionLength(precision))) \(unit)"
            }
        } else {
            if unit.isEmpty {
                content = "--"
            } else {
                content = "-- \(unit)"
            }
        }
        
        return DatapointView(title: title, content: content, background: background)
    }
        
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Header("Attitude")
                    angleDatapoint(title: "Pitch", angle: viewModel.motion?.attitude.pitch, background: .red.gradient)
                    angleDatapoint(title: "Roll", angle: viewModel.motion?.attitude.roll, background: .green.gradient)
                    angleDatapoint(title: "Yaw", angle: viewModel.motion?.attitude.yaw, background: .blue.gradient)
                    
                    Header("Rotation Rate")
                    doubleDatapoint(title: "X", double: viewModel.motion?.rotationRate.x, background: .gray.gradient)
                    doubleDatapoint(title: "Y", double: viewModel.motion?.rotationRate.y, background: .gray.gradient)
                    doubleDatapoint(title: "Z", double: viewModel.motion?.rotationRate.z, background: .gray.gradient)
                    
                    Header("User Acceleration")
                    doubleDatapoint(title: "X", double: viewModel.motion?.userAcceleration.x, unit: "G", background: .gray.gradient)
                    doubleDatapoint(title: "Y", double: viewModel.motion?.userAcceleration.y, unit: "G", background: .gray.gradient)
                    doubleDatapoint(title: "Z", double: viewModel.motion?.userAcceleration.z, unit: "G", background: .gray.gradient)
                    
                    Header("Gravity")
                    doubleDatapoint(title: "X", double: viewModel.motion?.gravity.x, precision: 1, unit: "G", background: .gray.gradient)
                    doubleDatapoint(title: "Y", double: viewModel.motion?.gravity.y, precision: 1, unit: "G", background: .gray.gradient)
                    doubleDatapoint(title: "Z", double: viewModel.motion?.gravity.z, precision: 1, unit: "G", background: .gray.gradient)
                    
                    Header("Magnetic Field")
                    angleDatapoint(title: "Heading", angle: (viewModel.motion?.heading).map { $0 * .pi / 180 }, background: .brown.gradient)
                    doubleDatapoint(title: "X", double: viewModel.motion?.magneticField.field.x, unit: "µT", background: .gray.gradient)
                    doubleDatapoint(title: "Y", double: viewModel.motion?.magneticField.field.y, unit: "µT", background: .gray.gradient)
                    doubleDatapoint(title: "Z", double: viewModel.motion?.magneticField.field.z, unit: "µT", background: .gray.gradient)
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Angle", selection: $angleType) {
                        Text("deg").tag(AngleType.degrees)
                        Text("rad").tag(AngleType.radians)
                    }
                    .pickerStyle(.segmented)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isStarted {
                        Button {
                            viewModel.stop()
                        } label: {
                            Label("Stop", systemImage: "stop.fill")
                        }
                    } else {
                        Button {
                            viewModel.start()
                        } label: {
                            Label("Start", systemImage: "play.fill")
                        }
                    }
                }
            }
        }
    }
}

struct Header: View {
    var content: LocalizedStringKey
    
    init(_ content: LocalizedStringKey) {
        self.content = content
    }
    
    var body: some View {
        Text(content)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.vertical)
    }
}

struct DatapointView<Background: ShapeStyle>: View {
    var title: LocalizedStringKey
    var content: LocalizedStringKey
    var background: Background
    
    var body: some View {
        NavigationLink {
            Text(content)
                .font(.system(size: 144).monospaced())
                .fontWeight(.bold)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundStyle(.white)
                .navigationTitle(title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background, ignoresSafeAreaEdges: .all)
        } label: {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Text(content)
                    .font(.title.monospaced())
                    .fontWeight(.bold)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.forward")
                    .opacity(0.7)
            }
            .padding()
            .foregroundStyle(.white)
            .background(background)
            .clipShape(.rect(cornerRadius: 24))
        }
    }
}

#Preview {
    ContentView()
}
