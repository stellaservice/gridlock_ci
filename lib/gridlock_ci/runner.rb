module GridlockCi
  class Runner
    attr_reader :run_id, :run_attempt

    def initialize(run_id, run_attempt)
      @run_id = run_id
      @run_attempt = run_attempt
    end

    def run(rspec_opts = [])
      gridlock = GridlockCi::Client.new(run_id, run_attempt)
      exitstatus = 0
      failed_specs = []

      loop do
        spec = gridlock.next_spec
        rspec_opts.insert(0, spec)

        break if spec.nil?

        options = RSpec::Core::ConfigurationOptions.new(rspec_opts)
        rspec_runner = RSpec::Core::Runner.new(options)

        status_code = rspec_runner.run($stderr, $stdout)

        if status_code.positive?
          exitstatus = status_code
          failed_specs << spec
        end

        clear_rspec_examples
      end

      return unless exitstatus.positive?

      enqueue_failed_specs(failed_specs)
      exit exitstatus
    end

    private

    def enqueue_failed_specs(failed_specs)
      gridlock = GridlockCi::Client.new(run_id, run_attempt + 1)

      gridlock.send_specs(failed_specs)
    end

    def clear_rspec_examples
      if RSpec::ExampleGroups.respond_to?(:remove_all_constants)
        RSpec::ExampleGroups.remove_all_constants
      else
        RSpec::ExampleGroups.constants.each do |constant|
          RSpec::ExampleGroups.__send__(:remove_const, constant)
        end
      end
      RSpec.world.example_groups.clear
      RSpec.configuration.start_time = RSpec::Core::Time.now
      RSpec.configuration.reset
    end
  end
end
