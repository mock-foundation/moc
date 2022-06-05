//
//  CacheService.swift
//
//
//  Created by Егор Яковенко on 29.05.2022.
//

import Foundation
import GRDB

// MARK: - Definition

public class CacheService {
    public static var shared = CacheService()

    let dbQueue: DatabaseQueue

    var migrator = DatabaseMigrator()

    init() {
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        dbQueue = try! DatabaseQueue(path: "cache.sqlite")

        registerMigrations()
        // Migrate if not already
        if (try! dbQueue.read { db in
            try! !migrator.hasCompletedMigrations(db)
        }) {
            try! migrator.migrate(dbQueue)
        }
    }
}

// MARK: - Private methods

private extension CacheService {
    private func registerMigrations() {
        migrator.registerMigration("v1") { db in
            try db.create(table: "chatFilter") { t in
                t.column("title", .text).notNull()
                t.column("id", .integer).notNull().primaryKey(onConflict: .replace, autoincrement: false)
                t.column("iconName", .text).notNull()
                t.column("order", .integer).notNull().unique(onConflict: .replace)
            }
            
            try db.create(table: "unreadCounter") { t in
                t.column("chats", .integer).notNull()
                t.column("messages", .integer).notNull()
                t.column("chatList", .text).notNull().unique(onConflict: .replace)
            }
        }
    }

    private func save<Record>(db: Database, record: Record) throws
        where Record: FetchableRecord & PersistableRecord {
        try record.insert(db)
    }

    private func deleteAll<Record>(db: Database, records: Record.Type) throws
    where Record: FetchableRecord & PersistableRecord {
        try records.deleteAll(db)
    }
    
    private func delete<Record, Key>(from db: Database, record: Record.Type, at key: Key) throws
    where Record: FetchableRecord & PersistableRecord, Key: DatabaseValueConvertible {
        try record.deleteOne(db, key: key)
    }
    
    private func delete<Record>(from db: Database, record: Record) throws
    where Record: FetchableRecord & PersistableRecord {
        try record.delete(db)
    }

    private func getRecords<Record>(
        from db: Database,
        as record: Record.Type,
        ordered: [SQLOrderingTerm]) throws -> [Record]
    where Record: FetchableRecord & PersistableRecord {
        try record.order(ordered).fetchAll(db)
    }
    
    private func modify<Record, Key>(
        record: Record.Type,
        at key: Key,
        from db: Database,
        transform: (inout Record) -> Void) throws
    where Record: FetchableRecord & PersistableRecord, Key: DatabaseValueConvertible {
        if var value = try record.fetchOne(db, key: key) {
            try value.updateChanges(db) {
                transform(&$0)
            }
        }
    }
}

// MARK: - Public methods

public extension CacheService {
    func save<Record>(record: Record) throws
    where Record: FetchableRecord & PersistableRecord {
        try dbQueue.write { db in
            try save(db: db, record: record)
        }
    }

    func deleteAll<Record>(records: Record.Type) throws
    where Record: FetchableRecord & PersistableRecord {
        try dbQueue.write { db in
            try deleteAll(db: db, records: records)
        }
    }
    
    func delete<Record, Key>(record: Record.Type, at key: Key) throws
    where Record: FetchableRecord & PersistableRecord, Key: DatabaseValueConvertible {
        try dbQueue.write { db in
            try delete(from: db, record: record, at: key)
        }
    }
    
    func delete<Record>(record: Record) throws
    where Record: FetchableRecord & PersistableRecord {
        try dbQueue.write { db in
            try delete(from: db, record: record)
        }
    }

    func getRecords<Record>(
        as record: Record.Type,
        ordered: [SQLOrderingTerm] = []) throws -> [Record]
    where Record: FetchableRecord & PersistableRecord {
        try dbQueue.read { db in
            try getRecords(from: db, as: record, ordered: ordered)
        }
    }
    
    func modify<Record, Key>(
        record: Record.Type,
        at key: Key,
        transform: (inout Record) -> Void) throws
    where Record: FetchableRecord & PersistableRecord, Key: DatabaseValueConvertible {
        try dbQueue.write { db in
            try modify(record: record, at: key, from: db, transform: transform)
        }
    }
}
