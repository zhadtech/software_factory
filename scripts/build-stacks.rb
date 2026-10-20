#!/usr/bin/env ruby
# Writes plugins/sdlc-stacks/rules.json from registry/stacks.yaml and the stack rules in
# registry/rules.yaml (scope stack:<id>). The plugin's hook reads that file.
#   ruby scripts/build-stacks.rb [--check]
# --check: change nothing; exit 1 when the file is out of date.
require "yaml"
require "json"
require "date"
Encoding.default_external = "UTF-8"

ROOT = File.expand_path("..", __dir__)
OUT = File.join(ROOT, "plugins/sdlc-stacks/rules.json")
# The same statuses the template's AGENTS.md carries: proposed rules ship until the director decides.
STATUSES = %w[active trial proposed].freeze

stacks = YAML.safe_load_file(File.join(ROOT, "registry/stacks.yaml"))
rules = YAML.safe_load_file(File.join(ROOT, "registry/rules.yaml"), permitted_classes: [Date])

data = {
  "generated" => "From registry/stacks.yaml and registry/rules.yaml by scripts/build-stacks.rb. Do not edit by hand.",
  "stacks" => stacks.map { |s| { "id" => s["id"], "title" => s["title"], "markers" => Array(s["markers"]) } },
  "rules" => rules.filter_map do |r|
    stack = Array(r["scope"]).grep(/\Astack:/).first or next
    next unless STATUSES.include?(r["status"])
    { "id" => r["id"], "stack" => stack.delete_prefix("stack:"), "status" => r["status"],
      "paths" => r["paths"], "text" => r["text"].strip }
  end.sort_by { |r| r["id"] }
}
json = JSON.pretty_generate(data) + "\n"

if ARGV.include?("--check")
  # Compare parsed content, not text: JSON gem versions differ in whitespace, such as empty arrays.
  current = File.exist?(OUT) ? JSON.parse(File.read(OUT)) : nil
  abort "#{OUT.delete_prefix("#{ROOT}/")} is out of date: run ruby scripts/build-stacks.rb" unless current == JSON.parse(json)
  puts "stack rules up to date: #{data['rules'].size} rule(s) for #{data['stacks'].size} stack(s)"
else
  File.write(OUT, json)
  puts "stack rules written: #{data['rules'].size} rule(s) for #{data['stacks'].size} stack(s)"
end
