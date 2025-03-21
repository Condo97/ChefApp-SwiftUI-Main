//
//  EasyPantryUpdateView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/29/24.
//

import SwiftUI

struct EasyPantryUpdateView: View {
    
    // TODO: When submitted, update updateDate
    
    let onClose: () -> Void
    //    var beforeDaysAgoDateSectionedPantryItems: SectionedFetchResults<String?, PantryItem>
    
    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedItems: [PantryItem] = []
    
    private var beforeDaysAgoDateSectionedPantryItemsFetchRequest: SectionedFetchRequest<String?, PantryItem> {
        SectionedFetchRequest<String?, PantryItem>(
            sectionIdentifier: \.daysAgoString,
            sortDescriptors: [
                NSSortDescriptor(keyPath: \PantryItem.updateDate, ascending: true),
                NSSortDescriptor(keyPath: \PantryItem.name, ascending: true)
            ],
            predicate: NSPredicate(format: "%K <= %@", #keyPath(PantryItem.updateDate), Calendar.current.date(byAdding: .day, value: -constantsUpdater.easyPantryUpdateContainerOlderThanDays, to: Date())! as NSDate),
            animation: .default)
    }
    
    var body: some View {
        DynamicSectionedFetchRequestView(
            withSectionedFetchRequest: beforeDaysAgoDateSectionedPantryItemsFetchRequest) { beforeDaysAgoDateSectionedPantryItems in
                ScrollView {
                    var allSelected: Bool {
                        selectedItems.count == beforeDaysAgoDateSectionedPantryItems.reduce(0) { $0 + $1.count } // This sums up the items in each section
                    }
                    
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Remove Old Items...")
                                .font(.custom(Constants.FontName.heavy, size: 24.0))
                                .padding(.horizontal)
                            HStack {
                                Text("Showing items older than")
                                    .font(.custom(Constants.FontName.body, size: 14.0))
                                Menu(content: {
                                    ForEach(0...11, id: \.self) { index in
                                        Button(action: {
                                            // Reset selectedItems
                                            selectedItems = []
                                            
                                            // Set older than days
                                            constantsUpdater.easyPantryUpdateContainerOlderThanDays = index
                                        }) {
                                            Text("\(index) days")
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("\(constantsUpdater.easyPantryUpdateContainerOlderThanDays) days")
                                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                                            .underline()
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                    }
                                    .foregroundStyle(Colors.elementBackground)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        
                        Button(action: { // TODO: Move this to PantryItemsView so that it will show in all its uses
                            if allSelected {
                                // If all selected remove all from selected items
                                selectedItems = []
                            } else {
                                // If not selected select all
                                selectedItems = beforeDaysAgoDateSectionedPantryItems.flatMap { section in
                                    section.compactMap { pantryItem in
                                        pantryItem as PantryItem
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Text(allSelected ? "Deselect All" : "Select All")
                                    .font(.heavy, 17)
                                Spacer()
                                Image(systemName: allSelected ? "checkmark.circle.fill" : "checkmark.circle")
                            }
                            .foregroundStyle(Colors.elementBackground)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Colors.elementText)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            .padding(.horizontal)
                        }
                        
                        if beforeDaysAgoDateSectionedPantryItems.isEmpty {
                            Text("No Items")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(Colors.foregroundText)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Colors.foreground.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        } else {
                            PantryItemsView(
                                selectedItems: $selectedItems,
                                editMode: .constant(.inactive),
                                sectionedPantryItems: beforeDaysAgoDateSectionedPantryItemsFetchRequest,
                                showsContextMenu: false,
                                selectionColor: .red)
                        }
                    }
                }
                .toolbarBackground(Colors.elementBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image(Constants.ImageName.navBarLogoImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Colors.elementText)
                            .frame(maxHeight: 38.0)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            onClose()
                        }) {
                            Text("Close")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(Colors.elementText)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            Task {
                                for selectedItem in selectedItems {
                                    do {
                                        try await CDClient.delete(selectedItem, in: viewContext)
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error deleting pantry item in EasyPantryUpdateContainer, continuing... \(error)")
                                    }
                                }
                                
                                for pantryItemElement in beforeDaysAgoDateSectionedPantryItems {
                                    for pantryItem in pantryItemElement {
                                        // Set each item's updateDate to one day before the olderThanDays in reference to the current date TODO: Should this be in reference to the ingredient's date? No, because if the item is like 5 days old and olderThanDays is 3, it will set it to 2 days old so that the next day it will show up in the easy pantry update view
                                        let newUpdateDate = Calendar.current.date(
                                            byAdding: .day,
                                            value: constantsUpdater.easyPantryUpdateContainerOlderThanDays <= 0 ? 0 : -constantsUpdater.easyPantryUpdateContainerOlderThanDays + 1, // Make sure the olderThanDays result is not less than zero
                                            to: Date()) ?? Date()
                                        
                                        try await PantryItemCDClient.updatePantryItem(pantryItem, updateDate: newUpdateDate, in: viewContext)
                                    }
                                }
                            }
                            
                            onClose()
                        }) {
                            Text("Save")
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                                .foregroundStyle(Colors.elementText)
                        }
                    }
                }
            }
            .background(Colors.background)
    }
    
}

extension View {
    
    func easyPantryUpdatePopup(isPresented: Binding<Bool>) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                NavigationStack {
                    EasyPantryUpdateView(onClose: {
                        isPresented.wrappedValue = false
                    })
                }
            }
    }
    
}

#Preview {
    
    NavigationStack {
        EasyPantryUpdateView(
            onClose: {
                
            })
    }
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
