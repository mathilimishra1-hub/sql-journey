
# sql-journey
# 🚀 SQL Data Warehouse | Medallion Architecture

A modern, scalable, and production-ready **SQL Data Warehouse** built using the industry-standard **Medallion Architecture**. This project demonstrates how raw data can be transformed into reliable, analytics-ready datasets through structured ETL pipelines and optimized dimensional modeling.

---

## 📖 Overview

This repository showcases the complete development lifecycle of a Data Warehouse—from ingesting raw source data to delivering business-ready insights. It follows the **Bronze → Silver → Gold** layered architecture, a widely adopted approach in modern data engineering.

The project focuses on:

- Building a scalable warehouse architecture
- Developing robust ETL pipelines
- Designing efficient analytical models
- Generating meaningful business insights using SQL

---

## 🏛️ Architecture

The warehouse is organized into three logical layers:
<img width="1536" height="1024" alt="sqlDiagram" src="https://github.com/user-attachments/assets/bf35ec41-c89d-46e7-a094-b13536cce6a7" />

### 🥉 Bronze Layer — Raw Data
- Stores source data in its original form.
- Preserves historical records.
- Acts as the system of record.

### 🥈 Silver Layer — Cleaned Data
- Standardizes formats and data types.
- Removes duplicates and invalid records.
- Applies business rules and transformations.

### 🥇 Gold Layer — Analytics Ready
- Contains curated fact and dimension tables.
- Optimized for reporting and business intelligence.
- Enables fast analytical querying.

---

## 🎯 Objectives

- Ingest data from multiple source systems.
- Ensure data quality and consistency.
- Create a reliable analytical foundation.
- Support business reporting and decision-making.
- Demonstrate real-world data engineering practices.

---

## 🔄 End-to-End Workflow

```text
Source Systems
      ↓
   Bronze Layer
      ↓
   Silver Layer
      ↓
    Gold Layer
      ↓
Analytics & Reporting
