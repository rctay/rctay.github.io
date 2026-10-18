#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "nokogiri"
require "pathname"
require "set"
require "uri"

class SiteVerifier
  class Failure < StandardError; end

  EXPECTED_HOME_GROUPS = [
    ["2025", [["Flashing Dactyl firmware on Mac", "/flashing-Dactyl-keyboard-firmware-on-Mac"]]],
    ["2021", [
      ["Blazor: a first look", "/blazor-first-look"],
      ["TypeScript problem with requiring constructors and defaults", "/typescript-problem-requiring-constructors-and-defaults"],
      ["Why is the Apache process named httpd?", "/why-is-the-apache-process-named-httpd"]
    ]],
    ["2020", [
      ["Observability and the frontend: initial steps (talk)", "/observability-and-the-frontend-initial-steps"],
      ["Ctrl/Alt/Opt shortcuts in IntelliJ Terminal", "/ctrl-alt-opt-shortcuts-in-intellij-terminal"]
    ]],
    ["2019", [
      ["Shrinking a Google Compute disk", "/shrinking-a-google-compute-disk"],
      ["Multi-language is easy!", "/multi-language-is-easy"],
      ["smartcards", "/smartcards"],
      ["Git setup", "/git-setup"],
      ["REST updating a resource", "/rest-updating-a-resource"],
      ["REST API conventions", "/rest-api-conventions"],
      ["Entropy of passwords", "/entropy-of-passwords"]
    ]]
  ].freeze

  EXPECTED_DRAFTS = [
    ["Reset terminal window title after", "/drafts/reset-terminal-window"],
    ["The case against regular expressions", "/drafts/2021-04-24-why-not-to-use-regular-expressions"],
    ["Listing Ubuntu/Debian package dependencies", "/drafts/listing-ubuntu-debian-package-dependencies"],
    ["What's better than taking notes? Making them open", "/drafts/the-case-for-open-notes"]
  ].freeze

  EXPECTED_FEED_ENTRIES = [
    ["Blazor: a first look", "/blazor-first-look"],
    ["Ctrl/Alt/Opt shortcuts in IntelliJ Terminal", "/ctrl-alt-opt-shortcuts-in-intellij-terminal"],
    ["Flashing Dactyl firmware on Mac", "/flashing-Dactyl-keyboard-firmware-on-Mac"],
    ["Git setup", "/git-setup"],
    ["Multi-language is easy!", "/multi-language-is-easy"],
    ["Observability and the frontend: initial steps (talk)", "/observability-and-the-frontend-initial-steps"],
    ["Shrinking a Google Compute disk", "/shrinking-a-google-compute-disk"],
    ["TypeScript problem with requiring constructors and defaults", "/typescript-problem-requiring-constructors-and-defaults"],
    ["Why is the Apache process named httpd?", "/why-is-the-apache-process-named-httpd"],
    ["smartcards", "/smartcards"]
  ].freeze

  EXPECTED_TAG_LINKS = [
    ["talks", ["/observability-and-the-frontend-initial-steps", "/multi-language-is-easy"]],
    ["security", ["/smartcards", "/entropy-of-passwords"]],
    ["architecture", ["/rest-updating-a-resource", "/rest-api-conventions"]],
    ["unix", ["/shrinking-a-google-compute-disk"]],
    ["typescript", ["/typescript-problem-requiring-constructors-and-defaults"]],
    ["too-long-didn-t-watch-notes", ["/blazor-first-look"]],
    ["observability", ["/observability-and-the-frontend-initial-steps"]],
    ["localisation", ["/multi-language-is-easy"]],
    ["keyboards", ["/flashing-Dactyl-keyboard-firmware-on-Mac"]],
    ["internationalisation", ["/multi-language-is-easy"]],
    ["interestings", ["/why-is-the-apache-process-named-httpd"]],
    ["intellij", ["/ctrl-alt-opt-shortcuts-in-intellij-terminal"]],
    ["history", ["/why-is-the-apache-process-named-httpd"]],
    ["google-compute", ["/shrinking-a-google-compute-disk"]],
    ["git", ["/git-setup"]],
    ["os", ["/shrinking-a-google-compute-disk"]],
    ["net-core", ["/blazor-first-look"]]
  ].freeze

  SLIDES = {
    "Multi-language is easy!" => "/multi-language-is-easy",
    "Observability and the frontend: initial steps (talk)" => "/observability-and-the-frontend-initial-steps"
  }.freeze

  SLIDE_ASSETS = [
    "/public/revealjs/css/reveal.css",
    "/public/revealjs/css/theme/white.css",
    "/public/revealjs/plugin/highlight/github.css",
    "/public/revealjs/js/reveal.js",
    "/public/revealjs/plugin/markdown/marked.js",
    "/public/revealjs/plugin/markdown/markdown.js",
    "/public/revealjs/plugin/notes/notes.js",
    "/public/revealjs/lib/js/head.min.js",
    "/public/revealjs/plugin/highlight/highlight.js"
  ].freeze

  APACHE_IMAGES = [
    "/public/img/2021-04-01-why-is-the-apache-process-named-httpd/shared-hosting-plans.jpg",
    "/public/img/2021-04-01-why-is-the-apache-process-named-httpd/vps-hosting-plans.jpg"
  ].freeze

  def initialize(output_dir, baseline_dir = nil)
    @output = Pathname(output_dir).expand_path
    @baseline = baseline_dir && Pathname(baseline_dir).expand_path
    @checks = 0
    raise Failure, "output directory does not exist: #{@output}" unless @output.directory?
    raise Failure, "baseline directory does not exist: #{@baseline}" if @baseline && !@baseline.directory?
  end

  def run
    @index_doc = html_file(@output.join("index.html"))
    @home_groups = extract_home_groups(@index_doc)
    @home_links = @home_groups.flat_map { |group| group[:links] }

    verify_route_inventory
    verify_home_excerpts
    verify_drafts
    verify_feed
    verify_tags
    verify_regular_posts
    verify_selected_post_content
    verify_drafts_noindex
    verify_not_found_page
    verify_legacy_archive_routes
    verify_slides
    verify_local_assets
    verify_baseline if @baseline

    puts "Verified #{@checks} assertions across #{@home_links.length} published posts, #{EXPECTED_DRAFTS.length} drafts, and #{html_paths(@output).length} HTML outputs."
  rescue Failure => e
    abort "FAILED: #{e.message}"
  end

  private

  def assert(name, condition, detail = nil)
    raise Failure, "#{name}#{detail ? ": #{detail}" : ""}" unless condition

    @checks += 1
  end

  def equal(name, actual, expected)
    return @checks += 1 if actual == expected

    raise Failure, "#{name}: expected #{expected.inspect}, got #{actual.inspect}"
  end

  def html_file(path)
    raise Failure, "missing HTML file #{path}" unless path.file?

    Nokogiri::HTML(path.read)
  end

  def html_paths(root)
    Dir.glob(root.join("**/*.html")).map { |path| Pathname(path).relative_path_from(root).to_s }.sort
  end

  def clean_text(node)
    node.text.gsub(/\s+/, " ").strip
  end

  def url_path(value)
    URI.parse(value.to_s).path.to_s
  rescue URI::InvalidURIError
    value.to_s
  end

  def output_file_for_url(url, root = @output)
    uri = URI.parse(url.to_s)
    relative = URI::DEFAULT_PARSER.unescape(uri.path.to_s).sub(%r{\A/}, "")
    relative = "index.html" if relative.empty?
    candidates = [
      root.join(relative),
      root.join("#{relative}.html"),
      root.join(relative, "index.html")
    ]
    candidates.find(&:file?)
  rescue URI::InvalidURIError
    nil
  end

  def doc_for_url(url, root = @output)
    path = output_file_for_url(url, root)
    raise Failure, "no generated output for URL #{url}" unless path

    html_file(path)
  end

  def extract_home_groups(doc)
    doc.css(".posts h2").map do |heading|
      list = heading.xpath("following-sibling::ul[1]")
      {
        year: clean_text(heading),
        links: list.css("li a").map { |a| { title: clean_text(a), url: a["href"] } }
      }
    end
  end

  def compact_groups(groups)
    groups.map do |group|
      [group[:year], group[:links].map { |link| [link[:title], url_path(link[:url])] }]
    end
  end

  def verify_route_inventory
    expected = EXPECTED_HOME_GROUPS
    if @baseline
      baseline_groups = extract_home_groups(html_file(@baseline.join("index.html")))
      expected = compact_groups(baseline_groups)
    end
    equal("home post count", @home_links.length, 13)
    equal("home post year groups and routes", compact_groups(@home_groups), expected)
    older_blog = @index_doc.css("a[href='https://old.raythelean.dev']")
    assert("older-blog link is retained", older_blog.length == 1)
  end

  def verify_home_excerpts
    entries = @index_doc.css(".posts ul.post > li")
    equal("each published post has a preview", entries.length, 13)
    entries.each do |entry|
      heading = entry.at_css("h3 a")
      assert("preview has a linked heading", heading && !clean_text(heading).empty?)
      excerpt = entry.at_css(".post-excerpt")
      assert("preview has a nonempty snippet", excerpt && !clean_text(excerpt).empty?)
      assert("snippet is bounded", clean_text(excerpt).length <= 200)
      assert("snippet contains plain text only", excerpt.element_children.empty?)
    end
    tags = html_file(@output.join("tags.html"))
    assert("tag archive stays headings only", tags.css(".post-excerpt").empty?)
  end

  def extract_draft_links(doc)
    doc.css(".posts li a").map { |a| [clean_text(a), url_path(a["href"])] }
  end

  def drafts_doc
    @drafts_doc ||= doc_for_url("/drafts/")
  end

  def verify_drafts
    expected = EXPECTED_DRAFTS
    if @baseline
      expected = extract_draft_links(doc_for_url("/drafts/", @baseline))
    end
    actual = extract_draft_links(drafts_doc)
    equal("draft listing routes and order", actual, expected)
    assert("draft listing has noindex", drafts_doc.at_css('meta[name="robots"]')&.[]("content") == "noindex")
    assert("draft routes do not appear on home", @home_links.none? { |link| url_path(link[:url]).start_with?("/drafts/") })
    draft_titles = EXPECTED_DRAFTS.map(&:first)
    assert("draft-only titles do not appear in home links", @home_links.none? { |link| draft_titles.include?(link[:title]) })
  end

  def feed_entries(root = @output)
    path = root.join("feed.xml")
    raise Failure, "missing feed.xml" unless path.file?

    xml = Nokogiri::XML(path.read)
    xml.xpath("//*[local-name()='entry' or local-name()='item']").map do |entry|
      title = clean_text(entry.at_xpath("./*[local-name()='title']"))
      link_node = entry.at_xpath("./*[local-name()='link']")
      link = link_node && (link_node["href"] || link_node.text)
      [title, url_path(link)]
    end.sort
  end

  def verify_feed
    expected = EXPECTED_FEED_ENTRIES
    expected = feed_entries(@baseline) if @baseline
    equal("normalized feed title and link-path set", feed_entries, expected.sort)
    assert("draft routes are excluded from feed", feed_entries.none? { |_title, path| path.start_with?("/drafts/") })
    draft_titles = EXPECTED_DRAFTS.map(&:first)
    assert("draft-only titles are excluded from feed", feed_entries.none? { |title, _path| draft_titles.include?(title) })
  end

  def tag_links(doc)
    doc.css("h2[id]").map do |heading|
      [heading["id"], heading.xpath("following-sibling::ul[1]").css("a").map { |a| url_path(a["href"]) }]
    end
  end

  def verify_tags
    tags_doc = html_file(@output.join("tags.html"))
    expected = EXPECTED_TAG_LINKS
    if @baseline
      expected = tag_links(html_file(@baseline.join("tags.html")))
    end
    equal("tag heading IDs and linked post routes", tag_links(tags_doc), expected)
    tag_ids = tags_doc.css("h2[id]").map { |heading| heading["id"] }
    assert("punctuation and space tag IDs are preserved", tag_ids.include?("net-core") && tag_ids.include?("too-long-didn-t-watch-notes"))

    @home_links.each do |link|
      next if SLIDES.key?(link[:title])

      doc = doc_for_url(link[:url])
      doc.css(".page__taxonomy-item").each do |tag|
        uri = URI.parse(tag["href"])
        assert("post tag link targets tags.html", uri.path == "/tags.html", "#{link[:title]} -> #{tag['href']}")
        assert("post tag anchor exists", tag_ids.include?(uri.fragment), "#{link[:title]} -> #{tag['href']}")
      end
    end
  end

  def post_link(title)
    @home_links.find { |link| link[:title] == title } || raise(Failure, "post is missing from home: #{title}")
  end

  def post_doc(title)
    doc_for_url(post_link(title)[:url])
  end

  def regular_links
    @home_links.reject { |link| SLIDES.key?(link[:title]) }
  end

  def has_theme_stylesheet?(doc)
    doc.css('link[rel="stylesheet"][href]').any? { |link| url_path(link["href"]).include?("/assets/css/main.css") }
  end

  def verify_regular_posts
    equal("regular post count", regular_links.length, 11)
    regular_links.each do |link|
      doc = doc_for_url(link[:url])
      assert("theme masthead exists", !doc.css(".masthead").empty?, link[:title])
      assert("theme stylesheet is linked", has_theme_stylesheet?(doc), link[:title])
      equal("one theme post title", doc.css("h1.page__title").length, 1)
      assert("published post has no noindex metadata", doc.at_css('meta[name="robots"]').nil?, link[:title])
      verify_theme_assets(doc, link[:title])
    end
  end

  def license_badge?(doc)
    !doc.css(".post-footer > .post-footer__licence a[rel='license'] img[alt]").empty?
  end

  def verify_selected_post_content
    keyboard = post_doc("Flashing Dactyl firmware on Mac")
    assert("keyboard post drafted date is retained", clean_text(keyboard.at_css(".post-date-drafted")).include?("11 Jul 2020"))
    metadata = keyboard.at_css("header p.post-meta")
    assert("keyboard dates and tags share one metadata paragraph", !metadata.nil?)
    metadata_text = clean_text(metadata).tr("\u00a0", " ").gsub(/\s+/, " ")
    equal("keyboard inline metadata text", metadata_text, "12 Jul 2025 (Drafted: 11 Jul 2020) •keyboards")
    published = metadata.at_css('time.post-date[itemprop="datePublished"]')
    drafted = metadata.at_css('time.post-date-drafted[itemprop="dateDrafted"]')
    assert("publication timestamp is machine readable", published && published["datetime"]&.start_with?("2025-07-12T"))
    assert("draft timestamp is machine readable", drafted && drafted["datetime"]&.start_with?("2020-07-11T"))
    equal("inline keyboard tag destination", metadata.at_css("a.post-tag")&.[]("href"), "/tags.html#keyboards")
    assert("separate drafted-date paragraph is removed", keyboard.css("p.post-date-drafted").empty?)
    assert("keyboard post licence HTML is retained", license_badge?(keyboard))

    blazor = post_doc("Blazor: a first look")
    assert("Blazor post has no drafted-date paragraph", blazor.css(".post-date-drafted").empty?)
    assert("Blazor post licence HTML is retained", license_badge?(blazor))

    apache = post_doc("Why is the Apache process named httpd?")
    equal("Apache figure count", apache.css(".figure").length, 2)
    equal("Apache figure captions", apache.css(".figure figcaption").map { |caption| clean_text(caption) }, [
      "shared hosting plans, circa 2009",
      "VPS hosting plans, circa 2009"
    ])
    equal("Apache figure media URLs", apache.css(".figure img[src], .figure video source[src]").map { |node| url_path(node["src"]) }, APACHE_IMAGES)

    smartcards = post_doc("smartcards")
    assert("smartcards highlight callout is retained", !smartcards.css("blockquote.highlight").empty?)

    stylesheet = keyboard.css('link[rel="stylesheet"][href]').find { |link| url_path(link["href"]).include?("/assets/css/main.css") }
    assert("generated theme stylesheet resolves", stylesheet && output_file_for_url(stylesheet["href"]))
    css = File.read(output_file_for_url(stylesheet["href"]))
    normalized_css = css.gsub(/\s+/, " ")
    assert("generated CSS retains highlight styling", normalized_css.include?("blockquote.highlight"))
    assert("generated CSS contains GitHub Dark background and keyword colours", normalized_css.include?("#0d1117") && normalized_css.include?("#ff7b72"))
    assert("tagline script is loaded alongside theme scripts", keyboard.css("script[src]").any? { |node| url_path(node["src"]) == "/assets/js/tagline.js" })
    assert("generated CSS retains figure styling", normalized_css.include?(".figure__inner") && normalized_css.include?(".figure__caption"))
    assert("generated CSS retains licence badge styling", normalized_css.include?(".post-footer__licence") && normalized_css.match?(/\.post-footer__licence\s+img/))
  end

  def verify_drafts_noindex
    EXPECTED_DRAFTS.each do |title, url|
      doc = doc_for_url(url)
      assert("collection draft is noindex", doc.at_css('meta[name="robots"]')&.[]("content") == "noindex", title)
    end
  end

  def verify_not_found_page
    doc = html_file(@output.join("404.html"))
    equal("404 has one visible title", doc.css("h1").length, 1)
    home_link = doc.css("a").find { |link| url_path(link["href"]) == "/" }
    assert("404 links home", !home_link.nil?)
  end

  def verify_legacy_archive_routes
    %w[page2/index.html page3/index.html].each do |relative|
      doc = html_file(@output.join(relative))
      refresh = doc.at_css('meta[http-equiv="refresh"]')&.[]("content")
      assert("#{relative} redirects to the unpaginated home archive", refresh == "0; url=/")
      assert("#{relative} is excluded from indexing", doc.at_css('meta[name="robots"]')&.[]("content") == "noindex,follow")
      assert("#{relative} provides a home archive link", doc.at_css('a[href="/"]')&.text&.include?("home archive"))
    end
  end

  def verify_slides
    SLIDES.each do |title, _url|
      doc = post_doc(title)
      assert("Reveal.js slide shell exists", !doc.css(".reveal .slides").empty?, title)
      script_text = doc.css("script").map(&:text).join("\n")
      assert("Reveal.initialize is present", script_text.include?("Reveal.initialize"), title)
      assert("slides do not acquire blog masthead", doc.css(".masthead").empty?, title)
      SLIDE_ASSETS.each do |asset|
        present = doc.to_html.include?(asset)
        assert("original slide asset URL is retained", present, "#{title}: #{asset}")
        assert("slide asset resolves locally", !output_file_for_url(asset).nil?, asset)
      end
    end
  end

  def verify_theme_assets(doc, page_title)
    doc.css('link[rel="stylesheet"][href], script[src]').each do |node|
      value = node["href"] || node["src"]
      uri = URI.parse(value)
      next if uri.host && uri.host != "raythelean.dev"
      next unless uri.path.start_with?("/assets/")

      assert("local theme asset resolves", !output_file_for_url(value).nil?, "#{page_title}: #{value}")
    end
  end

  def verify_local_assets
    apache = post_doc("Why is the Apache process named httpd?")
    APACHE_IMAGES.each do |asset|
      assert("figure image resolves locally", !output_file_for_url(asset).nil?, asset)
    end

    stylesheet = post_doc("Flashing Dactyl firmware on Mac").css('link[rel="stylesheet"][href]').find do |link|
      url_path(link["href"]).include?("/assets/css/main.css")
    end
    assert("theme stylesheet is available for local asset checks", !stylesheet.nil?)
    css_path = output_file_for_url(stylesheet["href"])
    assert("theme stylesheet file resolves", !css_path.nil?)
    css = File.read(css_path)
    local_css_urls = css.scan(/url\(\s*["']?([^"')]+)["']?\s*\)/).flatten.select do |value|
      value.start_with?("/assets/", "/public/")
    end
    local_css_urls.each do |asset|
      assert("local CSS asset resolves", !output_file_for_url(asset).nil?, asset)
    end
    assert("figure loading indicator resolves", !output_file_for_url("/public/img/loading.gif").nil?)
  end

  def content_tree(root, relative)
    base = root.join(relative)
    return {} unless base.directory?

    Dir.glob(base.join("**/*")).select { |path| File.file?(path) }.to_h do |path|
      [Pathname(path).relative_path_from(root).to_s, File.binread(path)]
    end
  end

  def verify_baseline
    baseline_html = html_paths(@baseline)
    output_set = html_paths(@output).to_set
    missing_html = baseline_html - output_set.to_a
    assert("all baseline HTML output paths remain", missing_html.empty?, missing_html.join(", "))
    %w[public/img public/revealjs].each do |relative|
      baseline_tree = content_tree(@baseline, relative)
      output_tree = content_tree(@output, relative)
      equal("#{relative} file paths and bytes are preserved", output_tree, baseline_tree)
    end
    %w[CNAME pkt25dbc50bc8da.html].each do |relative|
      equal("#{relative} bytes are preserved", File.binread(@output.join(relative)), File.binread(@baseline.join(relative)))
    end
    equal("baseline and migrated feed title/link-path sets match", feed_entries, feed_entries(@baseline))
  end
end

if ARGV.empty? || ARGV.length > 2
  abort "Usage: bundle exec ruby script/verify_site.rb OUTPUT_DIR [BASELINE_DIR]"
end

begin
  SiteVerifier.new(ARGV[0], ARGV[1]).run
rescue SiteVerifier::Failure => e
  abort "FAILED: #{e.message}"
end
