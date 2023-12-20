module GridlockCi
  class Client
    attr_reader :run_id, :run_attempt

    def initialize(run_id, run_attempt)
      @run_id = run_id
      @run_attempt = run_attempt.to_i
    end

    def previous_run_completed?
      return true if run_attempt == 1

      previous_run_key = "#{run_id}_#{run_attempt - 1}"
      results = conn.get("/spec_list/#{previous_run_key}").body['specs']

      true if results.empty?
    end

    def next_spec
      conn.get("/spec_list/#{run_key}/next").body['spec']
    end

    def send_specs(spec_list)
      spec_list_json = { spec_list: spec_list }.to_json
      result = conn.post("/spec_list/#{run_key}", spec_list_json).body

      raise result['status'] if result['status'] != 'success'
    end

    def upload_results(file_path)
      file = Faraday::Multipart::FilePart.new(file_path, 'text/xml')
      payload = { file: file }

      multipart_conn.post("/spec_results/#{run_key}", payload)
    end

    private

    def run_key
      "#{run_id}_#{run_attempt}"
    end

    def conn
      retry_options = { # Retry 4 times for: 1, 5, 25, 125 seconds
        exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed, Faraday::ServerError],
        max: 4,
        interval: 1,
        backoff_factor: 5
      }

      Faraday.new(url: gridlock_ci_endpoint) do |f|
        f.request :retry, retry_options
        f.request :json
        f.response :json
        f.response :raise_error
      end
    end

    def multipart_conn
      Faraday.new(url: gridlock_ci_endpoint, request: { timeout: 15 }) do |f|
        f.request :multipart
        f.response :json
        f.response :raise_error
      end
    end

    def gridlock_ci_endpoint
      ENV.fetch('GRIDLOCK_CI_SERVER_ENDPOINT', 'http://localhost:4568')
    end
  end
end
