module GridlockCi
  class ReproduceClient
    attr_reader :specs, :seed

    def initialize(specs, seed)
      @specs = specs.dup
      @seed = seed
    end

    def previous_run_completed?
      true
    end

    def next_spec
      @specs.shift
    end
  end
end
