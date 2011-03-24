require 'net/http'
require 'cgi'
require 'nokogiri'

class Thorz
  URL = "http://thepiratebay.org/search/%s/0/7/0"
  
  attr_reader :results
  
  def initialize(query)
    @query = CGI.escape query
    @results = []
  end
  
  def search
    url = URI.parse URL % @query
    #res = Net::HTTP.get_response(url)
    res = Net::HTTP.new(url.host, url.port).start do |http| 
      http.read_timeout = 5 
      http.request(req) 
    end 
    case res 
      when Net::HTTPSuccess 
        # success 
      else 
        # something went wront 
    end 
    
    #puts res.body

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
    #puts @results 
    true
  end
end

# q = "Dragon age 2"
# thor = Thorz.new(q)
# thor.search
# p thor.results