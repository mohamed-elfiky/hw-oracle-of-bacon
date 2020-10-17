require 'byebug'                # optional, may be helpful
require 'open-uri'              # allows open('http://...') to return body
require 'cgi'                   # for escaping URIs
require 'nokogiri'              # XML parser
require 'active_model'          # for validations

class OracleOfBacon

  class InvalidError < RuntimeError ; end
  class NetworkError < RuntimeError ; end
  class InvalidKeyError < RuntimeError ; end

  attr_accessor :from, :to
  attr_reader :api_key, :response, :uri
  
  include ActiveModel::Validations
  validates_presence_of :from
  validates_presence_of :to
  validates_presence_of :api_key
  validate :from_does_not_equal_to

  def from_does_not_equal_to
    # YOUR CODE HERE
    if (from == to) 
      errors.add(:from , "From cannot be the same as To")
      errors.add(:to , "From cannot be the same as To")
    end
  end

  def initialize(api_key='')
    # your code here
    @api_key = api_key
    @from = "Kevin Bacon"
    @to   = "Kevin Bacon"
  end

  def find_connections
    make_uri_from_arguments
    begin
      xml = URI.parse(uri).read
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
      Net::ProtocolError => e
      # convert all of these into a generic OracleOfBacon::NetworkError,
      #  but keep the original error message
      # your code here
    end
    # your code here: create the OracleOfBacon::Response object
  end

  def make_uri_from_arguments
    # your code here: set the @uri attribute to properly-escaped URI
    #   constructed from the @from, @to, @api_key arguments
  end
      
  class Response
    attr_reader :type, :data
    # create a Response object from a string of XML markup.
    def initialize(xml)
      @doc = Nokogiri::XML(xml)
      parse_response
    end

    private

    def parse_response
      if ! @doc.xpath('/error').empty?
        parse_error_response         
      elsif  ! @doc.xpath('/spellcheck').empty?
        parse_spellcheck_response
      elsif  ! @doc.xpath('/link').empty?
        parse_graph_response
      else
        parse_other_response
      end
    end
    def parse_other_response
      @type = :unknown
      @data = "unknown response type"
    end
    def parse_graph_response
      @type = :graph
      actors_array = @doc.xpath('//actor').map{|item| item.text}
      movies_array = @doc.xpath('//movie').map{|item| item.text}
      movies_actors_array = actors_array.zip(movies_array)
      @data = movies_actors_array.flatten.compact
    end
    def parse_spellcheck_response
      @type = :spellcheck
      @data = @doc.xpath('//match').map{|item| item.text}
    end
    def parse_error_response
      @type = :error
      @data = 'Unauthorized access'
    end
  end
end

