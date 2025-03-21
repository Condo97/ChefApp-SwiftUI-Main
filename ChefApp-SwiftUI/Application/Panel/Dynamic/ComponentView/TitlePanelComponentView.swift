//
//  TitlePanelComponentView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import SwiftUI

struct TitlePanelComponentView: View {
    
    var panelComponent: PanelComponent
    
//    var title: String
//    var detailTitle: String?
//    var detailText: String?
    
    @State private var detailPresented = false
    
    var body: some View {
        HStack {
            Text(panelComponent.title)
                .font(.custom(Constants.FontName.body, size: 17.0))
                .minimumScaleFactor(0.5)
                .lineLimit(1, reservesSpace: false)
            
            if panelComponent.requiredUnwrapped {
                Text("*")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                    .foregroundStyle(Colors.elementBackground)
            } else {
                Text("(optional)")
                    .font(.custom(Constants.FontName.light, size: 14.0))
                    .foregroundStyle(Colors.foregroundText)
                    .opacity(0.40)
            }
            
            if panelComponent.detailTitle != nil && panelComponent.detailText != nil {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    detailPresented = true
                }) {
                    Text(Image(systemName: "info.circle"))
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
                        .font(.custom(Constants.FontName.body, size: 24.0))
//                        .frame(maxHeight: 28)
                }
                .foregroundStyle(Colors.elementBackground)
            }
            
            Spacer()
        }
        .alert(panelComponent.detailTitle ?? "", isPresented: $detailPresented) {
            Button("Done", role: .cancel) {}
        } message: {
            Text(panelComponent.detailText ?? "")
        }
    }
    
}

#Preview {
    let dropdownPanelComponentViewConfig = DropdownPanelComponentViewConfig(
        items: [
            "Item 1",
            "Item 2"
        ])
    
    return VStack {
        TitlePanelComponentView(
            panelComponent: PanelComponent(
                input: .dropdown(dropdownPanelComponentViewConfig),
                title: "Title title title title title title",
                detailTitle: "Detail Title",
                detailText: "Detail Text",
                promptPrefix: "Prompt Prefix",
                required: true)
        )
    }
}
