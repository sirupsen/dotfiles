require 'net/https'
require 'uri'
require 'json'
begin
  require 'capybara/dsl'
  require 'byebug'
  require 'nokogiri'
rescue LoadError
  puts "\x1b[31mgem install byebug apparition selenium-webdriver capybara nokogiri\x1b[0m"
  raise
end

def verbose?
  ARGV.any? { |arg| ["--verbose", "-v"].include?(arg) }
end

def force?
  ARGV.any? { |arg| ["--force", "-f"].include?(arg) }
end

def allow_only_one_instance!
  lock_file = "/tmp/subscriptions.lock"
  if File.exist?(lock_file)
    puts "Lock already claimed #{lock_file}\n" if verbose?
    json = JSON.parse(File.read(lock_file))
    puts json if verbose?

    ppid = json["ppid"].to_s

    puts "\nParent Process:\n" if verbose?

    smart_grep = "[#{ppid[0]}]#{ppid[1..- 1]}"
    puts `ps aux | grep '#{smart_grep}'` if verbose?
    exit 0
  end

  File.open(lock_file, "w") do |f|
    f.write({time: Time.now, pid: Process.pid, ppid: Process.ppid}.to_json)
  end

  at_exit do
    # I might have manually deleted the lock file to test something.
    File.delete(lock_file) if File.exist?(lock_file)
  end
end

allow_only_one_instance! unless force?

require 'capybara/apparition'
require 'logger'
logger = Logger.new($stdout)
logger.level = Logger::WARN
logger.level = Logger::DEBUG if verbose?

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(
    app,
    logger: logger,
    browser_logger: logger,
  )
end
Capybara.default_driver = :apparition
Capybara.run_server = false
Capybara.default_max_wait_time = 5

def run?(url)
  name = ARGV.find { |arg| !arg.start_with?("-") }
  return true unless name
  url =~ Regexp.new(name)
end

def dry_run?
  return true if byebug?
  ARGV.any? { |arg| ["--dry-run", "-d"].include?(arg) }
end

def byebug?
  # implies -d
  ARGV.any? { |arg| ["--byebug", "-b"].include?(arg) }
end

def notify(text, url)
  # brew install terminal-notifier
  if `which terminal-notifier` && $?.success?
    system("terminal-notifier -title 'Subscriptions 🛒' -message '#{text}' -open '#{url}'")
  else
    system("osascript -e 'display notification \"#{text}\" with title \"Subscriptions\"'")
  end

  http = Net::HTTP.new("api.pushover.net", 443)
  http.use_ssl = true
  request = Net::HTTP::Post.new("/1/messages.json")
  request.set_form_data({
    token: ENV["PUSHOVER_APP_TOKEN"],
    user: ENV["PUSHOVER_USER_TOKEN"],
    title: text,
    message: text
  })
  response = http.request(request)
  raise StandardError.new(response) unless response.is_a?(Net::HTTPSuccess)

  true
end

def http_get(url, retries = 5, &block)
  if retries == 0
    return nil
  end

  puts "\x1b[34m#{url}\x1b[0m" if verbose?

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.read_timeout = 5
  http.open_timeout = 5
  http.write_timeout = 5

  request = Net::HTTP::Get.new(uri.request_uri)
  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
  request["Accept-Language"] = "en-US,en;q=0.9,da;q=0.8,sv;q=0.7"
  request["Cache-Control"] = "max-age=0"
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36"
  request['Cookie'] = ''


  begin
    response = http.request(request)
  rescue => e
    puts "\tRetrying url=#{url} exception=#{e.message.inspect} retries=#{retries}" if verbose?
    sleep((6 - retries) * 5)
    return http_get(url, retries - 1, &block)
  end

  unless response.code == "200"
    puts "\tRetrying url=#{url} status_code=#{response.code} retries=#{retries}" if verbose?
    sleep((6 - retries) * 5)
    return http_get(url, retries - 1, &block)
  end

  response
end

def http_nokogiri(url)
  return unless run?(url)
  return unless response = http_get(url)
  yield(Nokogiri::HTML.parse(response.body), url)
end

def http_regex(url, regex)
  return unless run?(url)
  return unless response = http_get(url)
  yield(response.body.scan(regex))
end

def changed!(url, new, notification: nil)
  sanitized = url.downcase.gsub(/[^a-z0-9\-_]/, '').gsub(/https(www)?/, "")
  path = "/tmp/subscriptions-#{sanitized}.marshal"

  if File.exists?(path) && !File.zero?(path)
    old = Marshal.load(File.read(path))

    # Re-generate file to stop showing notifications after ~10min
    # Especially useful if I'm away from my computer and Pushover is going
    # crazy.
    seconds_since_created = Time.now - File.mtime(path)
    if seconds_since_created > 60 * 10
      File.delete(path)
      puts "\tRegenerating file age=#{seconds_since_created}s" if verbose?
      return changed!(url, new, notification: notification)
    elsif old == new
      puts "\t\x1b[32mNothing changed\x1b[0m" if verbose?
    else
      old_diff = "/tmp/subscriptions-old-#{sanitized}.html"
      File.open(old_diff, "w") { |f| f.write(old) }
      new_diff = "/tmp/subscriptions-new-#{sanitized}.html"
      File.open(new_diff, "w") { |f| f.write(new) }

      if verbose?
        puts "\t\x1b[31mThere were changes"
        puts "\tgit diff --no-index #{old_diff} #{new_diff}\x1b[0m"
      end

      notify(notification || "#{url} changed", url)
    end
  else
    puts "\t\x1b[33mCreating new file\x1b[0m" if verbose?
    File.open(path, "w") { |f| f.write(Marshal.dump(new)) }
  end
end

def http_css_changed(url, css)
  http_nokogiri(url) do |doc, _url|
    if dry_run?
      puts doc.css(css).to_html
      byebug if byebug?
    else
      changed!(url, doc.css(css).to_html)
    end
  end
end

# Many pages have a lot of changes in their body. We explicitly don't include
# the <head> as CDN versions and so on might change rapidly. For many pages,
# that's also the case within the body for images, scripts, etc. So you might
# want to use `http_nokogiri` to extract the element you care about changing.
def http_body_changed(url)
  http_css_changed(url, "body")
end

# We don't want to _always_ use this driver, as it's much slower than raw HTTP.
# That's mostly a developmental concern.
def http_js(url, &block)
  # Anonymous class because Capybara freaks out if you include it in Kernel.
  # Probably rightly so.
  runner = Class.new do
    include Capybara::DSL
    attr_reader :url
    def run(url, func, retries = 2)
      return unless run?(url)
      return if retries == 0

      puts "\x1b[34m#{url}\x1b[0m" if verbose?
      visit(url)
      unless page.status_code == 200
        puts "\t\x1b[31mBad status code #{page.status_code}, retrying\x1b[0m" if verbose?
        sleep(5 * (3 - retries))
        return run(url, func, retries - 1)
      end
      # We need to use the Capybara selectors. It would've been nice to use
      # Nokogiri, but because Capybara might need to wait for elements to
      # appear, we use those.
      func.call(page, url)
    end
  end
  runner.new.run(url, block)
end

def http_js_changed(url, css, skip_on_no_css: false)
  http_js(url) do |doc, url|
    if dry_run?
      p doc.all(css).map { |el| el['innerHTML'] }
      byebug if byebug?
    else
      changed!(url, doc.all(css).map { |el| el['innerHTML'] })
    end
  end
end

http_body_changed "https://www.racentre.com/adult-clubs-programs/firearms-safety-education/"

http_css_changed(
  'https://www.canadianoutdoorequipment.com/gransfors-bruks-outdoor-axe.html',
  '.out-of-stock'
)

http_css_changed(
  'https://www.costco.ca/classic-adirondack-collection.product.100036005.html',
  ".product-info-description"
)

http_js_changed(
  "https://www.roguecanada.ca/deals",
  ".category"
)

http_css_changed(
  "https://www.bestbuy.ca/en-ca/product/playstation-5-digital-edition-console-online-only/14962184",
  ".availabilityMessageProduct_ZCIQp"
)

http_js_changed(
  "https://www.realcanadiansuperstore.ca/mp/playstation-5-console/1167-711719541042",
  ".product-details-page-details-invalid-price",
  skip_on_no_css: true
)

http_css_changed(
  "https://www.ebgames.ca/PS5/Games/877523",
  ".megaButton.buyDisabled"
)

http_css_changed(
  "https://www.costco.ca/playstation-5-console-bundle.product.100696941.html",
  "#add-to-cart"
)

http_body_changed(
  "https://shop.shoppersdrugmart.ca/Shop/p/BB_711719541042"
)

http_css_changed(
  "https://www.thesource.ca/en-ca/gaming/playstation/ps5-consoles/playstation%c2%ae5-digital-edition-console/p/108090498",
  ".addToCartButton"
)

http_css_changed(
  "https://www.newegg.ca/p/N82E16868110294",
  ".product-inventory"
)
