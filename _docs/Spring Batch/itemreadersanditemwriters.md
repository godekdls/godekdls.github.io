---
title: ItemReaders and ItemWriters
category: Spring Batch
order: 7
---

### 목차

6.1. ItemReader
6.2. ItemWriter
6.3. ItemProcessor
6.3.1. Chaining ItemProcessors
6.3.2. Filtering Records
6.3.3. Fault Tolerance
6.4. ItemStream
6.5. The Delegate Pattern and Registering with the Step
6.6. Flat Files
6.6.1. The FieldSet
6.6.2. FlatFileItemReader
6.6.3. FlatFileItemWriter
6.7. XML Item Readers and Writers
6.7.1. StaxEventItemReader
6.7.2. StaxEventItemWriter
6.8. JSON Item Readers And Writers
6.8.1. JsonItemReader
6.8.2. JsonFileItemWriter
6.9. Multi-File Input
6.10. Database
6.10.1. Cursor-based ItemReader Implementations
JdbcCursorItemReader
HibernateCursorItemReader
StoredProcedureItemReader
6.10.2. Paging ItemReader Implementations
JdbcPagingItemReader
JpaPagingItemReader
6.10.3. Database ItemWriters
6.11. Reusing Existing Services
6.12. Validating Input
6.13. Preventing State Persistence
6.14. Creating Custom ItemReaders and ItemWriters
6.14.1. Custom ItemReader Example
Making the ItemReader Restartable
6.14.2. Custom ItemWriter Example
Making the ItemWriter Restartable
6.15. Item Reader and Writer Implementations
6.15.1. Decorators
SynchronizedItemStreamReader
SingleItemPeekableItemReader
MultiResourceItemWriter
ClassifierCompositeItemWriter
ClassifierCompositeItemProcessor
6.15.2. Messaging Readers And Writers
AmqpItemReader
AmqpItemWriter
JmsItemReader
JmsItemWriter
KafkaItemReader
KafkaItemWriter
6.15.3. Database Readers
Neo4jItemReader
MongoItemReader
HibernateCursorItemReader
HibernatePagingItemReader
RepositoryItemReader
6.15.4. Database Writers
Neo4jItemWriter
MongoItemWriter
RepositoryItemWriter
HibernateItemWriter
JdbcBatchItemWriter
JpaItemWriter
GemfireItemWriter
6.15.5. Specialized Readers
LdifReader
MappingLdifReader
AvroItemReader
6.15.6. Specialized Writers
SimpleMailMessageItemWriter
AvroItemWriter
6.15.7. Specialized Processors
ScriptItemProcessor

## 6.1. ItemReader

## 6.2. ItemWriter

## 6.3. ItemProcessor

## 6.4. ItemStream

## 6.5. The Delegate Pattern and Registering with the Step

## 6.6. Flat Files

## 6.7. XML Item Readers and Writers

## 6.8. JSON Item Readers And Writers

## 6.9. Multi-File Input

## 6.10. Database

## 6.11. Reusing Existing Services

## 6.12. Validating Input

## 6.13. Preventing State Persistence

## 6.14. Creating Custom ItemReaders and ItemWriters

## 6.15. Item Reader and Writer Implementations