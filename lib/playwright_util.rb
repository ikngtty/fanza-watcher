require 'playwright'

class PlaywrightUtil
  def self.use_browser_context
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      playwright.chromium.launch(headless: true) do |browser|
        yield browser.new_context
      end
    end
  end
end
