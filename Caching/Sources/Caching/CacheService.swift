//
//  CacheService.swift
//
//
//  Created by Егор Яковенко on 29.05.2022.
//

import Foundation
import GRDB
import Logs

// MARK: - Definition

public class CacheService {
    public static var shared = CacheService()

    let dbQueue: DatabaseQueue
    var migrator = DatabaseMigrator()
    let logger = Logger(category: "CacheService", label: "Caching")

    init() {
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        var url = try! FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        if #available(macOS 13, iOS 16, *) {
            url.append(path: "cache.sqlite")
        } else {
            url.appendPathComponent("cache.sqlite")
        }
        var dir = ""
        if #available(macOS 13, iOS 16, *) {
            dir = url.path()
        } else {
            dir = url.path
        }
        logger.debug("Database path: \(dir)")
        dbQueue = try! DatabaseQueue(path: dir)

        registerMigrations()
        try! migrator.migrate(dbQueue)
        logger.notice("Started CacheService")
    }
}

// MARK: - Private methods

private extension CacheService {
    private func registerMigrations() {
        migrator.registerMigration("v1") { [self] db in
            logger.debug("Creating chatFilter table")
            try db.create(table: "chatFilter") { t in
                t.column("title", .text).notNull()
                t.column("id", .integer).notNull().primaryKey(onConflict: .replace, autoincrement: false)
                t.column("iconName", .text).notNull()
                t.column("order", .integer).notNull().unique(onConflict: .replace)
            }
            
            logger.debug("Creating unreadCounter table")
            try db.create(table: "unreadCounter") { t in
                t.column("chats", .integer).notNull()
                t.column("messages", .integer).notNull()
                t.column("chatList", .text).notNull().primaryKey(onConflict: .replace, autoincrement: false)
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
            logger.debug("Value with key \(key) exists, modifying")
            try value.updateChanges(db) {
                transform(&$0)
            }
        } else {
            logger.debug("A value with key \(key) can not be found, not modifying")
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
