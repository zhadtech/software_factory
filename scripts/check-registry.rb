#!/usr/bin/env ruby
# Checks registry/rules.yaml and registry/pool.md against each other.
#   ruby scripts/check-registry.rb [rule-file ...]
# Every **Rn.** rule in the given rule files (default: the agi-standards seed) must
# have a registry entry with legacy_id Rn. Prints one line on success; exits 1 on
# any problem and lists them all.
require "yaml"
require "date"
Encoding.default_external = "UTF-8"

ROOT = File.expand_path("..", __dir__)
STATUSES = %w[pool proposed trial active deprecated retired].freeze
ENFORCEMENTS = %w[prose rule-file hook lint ci script].freeze
REQUIRED = %w[id title text scope enforcement where sources status owner review_by].freeze
# A pool tip counts as promoted only while a rule citing it is in force.
IN_FORCE = %w[trial active deprecated].freeze

problems = []
rules = YAML.safe_load_file(File.join(ROOT, "registry/rules.yaml"), permitted_classes: [Date])
abort "registry/rules.yaml: expected a list of rules" unless rules.is_a?(Array)

pool_lines = File.readlines(File.join(ROOT, "registry/pool.md"), chomp: true)
tips = pool_lines.filter_map { |l| l[/\A(\d+)\. /, 1]&.to_i }
problems << "pool.md: no numbered tips found" if tips.empty?
problems << "pool.md: tips must be numbered 1 to #{tips.size} with no gaps" unless tips == (1..tips.size).to_a

ids = rules.map { |r| r["id"] }
ids.tally.each { |id, n| problems << "#{id}: id used #{n} times" if n > 1 }
legacy = rules.filter_map { |r| r["legacy_id"] }
legacy.tally.each { |id, n| problems << "legacy_id #{id} used #{n} times" if n > 1 }

cited = Hash.new { |h, k| h[k] = [] }
rules.each do |r|
  id = r["id"] || "(no id)"
  REQUIRED.each do |f|
    v = r[f]
    problems << "#{id}: #{f} is missing" if v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
  problems << "#{id}: id must look like R-CTX-012" unless id.match?(/\AR-[A-Z]+-\d{3}\z/)
  problems << "#{id}: status #{r['status'].inspect} is not one of #{STATUSES.join(', ')}" unless STATUSES.include?(r["status"])
  problems << "#{id}: enforcement #{r['enforcement'].inspect} is not one of #{ENFORCEMENTS.join(', ')}" unless ENFORCEMENTS.include?(r["enforcement"])
  problems << "#{id}: review_by must be a date" unless r["review_by"].is_a?(Date)
  Array(r["sources"]).each do |s|
    next unless (n = s.to_s[/\Apool P(\d+)\z/, 1])
    next problems << "#{id}: cites pool P#{n}, which does not exist" unless tips.include?(n.to_i)
    cited[n.to_i] << id if IN_FORCE.include?(r["status"])
  end
  Array(r["supersedes"]).each do |old|
    problems << "#{id}: supersedes #{old}, which is not in the registry" unless ids.include?(old)
  end
end

marked = {}
pool_lines.each do |l|
  next unless (n = l[/\A(\d+)\. /, 1]) && (ids_in = l[/\*Promoted: ([^*]+)\.\*\z/, 1])
  marked[n.to_i] = ids_in.split(", ")
end
(marked.keys | cited.keys).each do |n|
  next if marked.fetch(n, []).sort == cited.fetch(n, []).sort
  problems << "pool P#{n}: marked as promoted to #{marked.fetch(n, []).join(', ').then { _1.empty? ? 'nothing' : _1 }}, " \
              "but cited by #{cited.fetch(n, []).join(', ').then { _1.empty? ? 'no rule' : _1 }}"
end

rule_files = ARGV.empty? ? [File.join(ROOT, "seeds/agi-standards/AGENTS.md")].select { File.exist?(_1) } : ARGV
rule_files.each do |path|
  File.readlines(path, chomp: true).each do |l|
    next unless (n = l[/\A\*\*(R\d+)\.\*\*/, 1])
    problems << "#{path}: #{n} has no registry entry" unless legacy.include?(n)
  end
end

unless problems.empty?
  warn "registry check failed (#{problems.size}):"
  problems.each { |p| warn "  #{p}" }
  exit 1
end

active = rules.count { |r| r["status"] == "active" }
proposed = rules.count { |r| r["status"] == "proposed" }
unchecked = rules.count { |r| r["status"] == "active" && r["checked_on"].nil? }
puts "registry ok: #{rules.size} rules (#{active} active, #{proposed} proposed, #{unchecked} active never checked against a model), " \
     "#{tips.size} pool tips (#{marked.size} promoted), #{rule_files.size} rule file(s) covered"
