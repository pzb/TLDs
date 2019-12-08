#!/usr/bin/env ruby
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
require 'dnsruby'
$stderr.sync = true

# This take a n3map output file and a known names file
# and does the hashing to get the unhashed names

n3map_file = ARGV[0]
name_file = ARGV[1]

# First load and validate the file
hashes = {}
domain = nil
IO.foreach(ARGV[0]) do |l|
  l.strip!

  # Skip comment and empty lines
  next if l =~ /^\s*(;|$)/

  # Format: RRNAME, TTL, CLASS, RRTYPE+DATA, RRTYPES covered
  p = l.split(/\t/)

  # HC needs hash separate from domains
  labels = p[0].split(".", 2)
  hash = labels.shift
  if domain.nil?
    domain = labels.first
  elsif labels != [domain]
    raise "Multiple domains in file"
  end
  if p[2] != "IN"
    raise "Not INternet class"
  end

  # Format: RRTYLE, HASH, FLAGS (0 == no skips), Iterations, Salt, next hash
  rrd = p[3].split(/\s+/)
  if rrd[0] != "NSEC3"
    raise "Not NSEC3"
  end
  if rrd[1] != '1' # SHA-1
    raise "Unknown NSEC3 algorithm!"
  end
  if rrd[2] != '0'
    raise 'Opt-out flag set; incomplete zone'
  end
  iter = rrd[3]
  salt = rrd[4] 
  if salt == "-"
    salt = ""
  end
  nexthash = rrd[5]

  if p[4].nil?
    rrtypes = []
  else
    rrtypes = p[4].split(/\s+/)
  end

  if hashes.key?(hash)
    raise "Duplicate hash #{hash}"
  end

  hashes[hash] = {
    salt: salt,
    iter: iter.to_i,
    next: nexthash,
    rrtypes: rrtypes
  }
end

soa = hashes.select{|k,v|v[:rrtypes].include?('SOA')}
if soa.length > 1
  raise "Multiple SOA"
end
curr = soa = soa.keys.first
loop do
  if !hashes.key?(curr)
    raise "Broken loop at #{curr}"
  end
  curr = hashes[curr][:next]
  # Finished if we are back at SOA
  if curr == soa
    break
  end
end
$stderr.puts "Data is complete"

# Now try to compute names that match the hashes
names = []
IO.foreach(name_file) do |l|
  names << l.strip
end

ALG = 1 #SHA 1
# Check each combination and see if we get something
params = hashes.map{|k,v|[v[:iter], v[:salt]]}.uniq

if params.count > 1
  raise "Multiple NSEC3 parameters"
end
  
iter = params.first[0]
salt = params.first[1]

if salt != ""
  salt = Dnsruby::RR::NSEC3.decode_salt(salt)
end

hash = Dnsruby::RR::NSEC3.calculate_hash(domain, iter, salt, ALG) 
if !hashes.key?(hash)
  raise "De-hash error"
end
hashes[hash][:name] = domain 

names.each do |n|
  name = n + "." + domain
  hash = Dnsruby::RR::NSEC3.calculate_hash(name, iter, salt, ALG) 
  if hashes.key?(hash)
    hashes[hash][:name] = name
  end
end

hashes.each do |k, v|
  if !v.key?(:name)
    v[:name] = "<#{k}>"
  end
  puts ([v[:name]] + v[:rrtypes]).join(' ')
end
