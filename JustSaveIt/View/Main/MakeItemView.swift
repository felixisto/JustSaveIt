//
//  MakeItemView.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI
import CoreData

struct MakeItemView: View {
    @Binding var isPresented: Bool
    @StateObject var model: MakeItemViewModel
    
    @State private var showErrorAlert = false
    @State private var errorAlertText = ""
    
    @ObservedObject private var keyboard = KeyboardResponder.shared
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                if keyboard.currentHeight == 0 {
                    PickItemImageView(model: model.pickItemImageModel)
                        .frame(width: nil, height: 256, alignment: .center)
                    
                    Spacer().frame(width: nil, height: 10, alignment: .center)
                }
                
                TextField("Name", text: $model.name)
                
                Spacer().frame(width: nil, height: 10, alignment: .center)
                
                TextField("My description", text: $model.userDescription)
                    .foregroundColor(Color.gray)
                
                Spacer().frame(width: nil, height: 10, alignment: .center)
                
                StarRatingView(model: model.pickUserRatingModel, isMutable: true)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create", action: onCreate)
                }
            }
            .navigationBarTitle("New item", displayMode: .inline)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        }.alert(isPresented: $showErrorAlert, content: {
            Alert(title: Text(errorAlertText))
        })
        .padding(.bottom, keyboard.currentHeight)
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeOut(duration: 0.16))
    }
    
    func onCancel() {
        self.isPresented = false
    }
    
    func onCreate() {
        let success = {
            self.isPresented = false
        }
        
        let failure = { (error: Error) in
            self.errorAlertText = model.errorMessage(for: error)
            self.showErrorAlert = true
        }
        
        model.saveAndExit(withSuccess: success, failure: failure)
    }
}

struct MakeItemView_Preview: View {
    private var viewContext: NSManagedObjectContext {
        return CoreDataStorage.shared.container.viewContext
    }
    
    @State var isMakeCategoryPresented = false
    
    var body: some View {
        MakeItemView(isPresented: $isMakeCategoryPresented, model: buildModel())
    }
    
    func buildModel() -> MakeItemViewModel {
        let itemsRepo = ItemsRepositoryImpl(context: viewContext)
        let dependencies = MakeItemViewModelDependencies(itemsRepo: itemsRepo, itemImageRepo: CategoryImageRepository(), imagePicker: ImagePicker(), itemTextValidator: UserItemTextValidator(itemsRepo: itemsRepo))
        let model = MakeItemViewModel(dependencies: dependencies, categoryName: "Category")
        model.pickItemImageModel.onPicked(image: UIImage(named: "ImageSample1")!)
        return model
    }
}

struct MakeItemView_Previews: PreviewProvider {
    static var previews: some View {
        MakeItemView_Preview()
    }
}
