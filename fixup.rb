require "json"

def max_jump_in_str(str)
  str.scan(/\$\d+/).map { |e| e[/\d+/].to_i }.max
end

def max_jump_in_array(array)
  max_jump_in_str(array.join)
end

path = ARGV[0]
parsed = JSON.parse(File.read(path))

parsed.each do |key, value|
  body = parsed[key]["body"]

  if body.is_a?(Array)
    next if body.any? { |b| b =~ /\$0/ }

    # delete any trailing jump point
    body[-1].gsub!(/\$\d+$/, "")

    # change the max jump to a zero
    max = max_jump_in_array(body)
    body.each { |b| b.gsub!(/\$#{max}/, "$0") }
  else
    # delete any trailing jump point
    body.gsub!(/\$\d+$/, "")

    # change the max jump to a zero
    max = max_jump_in_str(body)
    body.gsub!(/\$#{max}/, "$0")
  end

  parsed[key]["body"] = body
end

File.open(path, "w") { |f| f.write(JSON.pretty_generate(parsed)) }

`prettier --write #{path}`
