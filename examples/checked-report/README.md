# Checked delivery example

Run `Rscript run.R` from this directory with dataraft.core and dataraft.adapters
installed. Set DATARAFT_EXAMPLE_OUTPUT to retain the release directory. The example
writes a versioned RDS delivery, ODCS contract and quality report without DuckDB.
The printed version pins subsequent reads with dr_source_rds().

This directory is ready to copy into a separate example repository. Its workflow
installs the two components and runs the script. It is also exercised in the
family CI, so the example is checked before a separate repository is published.
