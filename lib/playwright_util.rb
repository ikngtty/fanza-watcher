require 'playwright'

class PlaywrightUtil
  def self.use_browser(&)
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      playwright.chromium.launch(headless: true, &)
    end
  end
end
