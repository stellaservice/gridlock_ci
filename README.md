# GridlockCi

Client gem to run RSpec via GridlockCi dynamic test splitting.  This client library communicates with GridlockCi server to enqueue and retrieve specs.

## Installation

`gem install gridlock_ci`

## Usage

Before parallel steps, enqueue all specs via `gridlock_ci enqueue`
```sh
bundle exec gridlock_ci enqueue --run_id ${{ github.run_id }} --run_attempt ${{ github.run_attempt }}
```

For each parallel runner, run rspec vis `gridlock_ci run`
```sh
bundle exec gridlock_ci run --run_id ${{ github.run_id }} --run_attempt ${{ github.run_attempt }}
```

## RSpec run options

RSpec options may be passed via flags.

Example: `--rspec '--tag=foo --format progress'`

*Keep in mind some options may not work as intended because each spec file is run individually, and data is cleared between runs.  This will affect formatters final outputs and rspec options like `--profile`*

## Junit output

Junit output is supported via flag: `--junit-output FilePath`.  Do not use the RSpec formatter for the reasons explained above.

## Upload results

Results can be uploaded to the server for analysis

```sh
bundle exec gridlock_ci upload_results --run_id 1 --run_attempt 1 --file_path FilePath
```
