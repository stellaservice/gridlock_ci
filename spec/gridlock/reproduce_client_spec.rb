RSpec.describe(GridlockCi::ReproduceClient) do
  let(:specs) { ['spec/foo_spec.rb', 'spec/bar_spec.rb'] }
  let(:seed) { '12345' }

  subject { described_class.new(specs, seed) }

  describe '#previous_run_completed?' do
    it 'always returns true' do
      expect(subject.previous_run_completed?).to be(true)
    end
  end

  describe '#next_spec' do
    it 'returns specs in order' do
      expect(subject.next_spec).to eq('spec/foo_spec.rb')
      expect(subject.next_spec).to eq('spec/bar_spec.rb')
    end

    it 'returns nil when all specs are exhausted' do
      specs.length.times { subject.next_spec }
      expect(subject.next_spec).to be_nil
    end
  end

  describe '#seed' do
    it 'stores the seed' do
      expect(subject.seed).to eq('12345')
    end
  end
end
