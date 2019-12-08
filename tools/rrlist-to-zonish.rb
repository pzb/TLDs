#!/usr/bin/env ruby
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
require 'dnsruby'

module Dnsruby
  class Resolver
    def basic_query(name, type=Types.A, klass=Classes.IN)
      msg = Message.new
      msg.do_caching = false
      msg.add_question(name, type, klass)
      optrr = RR::OPT.new(4096)
      optrr.dnssec_ok=true
      msg.add_additional(optrr)
      msg.header.ad = false
      msg.header.rd = false
      msg.header.cd = false
      send_message(msg)
    end
  end
end


resolver = Dnsruby::Resolver.new
resolver.dnssec = false
resolver.recurse = false
resolver.nameserver = '192.33.4.12' # One of the root-servers

rrs = {}
IO.foreach(ARGV[0]) do |l|
  l.strip!
  next if l.empty?
  p = l.split(/\s+/)
  name = p.shift

  if name.start_with?('<')
    # Undecoded NSEC3 name
    next
  end

  if rrs.key?(name)
    raise "Duplicate name: #{name}"
  end

  rrs[name] = p
end

soa = rrs.select{|k,v|v.include?("SOA")}
if soa.length != 1
  raise "No SOA or multiple SOA found"
end

# Find our TLD
TLD = soa.keys.first.freeze
tld = Dnsruby::Name.create(TLD)

ans = resolver.basic_query(tld, Dnsruby::Types.NS)

ns = []
ans.authority.each do |a|
	if a.is_a? Dnsruby::RR::IN::NS
		if a.name == tld
			ns << a.domainname
		end
	end
end

nsip = []
ans.additional.each do |a|
	next unless a.is_a? Dnsruby::RR::IN::A
	next unless ns.include?(a.name)
	nsip << a.address.to_s
end

nsip.uniq!

rrs.each do |name, rrtypes|
  if !name.end_with?('.'+TLD) && name != TLD
    raise "#{name} does not end with #{TLD}"
  end

  # Rotate between name servers for the zone
  # Choose next NS IP (push current one to back of the list)
  nextns = nsip.shift
  nsip.push(nextns)
  resolver.nameserver = nextns

  tries = 0
  begin
    tries += 1
  	ans = resolver.basic_query(name, Dnsruby::Types.ANY)
  rescue Dnsruby::ResolvTimeout => e
    if tries < 4
      nextns = nsip.shift
     nsip.push(nextns)
     resolver.nameserver = nextns
     retry
    end
    raise e
  rescue Dnsruby::NXDomain => e
    # Domain doesn't exist; acceptable for '*'
    if rrtypes == ['*']
      next
    end
    # If not just asking for whatever is available (e.g. *)
    # then this is an error
    raise e
  end
  # Normal case; just use this directly
	if name == TLD || (!ans.answer.any? {|r| r.is_a?(Dnsruby::RR::SOA)})
    ans.answer.each {|r| puts r.to_s}
    ans.authority.select{|r|!r.is_a?(Dnsruby::RR::SOA)}.each {|r| puts r.to_s}
    # OPT records aren't real records and screw up zone parsing
    ans.additional.select{|r|!r.is_a?(Dnsruby::RR::OPT)}.each {|r| puts r}
    next
	end

  # If the rrtypes list is just '*', filter out SOA and include all others
  # and then query for DS records, as they don't normally show up the
  # response to the ANY query when the ANY query hit the subordinate
  # zone
  if rrtypes == ['*']
    ans.answer.select{|r|!r.is_a?(Dnsruby::RR::SOA)}.each {|r| puts r.to_s}
    ans.authority.select{|r|!r.is_a?(Dnsruby::RR::SOA)}.each {|r| puts r.to_s}
    # OPT records aren't real records and screw up zone parsing
    ans.additional.select{|r|!r.is_a?(Dnsruby::RR::OPT)}.each {|r| puts r}
    rrtypes = [ 'DS' ]
  end

  # Got SOA, which means overlapping zones
  # have to query rrtypes one by one
  rrtypes.each do |rrt|
    next if rrt == "RRSIG"
    begin
      tries += 1
      ans = resolver.basic_query(name, rrt)
    rescue Dnsruby::ResolvTimeout => e
      if tries < 4
        nextns = nsip.shift
       nsip.push(nextns)
       resolver.nameserver = nextns
       retry
      end
      raise e
    end

    ans.answer.each {|r| puts r.to_s}
    ans.authority.select{|r|!r.is_a?(Dnsruby::RR::SOA)}.each {|r| puts r.to_s}
    # OPT records aren't real records and screw up zone parsing
    ans.additional.select{|r|!r.is_a?(Dnsruby::RR::OPT)}.each {|r| puts r}
  end
end
