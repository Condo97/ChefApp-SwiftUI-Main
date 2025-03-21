//
//  DropdownPanelComponentView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import SwiftUI

struct DropdownPanelComponentView: ComponentView {
    
    var panelComponent: PanelComponent
    var dropdownPanelComponentViewConfig: DropdownPanelComponentViewConfig
    
    @Binding var finalizedPrompt: String?
    @State var selected: String
    
    
    private let noneItem: String = "- None -"
    
//    private var selectedBinding: Binding<String> {
//        Binding(
//            get: {
//                selected
//            },
//            set: { newValue in
//                selected = newValue
//                updateFinalizedPrompt()
//            })
//    }
    
    init(panelComponent: PanelComponent, dropdownPanelComponentViewConfig: DropdownPanelComponentViewConfig, finalizedPrompt: Binding<String?>) {
        self.panelComponent = panelComponent
        self.dropdownPanelComponentViewConfig = dropdownPanelComponentViewConfig
        self._finalizedPrompt = finalizedPrompt
        self._selected = State(initialValue: dropdownPanelComponentViewConfig.placeholderUnwrapped)//State(initialValue: dropdownPanelComponentViewConfig.items.count > 0 ? dropdownPanelComponentViewConfig.items[0] : "")
    }
    
    func updateFinalizedPrompt() {
        // Ensure an item is selected by checking if selected is not empty, otherwise set finalizedPrompt to nil and return
        guard !selected.isEmpty else {
            finalizedPrompt = nil
            return
        }
        
        // Ensure selected item is not noneItem, otherwise set finalizedPrompt to nil and return
        guard selected != noneItem else {
            finalizedPrompt = nil
            return
        }
        
        // Set finalizedPrompt to panelComponent prompt prefix if not nil, a space, and selected item
        finalizedPrompt = (panelComponent.promptPrefix == nil ? "" : panelComponent.promptPrefix! + " ") + selected
    }
    
    var body: some View {
        VStack(spacing: 2) {
            TitlePanelComponentView(
                panelComponent: panelComponent)
            HStack {
                // Picker
                Menu {
                    Picker(selection: $selected, content: {
                        // Build each item in items in Text
                        ForEach(panelComponent.required ?? false ? dropdownPanelComponentViewConfig.items : ([noneItem] + dropdownPanelComponentViewConfig.items), id: \.self) { item in
                            Text(item)
                        }
                    }) {
                        // No label
                        Text(selected)
                            .font(.custom(Constants.FontName.medium, size: 17.0))
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .onChange(of: selected) { newSelected in
                        updateFinalizedPrompt()
                    }
                } label: {
                    Text(selected)
                        .font(.custom(Constants.FontName.medium, size: 17.0))
                    Image(systemName: "chevron.up.chevron.down")
                }
                .menuOrder(.fixed)
                .menuIndicator(.visible)
                .padding(15)
//                .background(
//                    RoundedRectangle(
//                        cornerRadius: 20.0)
//                    .fill(Colors.foreground))
                .background(
                    ZStack {
                        RoundedRectangle(
                            cornerRadius: 20.0)
                        .fill(Colors.foreground)
                        
                        RoundedRectangle(
                            cornerRadius: 20.0)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(Colors.elementBackground)
                    })
                Spacer()
            }
            .foregroundStyle(Colors.foregroundText)
            ExampleComponentView(
                panelComponent: panelComponent)
        }
    }
    
}

#Preview {
    let dropdownPanelComponentViewConfig = DropdownPanelComponentViewConfig(
        items: [
            "First",
            "Second"
        ])
    let panelComponent = PanelComponent(
        input: .dropdown(dropdownPanelComponentViewConfig),
        title: "Title",
        promptPrefix: "Prompt Prefix",
        required: true)
    
    let selected = dropdownPanelComponentViewConfig.items.count > 0 ? dropdownPanelComponentViewConfig.items[0] : ""
    
    return DropdownPanelComponentView(
        panelComponent: panelComponent,
        dropdownPanelComponentViewConfig: dropdownPanelComponentViewConfig,
        finalizedPrompt: .constant("asdfasdf"))
    .background(Colors.background)
}
