//
//  DynamicFetchRequestView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/18/25.
//
// https://bsorrentino.github.io/bsorrentino/swiftui/2022/02/01/SwiftUI-Dynamically-Filtering-FetchRequest.html

import CoreData
import SwiftUI

struct DynamicFetchRequestView<T: NSManagedObject, Content: View>: View {
    
    // That will store our fetch request, so that we can loop over it inside the body.
    // However, we don’t create the fetch request here, because we still don’t know what we’re searching for.
    // Instead, we’re going to create custom initializer(s) that accepts filtering information to set the fetchRequest property.
    @FetchRequest var fetchRequest: FetchedResults<T>

    // this is our content closure; we'll call this once the fetch results is available
    let content: (FetchedResults<T>) -> Content

    var body: some View {
        self.content(fetchRequest)
    }

    // This is a generic initializer that allow to provide all filtering information
    init( withPredicate predicate: NSPredicate, andSortDescriptor sortDescriptors: [NSSortDescriptor] = [],  @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        _fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }

    // This initializer allows to provide a complete custom NSFetchRequest
    init( withFetchRequest request:FetchRequest<T>,  @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        _fetchRequest = request
        self.content = content
    }
    
}


struct DynamicSectionedFetchRequestView<I: Hashable, T: NSManagedObject, Content: View>: View {
    
    // That will store our fetch request, so that we can loop over it inside the body.
    // However, we don’t create the fetch request here, because we still don’t know what we’re searching for.
    // Instead, we’re going to create custom initializer(s) that accepts filtering information to set the fetchRequest property.
    @SectionedFetchRequest var sectionedFetchRequest: SectionedFetchResults<I, T>

    // this is our content closure; we'll call this once the fetch results is available
    let content: (SectionedFetchResults<I, T>) -> Content

    var body: some View {
        self.content(sectionedFetchRequest)
    }

    // This is a generic initializer that allow to provide all filtering information
    init(withSectionIdentifier sectionIdentifier: KeyPath<T, I>, andPredicate predicate: NSPredicate, andSortDescriptor sortDescriptors: [NSSortDescriptor] = [],  @ViewBuilder content: @escaping (SectionedFetchResults<I, T>) -> Content) {
        _sectionedFetchRequest = SectionedFetchRequest<I, T>(sectionIdentifier: sectionIdentifier, sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }

    // This initializer allows to provide a complete custom NSFetchRequest
    init(withSectionedFetchRequest request: SectionedFetchRequest<I, T>,  @ViewBuilder content: @escaping (SectionedFetchResults<I, T>) -> Content) {
        _sectionedFetchRequest = request
        self.content = content
    }
    
}
