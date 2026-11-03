ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Os testes criam seus próprios registros. As fixtures antigas não são
    # usadas e tinham valores duplicados (nome/slug/e-mail) que quebravam a
    # suíte ao serem carregadas automaticamente.
    # fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
