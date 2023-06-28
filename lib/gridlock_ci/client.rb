module GridlockCi
  class Client
    attr_reader :run_id, :run_attempt

    def initialize(run_id, run_attempt)
      @run_id = run_id
      @run_attempt = run_attempt
    end

    def next_spec
      conn.get("/spec_list/#{run_key}/next").body['spec']
    end

    def send_specs(spec_list)
      spec_list_json = { spec_list: spec_list }.to_json
      result = conn.post("/spec_list/#{run_key}", spec_list_json).body

      raise result['status'] if result['status'] != 'success'
    end

    private

    def run_key
      "#{run_id}_#{run_attempt}"
    end

    def conn
      Faraday.new(url: gridlock_ci_endpoint) do |f|
        f.request :json
        f.response :json
      end
    end

    def gridlock_ci_endpoint
      ENV.fetch('GRIDLOCK_CI_SERVER_ENDPOINT', 'http://localhost:4568')
    end
  end
end
