ENV['RACK_ENV'] = 'test'

require_relative '../app/app'
require 'capybara'
require 'capybara/rspec'
require 'database_cleaner'
require 'pry'
require 'rspec'
require 'selenium-webdriver'
require 'simplecov'
require 'simplecov-console'


Capybara.app = App

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end


SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::Console, SimpleCov::Formatter::HTMLFormatter]
)

SimpleCov.start


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    rental = Rental.create(price: 10, address: 'London', 
      image: Image.create(file: File.open('app/public/test/test.png'))
    )
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  RSpec::Matchers::define :have_link_or_button do |text|
    match do |page|
      Capybara.string(page.body).has_selector?(:link_or_button, text: text)
    end
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
