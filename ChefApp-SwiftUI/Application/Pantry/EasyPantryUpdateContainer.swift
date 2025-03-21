////
////  EasyPantryUpdateContainer.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 11/29/24.
////
//
//import SwiftUI
//
//struct EasyPantryUpdateContainer: View {
//    
//    let onClose: () -> Void
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
//    
//    @State private var selectedItems: [PantryItem] = []
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                
//                
//                EasyPantryUpdateView(
//                    olderThanDays: constantsUpdater.easyPantryUpdateContainerOlderThanDays,
//                    onClose: onClose,
//                    selectedItems: $selectedItems,
//                    beforeDaysAgoDateSectionedPantryItems: SectionedFetchRequest<String?, PantryItem>(
//                        sectionIdentifier: \.daysAgoString,
//                        sortDescriptors: [
//                            NSSortDescriptor(keyPath: \PantryItem.updateDate, ascending: true),
//                            NSSortDescriptor(keyPath: \PantryItem.name, ascending: true)
//                        ],
//                        predicate: NSPredicate(format: "%K <= %@", #keyPath(PantryItem.updateDate), Calendar.current.date(byAdding: .day, value: -constantsUpdater.easyPantryUpdateContainerOlderThanDays, to: Date())! as NSDate),
//                        animation: .default))
//                
//                Spacer()
//            }
//            .padding()
//        }
//        .background(Colors.background)
//    }
//}
//
//extension View {
//    
//    func easyPantryUpdateContainerPopup(isPresented: Binding<Bool>) -> some View {
//        self
//            .fullScreenCover(isPresented: isPresented) {
//                NavigationStack {
//                    EasyPantryUpdateContainer(onClose: {
//                        isPresented.wrappedValue = false
//                    })
//                }
//            }
//    }
//    
//}
//
//#Preview {
//    
//    NavigationStack {
//        EasyPantryUpdateContainer(onClose: {
//            
//        })
//    }
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    .environmentObject(ConstantsUpdater())
//    
//}
