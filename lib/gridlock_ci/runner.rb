module GridlockCi
  class Runner
    attr_reader :run_id, :run_attempt

    def initialize(run_id, run_attempt)
      @run_id = run_id
      @run_attempt = run_attempt
      @start_time = Time.now
      @reporter_data = {
        duration: 0.0,
        examples: [],
        failed_examples: [],
        pending_examples: [],
        load_time: 0.0,
        non_example_exception_count: 0
      }
    end

    def run(rspec_opts: [], junit_output: nil)
      begin
        exitstatus = 0
        all_specs = []
        failed_specs = []
        gridlock = GridlockCi::Client.new(run_id, run_attempt)

        gridlock.previous_run_completed? ||
          (raise 'Something is wrong, there are existing specs remaining in previous run.  Please retry all specs.')

        loop do
          spec = gridlock.next_spec

          break if spec.nil?

          all_specs << spec
          rspec_config_options = rspec_opts.dup.insert(0, spec)
          options = RSpec::Core::ConfigurationOptions.new(rspec_config_options)
          rspec_runner = RSpec::Core::Runner.new(options)

          status_code = rspec_runner.run($stderr, $stdout)

          if status_code.positive?
            exitstatus = status_code
            failed_specs << spec
          end

          collect_reporter_data
          clear_rspec_examples
        end

        print_summary(all_specs, failed_specs)
        output_junit(junit_output) if junit_output

        return unless exitstatus.positive?
      ensure
        enqueue_failed_specs(failed_specs) unless failed_specs.empty?
      end

      exit exitstatus
    end

    private

    def enqueue_failed_specs(failed_specs)
      gridlock = GridlockCi::Client.new(run_id, run_attempt.to_i + 1)

      gridlock.send_specs(failed_specs)
    end

    def clear_rspec_examples
      return if ENV['GRIDLOCK_TEST_ENV']

      if RSpec::ExampleGroups.respond_to?(:remove_all_constants)
        RSpec::ExampleGroups.remove_all_constants
      else
        RSpec::ExampleGroups.constants.each do |constant|
          RSpec::ExampleGroups.__send__(:remove_const, constant)
        end
      end
      RSpec.world.example_groups.clear
      RSpec.configuration.start_time = RSpec::Core::Time.now
      RSpec.configuration.reset_filters
      RSpec.configuration.reset
    end

    def print_summary(all_specs, failed_specs)
      return if ENV['GRIDLOCK_TEST_ENV']

      summary = <<~SUMMARY
        ----------------------------------------------------------------------
        #{summary_notification.fully_formatted}

        Full Spec list:
        #{all_specs.join(' ')}

        Failed Spec Files:
        #{failed_specs.join(' ')}
      SUMMARY

      puts summary
    end

    # Copy relevant data from RSpec::Core::Reporter each run before clearing
    def collect_reporter_data
      reporter = RSpec.configuration.reporter
      @reporter_data.each_key do |key|
        @reporter_data[key] += reporter.instance_variable_get("@#{key}")
      end
    end

    def summary_notification
      RSpec::Core::Notifications::SummaryNotification.new(*@reporter_data.values)
    end

    def output_junit(file)
      JunitOutput.new(summary_notification, @start_time).output(file)
    end
  end
end
