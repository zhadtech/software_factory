#!/usr/bin/env ruby
# Checks the scout's output (intel/scout.md): each inbox file, the digest and the state file.
#   ruby scripts/check-intel.rb
# Prints one line on success; exits 1 and lists every problem otherwise.
require "yaml"
require "json"
require "date"
Encoding.default_external = "UTF-8"

ROOT = File.expand_path("..", __dir__)
FIELDS = ["Source", "Published", "What changed", "Touches", "Action", "Why"].freeze
ACTIONS = %w[none pool-tip propose-rule plugin-change audit-trigger].freeze
MAX_WEEKS = 12

problems = []
rules = YAML.safe_load_file(File.join(ROOT, "registry/rules.yaml"), permitted_classes: [Date])
rule_ids = rules.map { |r| r["id"] }

inbox = Dir[File.join(ROOT, "intel/inbox/*.md")].sort
items = 0
inbox.each do |path|
  name = path.delete_prefix("#{ROOT}/")
  problems << "#{name}: name it after the run date, such as 2026-10-13.md" unless File.basename(path) =~ /\A\d{4}-\d{2}-\d{2}\.md\z/
  sections = File.read(path).split(/^## /).drop(1)
  problems << "#{name}: no items; a run with nothing to report still writes one item with action none" if sections.empty?
  sections.each do |section|
    items += 1
    title = section.lines.first.strip
    fields = section.scan(/^- ([A-Za-z ]+): (.+)$/).to_h
    FIELDS.each { |f| problems << "#{name}: \"#{title}\" has no #{f}" if fields[f].to_s.strip.empty? }
    if (src = fields["Source"]) && src !~ %r{\Ahttps?://\S+\z}
      problems << "#{name}: \"#{title}\" Source is not a URL: #{src}"
    end
    if (act = fields["Action"]) && !ACTIONS.include?(act.strip)
      problems << "#{name}: \"#{title}\" Action #{act} is not one of #{ACTIONS.join(', ')}"
    end
    next unless (touches = fields["Touches"]) && touches.strip != "none"

    touches.split(",").map(&:strip).each do |t|
      next if t =~ /\AR-[A-Z]+-\d{3}\z/ && rule_ids.include?(t)
      next if t.include?("/") && File.exist?(File.join(ROOT, t))
      problems << "#{name}: \"#{title}\" touches #{t}, which is neither a rule ID nor a file in this repo"
    end
  end
end

digest = File.join(ROOT, "intel/digest.md")
if File.exist?(digest)
  weeks = File.read(digest).scan(/^## Week of (\d{4}-\d{2}-\d{2})$/).flatten
  problems << "intel/digest.md: no \"## Week of YYYY-MM-DD\" sections" if weeks.empty? && !inbox.empty?
  problems << "intel/digest.md: weeks must run newest first" unless weeks == weeks.sort.reverse
  problems << "intel/digest.md: #{weeks.size} weeks; keep the #{MAX_WEEKS} newest" if weeks.size > MAX_WEEKS
elsif !inbox.empty?
  problems << "intel/digest.md is missing"
end

state = JSON.parse(File.read(File.join(ROOT, "intel/state.json")))
%w[last_run claude_code_version].each { |k| problems << "intel/state.json: no #{k} key" unless state.key?(k) }
if (last = state["last_run"]) && !inbox.empty? && File.basename(inbox.last, ".md") != last
  problems << "intel/state.json: last_run is #{last}, but the newest inbox is #{File.basename(inbox.last, '.md')}"
end

unless problems.empty?
  warn "intel check failed (#{problems.size}):"
  problems.each { |p| warn "  #{p}" }
  exit 1
end
puts "intel ok: #{inbox.size} inbox file(s), #{items} item(s)"
