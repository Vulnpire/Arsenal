#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'optparse'

def main()
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'GitLab User Enumeration in Ruby'

    opts.on('--url URL', 'The URL of the GitLab instance') do |url|
      options[:url] = url
    end

    opts.on('--wordlist WORDLIST', 'Path to the username wordlist') do |wordlist|
      options[:wordlist] = wordlist
    end
  end.parse!

  puts "GitLab User Enumeration in Ruby\n"

  begin
    File.open(options[:wordlist], 'r').each_line do |line|
      username = line.strip
      uri = URI.parse("#{options[:url]}/#{username}")
      response = Net::HTTP.get_response(uri)
      http_code = response.code.to_i
      if http_code == 200
        puts "[+] The username #{username} exists!"
      elsif http_code == 0
        puts '[!] The target is unreachable.'
        break
      end
    end
  rescue Errno::ENOENT
    puts '[!] Wordlist file not found.'
    exit(1)
  rescue Interrupt
    puts "\n[!] Enumeration interrupted."
    exit(1)
  end
end

if __FILE__ == $0
  main()
end