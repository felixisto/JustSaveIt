//
//  CategoryView.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI

struct CategoryView: View {
    @ObservedObject var model: CategoryViewModel
    
    @State private var isPresenting = false
    
    var body: some View {
        VStack {
            HStack {
                Image(uiImage: model.info.image)
                    .resizable()
                    .frame(width: nil, height: 128)
                    .clipShape(Circle())
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            
            List {
                ForEach(model.items) { item in
                    NavigationLink(destination: ItemView(model: model.itemViewModel(for: item))) {
                        HStack {
                            Image(uiImage: item.image)
                                .resizable()
                                .frame(width: 48, height: 48)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(item.title)
                                
                                StarRatingView(model: model.itemViewModel(for: item).starRatingVM, isMutable: false)
                            }
                        }
                    }
                }
                .onDelete(perform: onDeleteItems)
            }
            .navigationBarTitle(model.info.title, displayMode: .inline)
            .toolbar {
                Button(action: onAddItem) {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $isPresenting, content: {
                MakeItemView(isPresented: $isPresenting, model: buildItemViewModel())
            })
        }
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
extension CategoryView {
    func buildItemViewModel() -> MakeItemViewModel {
        let dependencies = MakeItemViewModelDependencies.make(from: model.dependencies)
        return MakeItemViewModel(dependencies: dependencies, categoryName: model.categoryName)
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(model: buildModel())
    }
    
    static func buildModel() -> CategoryViewModel {
        let primaryVM = JustSaveItApp.buildDefaultPrimaryVM(context: CoreDataStorage.preview.container.viewContext)
        let info = CategoryViewInfo(title: "Title", imageID: "0", image: UIImage())
        let dependencies = CategoryViewModelDependencies.make(from: primaryVM.dependencies)
        return CategoryViewModel(dependencies: dependencies, info: info)
    }
}
