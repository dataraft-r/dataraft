# Chapter dependency and learning map

```mermaid
flowchart LR
  A[1-3 Problem and mental model] --> B[4 First workflow]
  B --> C[5 Contracts]
  B --> D[6 Quality]
  C --> E[7 Recipes]
  D --> F[8 Execution]
  E --> F
  F --> G[9 Storage]
  G --> H[10 Composition]
  H --> I[11-14 Evidence and governance]
  I --> J[15-17 Platform architecture]
  J --> K[18 Complete project]
  K --> L[19 Change safely]
  L --> M[20 Operate]
  M --> N[21-22 Design boundaries]
```

The first four chapters are sufficient to explain DataRaft and run an in-memory product. Storage appears only after the acceptance model is clear. Part VI then turns the concepts into a runnable local platform, changes it deliberately, and adds an operating routine before the final design chapters.
