RSpec.describe(GridlockCi::Runner) do
  let(:run_id) { '1' }
  let(:run_attempt) { '1' }
  let(:gridlock_client) { double('client') }
  let(:rspec_config) { double('rspec_config') }
  let(:rspec_runner) { double('rspec_runner', run: 0) }
  let(:fake_spec) { 'spec/test_spec.foo' }

  subject { described_class.new(run_id, run_attempt) }

  describe '#run' do
    before(:each) do
      allow(gridlock_client).to receive(:next_spec).and_return(fake_spec, nil)
      allow(GridlockCi::Client).to receive(:new) { gridlock_client }
      allow(RSpec::Core::Runner).to receive(:new) { rspec_runner }
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

        subject.run(rspec_opts)
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

    context 'when spec failed' do
      let(:rspec_runner) { double('rspec_runner', run: 1) }

      it 'readds the failed spec to queue' do
        client = double('client')
        allow(GridlockCi::Client).to receive(:new).with(run_id, run_attempt.to_i + 1) { client }

        expect(client).to receive(:send_specs).with([fake_spec])

        expect(subject.run).to eq(1)
      end
    end
  end
end
