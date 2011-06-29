require 'base64'
require 'cgi'
require 'digest/md5'
require 'digest/sha1'
require 'net/https'

class P24
  attr_reader :response
  
  def initialize(*args)
    @url = URI.parse('https://privat24.privatbank.ua/p24/accountorder?oper=prp&PUREXML')
    unless args.empty?
      @merchant_id, @password, @url = args[0], args[1], (URI.parse(args[2]) rescue @url)
    else
    end
  end
  
  def self.define_methods(type,*methods)
    methods.each do |method|
      define_method method do |*args|
        @params = method == :bank_mfo ? [] : [method.to_s.gsub('_','=')]
        args.first.each {|k,v| @params << "#{k}=#{rawurlencode(v)}"} if args.first.is_a?(Hash)
        query(type,@params)
      end
    end
  end
  
  define_methods 'get', :exchange, :apicour, :deposit, :bank_mfo, :avias_price, :avias_avias, :atm, :pboffice, :peoplenet, :bonus, :kontech, :konauto, :konbez, :wifi
  # define_methods 'post', :privat24, :liqpay
  
  private
  
  def query(type,data=nil)
    connection = Net::HTTP.new(@url.host,@url.port)
    connection.use_ssl = true
    connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    connection.start do |http|
      url = type == 'post' ? @url.request_uri : @url.request_uri + '&' + (data.is_a?(Array) ? data.join('&') : (data.is_a?(String) ? data : ''))
      @response = http.send(type,url,(data unless type == 'get')).body if ['get','post'].include?(type)
    end
  end
  
  # def signature(data)
  #   sha1(md5(data + @password))
  # end
  # 
  # def liqpay_signature(merch_sign,xml)
  #   Base64.encode64(sha1(merch_sign + xml + merch_sign))
  # end
  # 
  def rawurlencode(str)
    CGI.escape(str).gsub('+','%20') rescue str
  end
  # 
  # def sha1(str)
  #   Digest::SHA1.hexdigest(str)
  # end
  # 
  # def md5(str)
  #   Digest::MD5.hexdigest(str)
  # end
end