require "selenium-webdriver"

module Scrapers
  class BaseScraper
    def initialize
      @driver = Selenium::WebDriver.for(:chrome, options: chrome_options)
    end

    def quit_driver
      @driver.quit
    end

    private

    def chrome_options
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
      options.add_argument("--headless")
      options.add_argument("--disable-gpu")
      options.add_argument("--window-size=1920,1080")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
      options
    end
  end
end