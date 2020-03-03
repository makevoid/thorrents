require 'net/http'
require 'cgi'
require 'nokogiri'

class Thorz
  # HOST = "thepiratebay.se"
  # HOST = "piratebay.org"
  # HOST = "pirateproxy.in"
  HOST = "thepiratebay.se.net" # use any host here, this is just for sample
  URL = "https://#{HOST}/search/%s/0/7/0"

  TIMEOUT = 5

  attr_reader :results

  def initialize(query)
    @query = CGI.escape query
    @results = []
  end

  def proxied_search(host)
    return false if @query.blank?
    url = URI.parse "https://#{host}/search/#{@query}.json"
    res = nil
    timeout(TIMEOUT) do
      res = Net::HTTP.get_response url
    end
    if res
      JSON.parse(res.body)["results"].each do |rs|
        @results << {name: rs["name"], magnet: rs["magnet"], seeds: rs["seeds"]}
      end
    end
  end

  def search
    url = URI.parse URL % @query
    res, reason, errror = nil
    begin
      timeout(TIMEOUT) do
        res = get url
      end
    rescue Timeout::Error => e
      reason = "Timeout", error = e
    end

    if res
      doc = Nokogiri::HTML(res.body)
      # just use "#main-content > table#searchResult tr" if you want
      # to use another HOST
      mod = ""
      mod = "[2]" if HOST == "thepiratebay.se.net" # suppress ads on se.net
      doc.css("#main-content > table#searchResult#{mod} tr").each do |tr|
        name = tr.css(".detName").inner_text
        next if name.nil? || name == ""
        magnet = tr.css("a").map{ |a| a if a["title"] =~ /download this torrent using magnet/i }.compact
        magnet = magnet.first && magnet.first["href"] unless magnet.nil?
        seeds = tr.css("td")[2]
        seeds = seeds.inner_text unless seeds.nil?

        @results << {name: name, magnet: magnet, seeds: seeds}
      end
    else
      @results << { name: "an error occcurred, maybe TPB server is down", magnet: "#", seeds: 0 }
    end

    true
  end

  private

  def get(uri)
     resp = Net::HTTP.get_response uri
     resp = Net::HTTP.get_response URI.parse(resp.header['location']) if resp.code == "301"
     resp
  end
end

# q = "Dragon age 2"
# thor = Thorz.new(q)
# thor.search
# p thor.results
