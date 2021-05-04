//
//  MakeCategoryView.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI
import CoreData

struct MakeCategoryView: View {
    @Binding var isPresented: Bool
    @StateObject var model: MakeCategoryViewModel
    
    @State private var isPresentingError = false
    @State private var errorAlertText = ""
    
    @ObservedObject private var keyboard = KeyboardResponder.shared
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                if keyboard.currentHeight == 0 {
                    PickItemImageView(model: model.pickItemImageModel)
                        .frame(width: nil, height: 256, alignment: .center)
                        .padding(.bottom, keyboard.currentHeight)
                    
                    Spacer().frame(width: nil, height: 10, alignment: .center)
                }
                
                TextField("Name", text: $model.name)
                
                Spacer().frame(width: nil, height: 10, alignment: .center)
                
                TextField("My description", text: $model.userDescription)
                
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
            .navigationBarTitle("New category", displayMode: .inline)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        }.alert(isPresented: $isPresentingError, content: {
            Alert(title: Text(errorAlertText))
        })
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
            self.isPresentingError = true
        }
        
        model.saveAndExit(withSuccess: success, failure: failure)
    }
}

struct MakeCategoryView_Preview: View {
    private var viewContext: NSManagedObjectContext {
        return CoreDataStorage.shared.container.viewContext
    }
    
    @State var isMakeCategoryPresented = false
    
    var body: some View {
        MakeCategoryView(isPresented: $isMakeCategoryPresented, model: buildModel())
    }
    
    func buildModel() -> MakeCategoryViewModel {
        let categoriesRepo = CategoriesRepositoryImpl(context: viewContext)
        let dependencies = MakeCategoryViewModelDependencies(categoriesRepository: categoriesRepo, imageRepo: CategoryImageRepository(), imagePicker: ImagePicker(), categoryTextValidator: UserCategoryTextValidator(categoriesRepo: categoriesRepo))
        let model = MakeCategoryViewModel(dependencies: dependencies)
        model.pickItemImageModel.onPicked(image: UIImage(named: "ImageSample1")!)
        return model
    }
}

struct MakeCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        MakeCategoryView_Preview()
    }
}
