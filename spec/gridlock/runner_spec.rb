require 'nokogiri'

RSpec.describe(GridlockCi::Runner) do
  let(:run_id) { '1' }
  let(:run_attempt) { '1' }
  let(:gridlock_client) { double('client') }
  let(:rspec_config) { double('rspec_config') }
  let(:rspec_runner) { double('rspec_runner', run: 0) }
  let(:fake_spec) { 'spec/test_spec.foo' }
  let(:reporter) do
    class FakeReporter
      attr_accessor :examples, :failed_examples

      def initialize
        @duration = 15.35
        @examples = []
        @failed_examples = []
        @pending_examples = []
        @non_example_exception_count = 0
        @load_time = 3.5
      end
    end

    FakeReporter.new
  end

  subject { described_class.new(run_id, run_attempt) }

  describe '#run' do
    before(:each) do
      allow(gridlock_client).to receive(:next_spec).and_return(fake_spec, nil)
      allow(GridlockCi::Client).to receive(:new) { gridlock_client }
      allow(RSpec::Core::Runner).to receive(:new) { rspec_runner }
      allow(RSpec).to receive(:configuration) do
        double(
          :configuration,
          force: nil,
          value_for: nil,
          seed: 2345,
          dry_run?: false,
          color_enabled?: false,
          reporter: reporter
        )
      end
    end

    context 'when no rspec opts given' do
      it 'passes the resulting spec from the server to rspec runner' do
        expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(
          [fake_spec]
        ) { rspec_config }

        expect(RSpec::Core::Runner).to receive(:new).with(
          rspec_config
        ) { rspec_runner }

        subject.run
      end
    end

    context 'when rspec opts are given' do
      let(:rspec_opts) { ['--format', 'progress'] }

      it 'passes the rspec opts to the runner' do
        expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(
          [fake_spec] + rspec_opts
        ) { rspec_config }

        expect(RSpec::Core::Runner).to receive(:new).with(
          rspec_config
        ) { rspec_runner }

        subject.run(rspec_opts: rspec_opts)
      end
    end

    context 'when next spec is nil' do
      before do
        allow(gridlock_client).to receive(:next_spec).and_return(nil)
      end

      it 'returns early' do
        expect(RSpec::Core::Runner).not_to receive(:new)

        subject.run
      end
    end

    context 'when junit option is set' do
      let(:junit_output) { '/tmp/junit-test.xml' }
      let(:duration) { 15.35 }
      after do
        File.delete(junit_output)
      end

      it 'creates junit output of results' do
        subject.run(junit_output: junit_output)
        xml_doc = Nokogiri::XML(File.read(junit_output))

        expect(xml_doc.css('testsuite').first.attribute('time').content.to_f).to eq(duration)
      end
    end

    context 'when spec failed' do
      let(:rspec_runner) { double('rspec_runner', run: 1) }

      it 'readds the failed spec to queue' do
        client = double('client')
        allow(GridlockCi::Client).to receive(:new).with(run_id, run_attempt.to_i + 1) { client }

        expect(client).to receive(:send_specs).with([fake_spec])

        expect do
          expect(subject.run).to eq(1)
        end.to raise_error(SystemExit)
      end
    end
  end
end
