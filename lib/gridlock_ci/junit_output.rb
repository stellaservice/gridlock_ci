module GridlockCi
  class JunitOutput
    attr_reader :summary_notification, :start_time

    def initialize(summary_notification, start_time)
      @start_time = start_time
      @summary_notification = summary_notification
    end

    def output(file)
      RSpec::Support::DirectoryMaker.mkdir_p(File.dirname(file))

      IO.open(IO.sysopen(file, 'w'), 'w') do |output|
        junit_formatter = RSpecJUnitFormatter.new(output)
        junit_formatter.instance_variable_set('@started', @start_time)
        junit_formatter.instance_variable_set(
          '@examples_notification',
          Struct.new(:notifications).new(example_notifications)
        )

        junit_formatter.dump_summary(summary_notification)
      end
    end

    def example_notifications
      summary_notification.examples.map do |example|
        RSpec::Core::Notifications::ExampleNotification.for(example)
      end
    end
  end
end
