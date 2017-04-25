//
//  EKManagedObjectMapperTestCase.swift
//  EasyMappingExample
//
//  Created by Денис Тележкин on 25.04.17.
//  Copyright © 2017 EasyKit. All rights reserved.
//

import XCTest

class ManagedTestCase : XCTestCase {
    override func tearDown() {
        super.tearDown()
        
        Storage.shared.resetStorage()
        Storage.shared.context.rollback()
        Storage.shared.context.reset()
    }
    
    func numberOfObjects<T:NSManagedObject>(_ type: T.Type) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: T.entity().name ?? "")
        return (try? Storage.shared.context.count(for: request)) ?? 0
    }
}

class EKManagedObjectMapperTestCase: ManagedTestCase {
    
    func testSimpleObjectFromExternalRepresentationWithMapping() {
        let info = FixtureLoader.dictionary(fromFileNamed: "Car.json")
        let sut = EKManagedObjectMapper.object(fromExternalRepresentation: info,
                                               with: ManagedMappingProvider.carMapping(),
                                               in: Storage.shared.context) as! ManagedCar
        
        XCTAssertEqual(sut.model, info["model"] as? String)
        XCTAssertEqual(sut.year, info["year"] as? String)
    }
    
    func testExistingObject() {
        let oldCar = NSEntityDescription.insertNewObject(forEntityName: "ManagedCar",
                                                         into: Storage.shared.context) as! ManagedCar
        oldCar.carID = 1
        oldCar.year = "1980"
        oldCar.model = "i20"
        
        try! Storage.shared.context.save()
        
        let info = ["id":1,"model":"i30","year":"2013"] as [String : Any]
        
        let sut = EKManagedObjectMapper.object(fromExternalRepresentation: info,
                                               with: ManagedMappingProvider.carMapping(),
                                               in: Storage.shared.context) as! ManagedCar
        
        XCTAssertEqual(sut, oldCar)
        XCTAssertEqual(sut.carID, oldCar.carID)
        XCTAssertEqual(sut.model, info["model"] as? String)
        XCTAssertEqual(sut.year, info["year"] as? String)
        XCTAssertEqual(numberOfObjects(ManagedCar.self), 1)
    }
}
