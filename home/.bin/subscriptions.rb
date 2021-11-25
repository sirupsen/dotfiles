require 'net/https'
require 'uri'
require 'json'
require 'base64'
begin
  require 'capybara/dsl'
  require 'byebug'
  require 'nokogiri'
  require 'google/cloud/storage'
rescue LoadError
  puts "\x1b[31mgem install byebug apparition selenium-webdriver capybara nokogiri\x1b[0m"
  raise
end

raw_priv_key = ENV["GOOGLE_SIRUPSEN_COM_SERVICE_ACCOUNT_PRIV_KEY"].dup.force_encoding(Encoding::US_ASCII)
raise "GOOGLE_SIRUPSEN_COM_SERVICE_ACCOUNT_PRIV_KEY undefined!" unless raw_priv_key

$storage = Google::Cloud::Storage.new(
  project_id: "omphalos-1186",
  credentials: {
    type: 'service_account',
    project_id: 'omphalos-1186',
    private_key_id: "bbe3653a2ff22131d15300728f4f7cf6d8895d66",
    client_email: "sirupsen-com@omphalos-1186.iam.gserviceaccount.com",
    client_id: "111847347645466674362",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/sirupsen-com%40omphalos-1186.iam.gserviceaccount.com",
    private_key: Base64.strict_decode64(raw_priv_key),
  }
)
$bucket = $storage.bucket "sirupsen-com"
exit 0

def verbose? = ARGV.any? { |arg| ["--verbose", "-v"].include?(arg) }
def force? = ARGV.any? { |arg| ["--force", "-f"].include?(arg) }
def dry_run? = byebug? ? true : ARGV.any? { |arg| ["--dry-run", "-d"].include?(arg) }
def byebug? = ARGV.any? { |arg| ["--byebug", "-b"].include?(arg) }

def allow_only_one_instance!
  lock_path = "subscriptions.rb/lock.json"
  lock_file = $bucket.file("subscriptions.rb/loll.txt")

  if lock_file && lock_file.size > 0
    io = lock_file.download
    io.rewind
    json = JSON.parse(io.read)

    puts "Lock already claimed #{lock_file}\n" if verbose?
    puts json if verbose?

    lock_age_seconds = Time.now - Time.parse(json["time"])
    puts "Lock age: #{lock_age_seconds / 60} minutes" if verbose?
    lock_file.delete if lock_age_seconds >= 10 * 60

    ppid = json["ppid"].to_s

    puts "\nParent Process:\n" if verbose?

    smart_grep = "[#{ppid[0]}]#{ppid[1..- 1]}"
    puts `ps aux | grep '#{smart_grep}'` if verbose?
    exit 0
  end

  json = {time: Time.now, pid: Process.pid, ppid: Process.ppid}.to_json
  $bucket.create_file(StringIO.new(json), lock_path)

  at_exit do
    $bucket.file(lock_path)&.delete
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

def notify(text, url)
  # brew install terminal-notifier
  if `which terminal-notifier` && $?.success?
    system("terminal-notifier -ignoreDnD -title 'Subscriptions 🛒' -message '#{text}' -open '#{url}'")
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

def http_get(url, retries = 4, &block)
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
  path = "subscriptions.rb/subscriptions-#{sanitized}.marshal"
  remote_file = $bucket.file(path)

  if remote_file && remote_file.size > 0
    io = remote_file.download
    io.rewind
    old = Marshal.load(io.read)

    # DateTime subscription gives fraction of days!
    seconds_since_created = ((DateTime.now - remote_file.updated_at) * 24 * 3600).to_f
    if old == new
      puts "\t\x1b[32mNothing changed\x1b[0m" if verbose?
    # Re-generate file to stop showing notifications after ~10min Especially
    # useful if I'm away from my computer and Pushover is going crazy.
    elsif seconds_since_created > 60 * 10 && old != new
      remote_file.delete
      puts "\tRegenerating file age=#{seconds_since_created}s" if verbose?
      return changed!(url, new, notification: notification)
    else
      notify(notification || "#{url} changed", url)
    end
  else
    puts "\t\x1b[33mCreating new file (#{path[0..25]}..)\x1b[0m" if verbose?
    io = StringIO.new
    Marshal.dump(new, io)
    file = $bucket.create_file(io, path)
    file.acl.public!
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

# http_body_changed "https://www.racentre.com/adult-clubs-programs/firearms-safety-education/"
# http_body_changed "https://ottawafirearmsafety.ca/course-schedule/#SCHEDULE"
# http_body_changed "https://www.thathuntingstore.com/cm1.cfm?page=upcoming_course_dates.html&ctaID=137"
# http_body_changed "http://www.firearmstraining.ca/when.htm"

# http_css_changed(
#   'https://www.costco.ca/classic-adirondack-collection.product.100036005.html',
#   ".product-info-description"
# )

# http_css_changed(
#   'https://www.costco.ca/classic-adirondack-footstool.product.100036007.html',
#   ".product-info-description"
# )

# http_css_changed(
#   'https://www.costco.ca/classic-adirondack-side-table.product.100115310.html',
#   ".product-info-description"
# )

# http_js_changed(
#   "https://www.roguecanada.ca/deals",
#   ".category"
# )

# http_css_changed(
#   "https://www.bestbuy.ca/en-ca/product/playstation-5-digital-edition-console/14962184",
#   ".productActionWrapperNonMobile_10B89"
# )

# http_js_changed(
#   "https://www.realcanadiansuperstore.ca/mp/playstation-5-console/1167-711719541042",
#   ".product-details-page-details-invalid-price",
#   skip_on_no_css: true
# )

# http_css_changed(
#   "https://www.ebgames.ca/PS5/Games/877523",
#   ".megaButton.buyDisabled"
# )

# http_css_changed(
#   "https://www.costco.ca/playstation-5-console-bundle.product.100696941.html",
#   "#add-to-cart"
# )

# http_body_changed(
#   "https://shop.shoppersdrugmart.ca/Shop/p/BB_711719541042"
# )

# http_css_changed(
#   "https://www.thesource.ca/en-ca/gaming/playstation/ps5-consoles/playstation%c2%ae5-digital-edition-console/p/108090498",
#   ".addToCartButton"
# )

# http_css_changed(
#   "https://www.newegg.ca/p/N82E16868110294",
#   ".product-inventory"
# )

# http_css_changed(
#   "https://www.chillymoose.ca/collections/coolers/products/ice-box-cutting-board-divider?variant=29162332094561",
#   ".variant-wrapper"
# )

# http_css_changed(
#   "https://www.fitnessavenue.ca/2-5lbs-rubber-grip-olympic-plates-2-inch",
#   ".custom_field.contactforshipping"
# )

# http_css_changed(
#   "https://www.fitnessavenue.ca/product/TO/op14/2.5lbs-Virgin-Rubber-Grip-Olympic-Plates-2-Inch",
#   ".custom_field.contactforshipping"
# )

# http_css_changed(
#   "https://www.fitnessavenue.ca/5lbs-rubber-grip-olympic-plates-2-inch",
#   ".custom_field.contactforshipping"
# )

# http_css_changed(
#   "https://viberg.com/collections/ss21-slide/products/slide-light-visone-kudu-roughout?variant=39278414397549",
#   ".add-to-cart"
# )

http_body_changed("https://www.wisemanandcromwell.com/collections/furniture")

# http_body_changed("https://shop.lululemon.com/p/men-shorts/THE-Short-7-Linerless/_/prod8260681?color=0001&sz=M&tasid=2WHrK9VGZh&taterm=the%20short")

# http_body_changed("https://nugrocery.com/products/peanuts-roasted?_pos=5&_sid=af71991fc&_ss=r")

# http_body_changed(
#   "https://www.sportinglife.ca/en-CA/men/accessories/winter-accessories/winter-hats/unisex-baggies%23x2122--brimmer-hat-25352360_012_016.html"
# )

# http_body_changed(
#   "https://www.patagonia.ca/product/baggies-brimmer-hat/33340.html"
# )

# http_css_changed(
#   "https://www.fitnessavenue.ca/product/TO/op15/5lbs-Virgin-Rubber-Grip-Olympic-Plates-2-Inch",
#   ".custom_field.contactforshipping"
# )

# http_js_changed(
#   "https://www.ikea.com/ca/en/p/aepplaroe-bench-with-backrest-outdoor-brown-stained-80208529/",
#   ".range-revamp-stockcheck__item"
# )
#

http_css_changed(
  "https://figure8.ca/shop/index.php?route=product/product&path=159_184&product_id=1614&sort=p.price&order=DESC",
  "#input-option1765"
)

Net::HTTP.get(URI.parse('https://hc-ping.com/2deb7e87-a6fb-4dfb-8ab7-54b21e0e79f1'))
