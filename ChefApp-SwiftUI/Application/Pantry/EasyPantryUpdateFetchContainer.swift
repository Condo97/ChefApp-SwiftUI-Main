//
//  EasyPantryUpdateFetchContainer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/25/25.
//

import SwiftUI

struct EasyPantryUpdateFetchContainer: View {
    
    let onClose: () -> Void
    
    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        EasyPantryUpdateView(
            beforeDaysAgoDateSectionedPantryItems: SectionedFetchRequest<String?, PantryItem>(
                sectionIdentifier: \.daysAgoString,
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \PantryItem.updateDate, ascending: true),
                    NSSortDescriptor(keyPath: \PantryItem.name, ascending: true)
                ],
                predicate: NSPredicate(format: "%K <= %@", #keyPath(PantryItem.updateDate), Calendar.current.date(byAdding: .day, value: -constantsUpdater.easyPantryUpdateContainerOlderThanDays, to: Date())! as NSDate),
                animation: .default),
            onClose: onClose)
    }
    
}

extension View {
    
    func easyPantryUpdatePopup(isPresented: Binding<Bool>) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                NavigationStack {
                    EasyPantryUpdateFetchContainer(onClose: {
                        isPresented.wrappedValue = false
                    })
                }
            }
    }
    
}

#Preview {
    
    EasyPantryUpdateFetchContainer(onClose: {})
    
}
