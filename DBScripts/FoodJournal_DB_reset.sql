USE master;
GO

--remove active connections from food journal db 
ALTER DATABASE FoodJournalDB
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

--drop table if it exists
DROP DATABASE IF exists FoodJournalDB;
GO

--create new database
CREATE DATABASE FoodJournalDB

--set multi user and use db
ALTER DATABASE FoodJournalDB
SET MULTI_USER;
GO

USE FoodJournalDB;