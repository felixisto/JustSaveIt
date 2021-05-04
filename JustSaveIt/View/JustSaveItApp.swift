//
//  JustSaveItApp.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI
import CoreData
import Combine

@main
struct JustSaveItApp: App {
    public static let categoriesRepo = CategoriesRepositoryImpl(context: CoreDataStorage.shared.container.viewContext)
    public static let itemsRepo = ItemsRepositoryImpl(context: CoreDataStorage.shared.container.viewContext)
    
    let coreDataStorage = CoreDataStorage.shared
    
    var body: some Scene {
        WindowGroup {
            PrimaryView(model: JustSaveItApp.buildDefaultPrimaryVM(context: coreDataStorage.container.viewContext))
                .environment(\.managedObjectContext, coreDataStorage.container.viewContext)
        }
    }
    
    static func buildDefaultPrimaryVM(context: NSManagedObjectContext) -> PrimaryViewModel {
        let dependencies = PrimaryViewModelDependencies(categoriesRepository: categoriesRepo, itemsRepository: itemsRepo, categoryImageRepo: CategoryImageRepository(), itemImageRepo: ItemImageRepository(), categoriesParser: PrimaryViewItemParser(), itemsParser: CategoryViewItemParser(), imagePicker: ImagePicker(), categoryTextValidator: UserCategoryTextValidator(categoriesRepo: categoriesRepo), itemTextValidator: UserItemTextValidator(itemsRepo: itemsRepo))
        
        return PrimaryViewModel(dependencies: dependencies)
    }
}
