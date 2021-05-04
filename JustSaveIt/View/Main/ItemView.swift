//
//  ItemView.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI

struct ItemView: View {
    @ObservedObject var model: ItemViewModel
    
    @State private var isPresentingError = false
    @State private var errorAlertText = ""
    
    @ObservedObject private var keyboard = KeyboardResponder.shared
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if keyboard.currentHeight == 0 {
                Image(uiImage: model.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: nil, height: 320, alignment: .center)
                
                Spacer().frame(width: nil, height: 10, alignment: .center)
            }
            
            TextField("No description",
                      text: $model.info.description,
                      onCommit: {
                        saveDescription()
                      })
            
            Spacer().frame(width: nil, height: 10, alignment: .center)
            
            Text(model.info.dateCreatedFormatted)
            
            Spacer().frame(width: nil, height: 10, alignment: .center)
            
            StarRatingView(model: buildStarRatingViewModel(), isMutable: true)
            
            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .navigationBarTitle(model.info.title, displayMode: .inline)
        .alert(isPresented: $isPresentingError, content: {
            Alert(title: Text(errorAlertText))
        })
    }
    
    func saveDescription() {
        do {
            try model.saveDescription()
        } catch let e {
            self.errorAlertText = model.errorMessage(for: e)
            self.isPresentingError = true
        }
    }
}

extension ItemView {
    func buildStarRatingViewModel() -> StarRatingViewModel {
        let dependencies = StarRatingViewModelDependencies(itemsRepo: model.dependencies.itemsRepo)
        let itemInfo = model.info
        return StarRatingViewModel(dependencies: dependencies, itemInfo: itemInfo, saveChanges: true)
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(model: buildModel())
    }
    
    static func buildModel() -> ItemViewModel {
        let primaryVM = JustSaveItApp.buildDefaultPrimaryVM(context: CoreDataStorage.preview.container.viewContext)
        let dependencies = ItemViewModelDependencies(itemsRepo: primaryVM.dependencies.itemsRepository, itemImageRepo: primaryVM.dependencies.itemImageRepo, itemTextValidator: primaryVM.dependencies.itemTextValidator)
        let info = ItemViewInfo(title: "Title", description: "Description", imageID: "0", userRating: 5, dateCreated: Date(), categoryName: "Category")
        return ItemViewModel(dependencies: dependencies, info: info)
    }
}
