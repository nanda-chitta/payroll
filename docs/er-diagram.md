# ER Diagram

This diagram covers the core payroll domain models used by the application.

## Domain Summary

- `Department` and `JobTitle` are reference tables
- `Employee` is the central entity for identity and employment state
- `EmployeeAddress` stores address and country details
- `EmployeeSalary` stores salary records over time
- `SalaryAdjustment` records explicit salary change events against a salary row

## Diagram

```mermaid
erDiagram
    Department ||--o{ Employee : assigns
    JobTitle ||--o{ Employee : classifies
    Employee ||--o{ EmployeeAddress : stores
    Employee ||--o{ EmployeeSalary : earns
    Employee ||--o{ SalaryAdjustment : receives
    EmployeeSalary ||--o{ SalaryAdjustment : explains

    Department {
        bigint id PK
        string name UK
        string code UK
        text description
    }

    JobTitle {
        bigint id PK
        string name UK
        string code UK
        text description
    }

    Employee {
        bigint id PK
        bigint department_id FK
        bigint job_title_id FK
        string employee_code UK
        string first_name
        string middle_name
        string last_name
        string email UK
        date date_of_birth
        date hire_date
        date termination_date
        string employment_type
        string status
        datetime created_at
        datetime updated_at
    }

    EmployeeAddress {
        bigint id PK
        bigint employee_id FK
        string address_type
        string line1
        string line2
        string city
        string state
        string postal_code
        string country
        boolean primary_address
        datetime created_at
        datetime updated_at
    }

    EmployeeSalary {
        bigint id PK
        bigint employee_id FK
        decimal amount
        string currency
        string pay_frequency
        date effective_from
        date effective_to
        string reason
        text notes
        datetime created_at
        datetime updated_at
    }

    SalaryAdjustment {
        bigint id PK
        bigint employee_id FK
        bigint employee_salary_id FK
        decimal previous_amount
        decimal new_amount
        decimal change_amount
        decimal change_percentage
        date effective_from
        string reason
        text notes
        datetime created_at
        datetime updated_at
    }
```

## Relationship Notes

- A `Department` can have many employees
- A `JobTitle` can have many employees
- An `Employee` can have many addresses, but the database enforces at most one primary address
- An `Employee` can have many salary rows across time
- A `SalaryAdjustment` belongs to both an employee and a specific salary row
- The UI primarily works with an employee's current address and current salary
