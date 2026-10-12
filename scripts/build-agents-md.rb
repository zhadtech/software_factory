#!/usr/bin/env ruby
# Rewrites the factory rules block of an AGENTS.md from registry/rules.yaml.
#   ruby scripts/build-agents-md.rb [--check] [AGENTS.md ...]   default: templates/project/AGENTS.md
# The block sits between "<!-- factory-rules:start statuses=a,b,c" and "<!-- factory-rules:end -->".
# It holds every all-projects rule whose status is listed there, minus the rules those supersede.
# --check: change nothing; exit 1 when a file is out of date.
require "yaml"
require "date"
Encoding.default_external = "UTF-8"

ROOT = File.expand_path("..", __dir__)
AREAS = {
  "BOOT" => "Boot", "PLAN" => "Plan and steps", "SESS" => "Sessions", "CTX" => "Context economy",
  "CODE" => "Writing code", "VER" => "Verification", "GIT" => "Git and blast radius",
  "TRUST" => "Trust boundary", "META" => "Maintaining the rules", "COMMS" => "Writing for the director"
}.freeze
START = /^<!-- factory-rules:start statuses=([a-z,]+)$/
FINISH = "<!-- factory-rules:end -->"

check = ARGV.delete("--check")
files = ARGV.empty? ? [File.join(ROOT, "templates/project/AGENTS.md")] : ARGV
rules = YAML.safe_load_file(File.join(ROOT, "registry/rules.yaml"), permitted_classes: [Date])

def block(rules, statuses)
  chosen = rules.select { |r| Array(r["scope"]).include?("all-projects") && statuses.include?(r["status"]) }
  replaced = chosen.flat_map { |r| Array(r["supersedes"]) }
  chosen.reject! { |r| replaced.include?(r["id"]) }
  out = ["", "## Rules", "", "Cite rules by ID in review (\"violates R-CTX-002\"). Change them in the factory registry, not here."]
  AREAS.each do |area, title|
    in_area = chosen.select { |r| r["id"].start_with?("R-#{area}-") }.sort_by { |r| r["id"] }
    next if in_area.empty?
    out << "" << "### #{title}" << ""
    in_area.each { |r| out << "**#{r['id']}.** #{r['text'].strip}" }
  end
  unknown = chosen.reject { |r| AREAS.key?(r["id"][/\AR-([A-Z]+)-/, 1]) }
  abort "build-agents-md: no area title for #{unknown.map { |r| r['id'] }.join(', ')}" unless unknown.empty?
  out << ""
end

stale = []
files.each do |path|
  lines = File.readlines(path, chomp: true)
  first = lines.index { |l| l.match?(START) } or abort "#{path}: no factory-rules:start marker"
  head_end = lines.index.with_index { |l, i| i >= first && l.end_with?("-->") }
  last = lines.index(FINISH) or abort "#{path}: no #{FINISH} marker"
  statuses = lines[first][START, 1].split(",")
  updated = lines[0..head_end] + block(rules, statuses) + lines[last..]
  next if updated == lines
  stale << path
  File.write(path, updated.join("\n") + "\n") unless check
end

if check && !stale.empty?
  warn "out of date (run ruby scripts/build-agents-md.rb): #{stale.join(', ')}"
  exit 1
end
puts "rules block #{check ? 'up to date' : 'written'}: #{files.size} file(s)" if stale.empty? || !check
