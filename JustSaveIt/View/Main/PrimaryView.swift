//
//  PrimaryView.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI
import CoreData

struct PrimaryView: View {
    @ObservedObject var model: PrimaryViewModel
    
    @State private var isPresenting = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(model.items) { item in
                    NavigationLink(destination: CategoryView(model: buildCategoryVM(from: item))) {
                        HStack {
                            Image(uiImage: item.image)
                                .resizable()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                            
                            VStack {
                                Text(item.title).bold()
                                Text(item.description)
                            }
                        }
                    }
                }
                .onDelete(perform: onDeleteItems)
            }
            .toolbar {
                Button(action: onAddItem) {
                    Label("Add", systemImage: "plus")
                }
            }
            .navigationBarTitle("Categories", displayMode: .inline)
        }
        .sheet(isPresented: $isPresenting, content: {
            MakeCategoryView(isPresented: $isPresenting, model: buildMakeCategoryVM())
        })
    }

    private func onAddItem() {
        isPresenting.toggle()
    }
    
    private func onDeleteItems(offsets: IndexSet) {
        withAnimation {
            model.deleteItems(at: offsets)
        }
    }
}

// Build subview models
extension PrimaryView {
    func buildCategoryVM(from item: PrimaryViewItem) -> CategoryViewModel {
        let dependencies = CategoryViewModelDependencies.make(from: model.dependencies)
        return CategoryViewModel(dependencies: dependencies, info: CategoryViewInfo.make(from: item))
    }
    
    func buildMakeCategoryVM() -> MakeCategoryViewModel {
        let dependencies = MakeCategoryViewModelDependencies.make(from: model.dependencies)
        return MakeCategoryViewModel(dependencies: dependencies)
    }
}

struct PrimaryView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryView(model: JustSaveItApp.buildDefaultPrimaryVM(context: CoreDataStorage.preview.container.viewContext))
    }
}
