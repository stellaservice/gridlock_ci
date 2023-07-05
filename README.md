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
