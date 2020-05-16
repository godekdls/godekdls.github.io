---
title: ItemReaders and ItemWriters
category: Spring Batch
order: 7
---

### 목차

- [6.1. ItemReader](#61-itemreader)
- [6.2. ItemWriter](#62-itemwriter)
- [6.3. ItemProcessor](#63-itemprocessor)
  + [6.3.1. Chaining ItemProcessors](#631-chaining-itemprocessors)
  + [6.3.2. Filtering Records](#632-filtering-records)
  + [6.3.3. Fault Tolerance](#633-fault-tolerance)
- [6.4. ItemStream](#64-itemstream)
- [6.5. The Delegate Pattern and Registering with the Step](#65-the-delegate-pattern-and-registering-with-the-step)
- [6.6. Flat Files](#66-flat-files)
  + [6.6.1. The FieldSet](#661-the-fieldset)
  + [6.6.2. FlatFileItemReader](#662-flatfileitemreader)
  + [6.6.3. FlatFileItemWriter](#663-flatfileitemwriter)
- [6.7. XML Item Readers and Writers](#67-xml-item-readers-and-writers)
  + [6.7.1. StaxEventItemReader](#671-staxeventitemreader)
  + [6.7.2. StaxEventItemWriter](#672-staxeventitemwriter)
- [6.8. JSON Item Readers And Writers](#68-json-item-readers-and-writers)
  + [6.8.1. JsonItemReader](#681-jsonitemreader)
  + [6.8.2. JsonFileItemWriter](#682-jsonfileitemwriter)
- [6.9. Multi-File Input](#69-multi-file-input)
- [6.10. Database](#610-database)
  + [6.10.1. Cursor-based ItemReader Implementations](#6101-cursor-based-itemreader-implementations)
    * [JdbcCursorItemReader](#jdbccursoritemreader)
    * [HibernateCursorItemReader](#hibernatecursoritemreader)
    * [StoredProcedureItemReader](#storedprocedureitemreader)
  + [6.10.2. Paging ItemReader Implementations](#6102-paging-itemreader-implementations)
    * [JdbcPagingItemReader](#jdbcpagingitemreader)
    * [JpaPagingItemReader](#jpapagingitemreader)
  + [6.10.3. Database ItemWriters](#6103-database-itemwriters)
- [6.11. Reusing Existing Services](#611-reusing-existing-services)
- [6.12. Validating Input](#612-validating-input)
- [6.13. Preventing State Persistence](#613-preventing-state-persistence)
- [6.14. Creating Custom ItemReaders and ItemWriters](#614-creating-custom-itemreaders-and-itemwriters)
  + [6.14.1. Custom ItemReader Example](#6141-custom-itemreader-example)
    * [Making the ItemReader Restartable](#making-the-itemreader-restartable)
  + [6.14.2. Custom ItemWriter Example](#6142-custom-itemwriter-example)
    * [Making the ItemWriter Restartable](#making-the-itemwriter-restartable)
- [6.15. Item Reader and Writer Implementations](#615-item-reader-and-writer-implementations)
  + [6.15.1. Decorators](#6151-decorators)
    * [SynchronizedItemStreamReader](#synchronizeditemstreamreader)
    * [SingleItemPeekableItemReader](#singleitempeekableitemreader)
    * [MultiResourceItemWriter](#multiresourceitemwriter)
    * [ClassifierCompositeItemWriter](#classifiercompositeitemwriter)
    * [ClassifierCompositeItemProcessor](#classifiercompositeitemprocessor)
  + [6.15.2. Messaging Readers And Writers](#6152-messaging-readers-and-writers)
    * [AmqpItemReader](#amqpitemreader)
    * [AmqpItemWriter](#amqpitemwriter)
    * [JmsItemReader](#jmsitemreader)
    * [JmsItemWriter](#jmsitemwriter)
    * [KafkaItemReader](#kafkaitemreader)
    * [KafkaItemWriter](#kafkaitemwriter)
  + [6.15.3. Database Readers](#6153-database-readers)
    * [Neo4jItemReader](#neo4jitemreader)
    * [MongoItemReader](#neo4jitemwriter)
    * [HibernateCursorItemReader](#hibernatecursoritemreader)
    * [HibernatePagingItemReader](#hibernatepagingitemreader)
    * [RepositoryItemReader](#repositoryitemreader)
  + [6.15.4. Database Writers](#6154-database-writers)
    * [Neo4jItemWriter](#neo4jitemwriter)
    * [MongoItemWriter](#mongoitemwriter)
    * [RepositoryItemWriter](#repositoryitemwriter)
    * [HibernateItemWriter](#hibernateitemwriter)
    * [JdbcBatchItemWriter](#jdbcbatchitemwriter)
    * [JpaItemWriter](#jpaitemwriter)
    * [GemfireItemWriter](#gemfireitemwriter)
  + [6.15.5. Specialized Readers](#6155-specialized-readers)
    * [LdifReader](#ldifreader)
    * [MappingLdifReader](#mappingldifreader)
    * [AvroItemReader](#avroitemreader)
  + [6.15.6. Specialized Writers](#6156-specialized-writers)
    * [SimpleMailMessageItemWriter](#simplemailmessageitemwriter)
    * [AvroItemWriter](#avroitemwriter)
  + [6.15.7. Specialized Processors](#6157-specialized-processors)
    * [ScriptItemProcessor](#scriptitemprocessor)



## 6.1. ItemReader

## 6.2. ItemWriter

## 6.3. ItemProcessor

### 6.3.1. Chaining ItemProcessors

### 6.3.2. Filtering Records

### 6.3.3. Fault Tolerance

## 6.4. ItemStream

## 6.5. The Delegate Pattern and Registering with the Step

## 6.6. Flat Files

### 6.6.1. The FieldSet

### 6.6.2. FlatFileItemReader

### 6.6.3. FlatFileItemWriter

## 6.7. XML Item Readers and Writers

### 6.7.1. StaxEventItemReader

### 6.7.2. StaxEventItemWriter

## 6.8. JSON Item Readers And Writers

### 6.8.1. JsonItemReader

### 6.8.2. JsonFileItemWriter

## 6.9. Multi-File Input

## 6.10. Database

### 6.10.1. Cursor-based ItemReader Implementations

#### JdbcCursorItemReader

#### HibernateCursorItemReader

#### StoredProcedureItemReader

### 6.10.2. Paging ItemReader Implementations

#### JdbcPagingItemReader

#### JpaPagingItemReader

### 6.10.3. Database ItemWriters

## 6.11. Reusing Existing Services

## 6.12. Validating Input

## 6.13. Preventing State Persistence

## 6.14. Creating Custom ItemReaders and ItemWriters

### 6.14.1. Custom ItemReader Example

#### Making the ItemReader Restartable

### 6.14.2. Custom ItemWriter Example

#### Making the ItemWriter Restartable

### 6.15. Item Reader and Writer Implementations

### 6.15.1. Decorators

#### SynchronizedItemStreamReader

#### SingleItemPeekableItemReader

#### MultiResourceItemWriter

#### ClassifierCompositeItemWriter

#### ClassifierCompositeItemProcessor

### 6.15.2. Messaging Readers And Writers

#### AmqpItemReader

#### AmqpItemWriter

#### JmsItemReader

#### JmsItemWriter

#### KafkaItemReader

#### KafkaItemWriter

### 6.15.3. Database Readers

#### Neo4jItemReader

#### MongoItemReader

#### HibernateCursorItemReader

#### HibernatePagingItemReader

#### RepositoryItemReader

### 6.15.4. Database Writers

#### Neo4jItemWriter

#### MongoItemWriter

#### RepositoryItemWriter

#### HibernateItemWriter

#### JdbcBatchItemWriter

#### JpaItemWriter

#### GemfireItemWriter

### 6.15.5. Specialized Readers

#### LdifReader

#### MappingLdifReader

#### AvroItemReader

### 6.15.6. Specialized Writers

#### SimpleMailMessageItemWriter

#### AvroItemWriter

### 6.15.7. Specialized Processors

#### ScriptItemProcessor