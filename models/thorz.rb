require 'net/http'
require 'cgi'
require 'nokogiri'

class Thorz
  URL = "http://thepiratebay.se/search/%s/0/7/0"

  attr_reader :results

  def initialize(query)
    @query = CGI.escape query
    @results = []
  end

  def proxied_search(host)
    return false if @query.blank?
    url = URI.parse "http://#{host}/search/#{@query}.json"
    res = nil
    timeout(5) do
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
      timeout(5) do
        res = Net::HTTP.get_response url
      end
    rescue Timeout::Error => e
      reason = "Timeout", error = e
    end
    #puts res.body

    if res
      doc = Nokogiri::HTML(res.body)
      doc.css("#searchResult tr").each do |tr|
        name = tr.css(".detName").inner_text
        next if name.nil? || name == ""
        magnet = tr.css("a").map{ |a| a if a["title"] =~ /magnet/i }.compact
        magnet = magnet.first["href"] unless magnet.nil?
        seeds = tr.css("td")[2]
        seeds = seeds.inner_text unless seeds.nil?

        @results << {name: name, magnet: magnet, seeds: seeds}
      end
    end
    #puts @results
    true
  end
end

# q = "Dragon age 2"
# thor = Thorz.new(q)
# thor.search
# p thor.results