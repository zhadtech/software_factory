#!/usr/bin/env ruby
# The monthly audit's facts (audits/auditor.md says what to do with them).
#   ruby scripts/audit.rb [--links] [--write]
# --links: also fetch every source URL and list the ones that no longer load.
# --write: save the report as audits/<today>.md instead of printing it.
require "yaml"
require "date"
require "net/http"
require "uri"
Encoding.default_external = "UTF-8"

ROOT = File.expand_path("..", __dir__)
Dir.chdir(ROOT)
today = Date.today
rules = YAML.safe_load_file("registry/rules.yaml", permitted_classes: [Date])
added = lambda do |id|
  out = `git log --reverse --format=%as -S "id: #{id}" -- registry/rules.yaml 2>/dev/null`.lines.first
  out ? out.strip : "not committed"
end

lines = ["# Audit #{today}", "",
         "Facts for the monthly audit. `audits/auditor.md` says what to propose from them; " \
         "rule statuses change only with the director's approval.", ""]
section = lambda do |title, rows, empty|
  lines << "## #{title}" << ""
  rows.empty? ? lines << empty : lines.concat(rows)
  lines << ""
end

past = rules.select { |r| %w[active trial].include?(r["status"]) && r["review_by"].is_a?(Date) && r["review_by"] <= today }
section.call("Rules past their review date", past.map { |r| "- #{r['id']} (#{r['status']}), due #{r['review_by']}: #{r['title']}" },
             "None.")

unchecked = rules.select { |r| r["status"] == "active" && r["checked_on"].to_s.empty? }
by_area = unchecked.group_by { |r| r["id"][/\AR-([A-Z]+)-/, 1] }
section.call("Active rules never checked against a model (#{unchecked.size})",
             by_area.map { |area, rs| "- #{area}: #{rs.map { |r| r['id'] }.join(', ')}" }, "None.")

trial = rules.select { |r| r["status"] == "trial" }
section.call("Rules on trial", trial.map { |r| "- #{r['id']}, added #{added.call(r['id'])}: #{r['title']}" }, "None.")

proposed = rules.select { |r| r["status"] == "proposed" }.each_with_index.map { |r, i| [added.call(r["id"]), i, r] }.sort_by { |d, i, _| [d, i] }.map { |d, _, r| [d, r] }
section.call("Proposed rules waiting on the director (#{proposed.size}), oldest first",
             proposed.first(15).map { |d, r| "- #{r['id']}, added #{d}: #{r['title']}" } +
               (proposed.size > 15 ? ["- and #{proposed.size - 15} more"] : []), "None.")

last_audit = Dir["audits/*.md"].map { |f| File.basename(f, ".md") }.grep(/\A\d{4}-\d{2}-\d{2}\z/).select { |d| d < today.to_s }.max
triggers = Dir["intel/inbox/*.md"].sort.select { |f| last_audit.nil? || File.basename(f, ".md") > last_audit }.flat_map do |f|
  File.read(f).split(/^## /).drop(1).select { |s| s =~ /^- Action: audit-trigger$/ }.map do |s|
    "- #{s.lines.first.strip} (#{f}). Touches: #{s[/^- Touches: (.+)$/, 1]}"
  end
end
section.call("Audit triggers from the scout#{last_audit ? " since #{last_audit}" : ''}", triggers, "None.")

if ARGV.include?("--links")
  urls = rules.flat_map { |r| Array(r["sources"]).map { |s| [s.to_s, r["id"]] } }.select { |s, _| s.start_with?("http") }
  broken = urls.group_by(&:first).filter_map do |url, uses|
    code = begin
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 15) do |h|
        res = h.request(Net::HTTP::Get.new(uri, "User-Agent" => "Mozilla/5.0"))
        res = h.request(Net::HTTP::Get.new(URI.join(url, res["location"]), "User-Agent" => "Mozilla/5.0")) if res.is_a?(Net::HTTPRedirection) && res["location"]
        res.code
      end
    rescue StandardError => e
      e.class.name
    end
    "- #{url} (#{code}), cited by #{uses.map(&:last).uniq.join(', ')}" unless code.to_s.start_with?("2", "3")
  end
  section.call("Sources that no longer load (#{urls.map(&:first).uniq.size} checked)", broken, "None.")
end

report = lines.join("\n")
if ARGV.include?("--write")
  Dir.mkdir("audits") unless Dir.exist?("audits")
  File.write("audits/#{today}.md", report)
  puts "audit written: audits/#{today}.md"
else
  puts report
end
