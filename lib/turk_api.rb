require 'net/http'
require 'digest/sha1'
require 'base64'
require 'builder'

class TurkApiException < RuntimeError
  attr :errors
  def initialize(errors)
    @errors = errors
  end
end

class TurkApi
  # Override defaults in environment.rb... right now this is gary's account
  AWS_ACCESS_KEY_ID = '107T76MRP4RR78KM2W02'
  AWS_SECRET_ACCESS_KEY = 'o97H3xi0IrX8622N3ao6jONm/kLUdiyWIJvCZoJV'
  SERVICE_NAME = 'AWSMechanicalTurkRequester'
  SERVICE_VERSION = '2006-10-31'
  QUESTION_FORM_SCHEMA = "http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2005-10-01/QuestionForm.xsd"
  
  attr :key
  attr :secret_key
  
  def initialize(key = AWS_ACCESS_KEY_ID, secret_key = AWS_SECRET_ACCESS_KEY)
    @key = key
    @secret_key = secret_key
  end
      
  # Get the current account balance
  def get_account_balance
    op = "GetAccountBalance"
    xml = aws_call(op)
    raise_if_error(xml, op)
    
    if result_node = xml.root.elements["#{op}Result/AvailableBalance"]
      return result_node.elements['FormattedPrice'].text
    end
    
    raise "Unexpected error: no result found"
  end
  
  # Get the HIT data structure for the given id
  def get_hit(id)
    op = "GetHIT"
    params = { :HITId => id }
    xml = aws_call(op, params)
    raise_if_error(xml, op)
    
    #if result_node = xml.root.elements["#{op}Result/AvailableBalance"]
    #  return result_node.elements['FormattedPrice'].text
    #end
    
    #raise "Unexpected error: no result found"
    puts xml.to_s
  end
  
  # Create a new HIT
  def create_hit(site)
    op = "CreateHIT"
    
    type = site.turk_hit_type
    params = {}
    params[:HITTypeId] = type.aws_hit_type_id if type.aws_hit_type_id
    params[:LifetimeInSeconds] = site.lifetime
    params[:MaxAssignments] = site.num_assignments
    params[:Keywords] = "music, concerts, tourb.us"
    
    if type.aws_hit_type_id.nil? || site.price_override
      # All all of the specific fields
      add_reward_params(site.price_override || type.price, params)
      params[:Title] = type.title
      params[:Description] = type.description
      params[:AssignmentDurationInSeconds] = type.duration
    end
    
    # Create the question structure
    question = ""
    xml = Builder::XmlMarkup.new(:target => question)
    xml.QuestionForm(:xmlns => QUESTION_FORM_SCHEMA) do
      xml.Question do
        xml.QuestionIdentifier("q1")
        xml.IsRequired("true")
        xml.QuestionContent do
          xml.FormattedContent do
            xml.cdata!(type.question_content(site))
          end
        end
        xml.AnswerSpecification do
          xml.FreeTextAnswer do
            xml.Constraints do
              #xml.NumberOfLinesSuggestion("20")
            end
          end
        end
      end
    end

    params[:Question] = question
   
    xml = aws_call(op, params)
    raise_if_error(xml, op)
    
    puts xml
  end
  
  ###############################
  # protected helper methods
  ###############################
  protected
  
  def add_reward_params(price, params)
    params["Reward.1.Amount"] = (price.to_f / 100).to_s
    params["Reward.1.CurrencyCode"] = "USD"
  end
  
  # Define authentication routines (from AWS docs)
  def generate_timestamp(time)
    return time.gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')
  end
  
  def hmac_sha1(key, s)
    ipad = [].fill(0x36, 0, 64)
    opad = [].fill(0x5C, 0, 64)
    key = key.unpack("C*")
    key += [].fill(0, 0, 64-key.length) if key.length < 64
    
    inner = []
    64.times { |i| inner.push(key[i] ^ ipad[i]) }
    inner += s.unpack("C*")
    
    outer = []
    64.times { |i| outer.push(key[i] ^ opad[i]) }
    outer = outer.pack("c*")
    outer += Digest::SHA1.digest(inner.pack("c*"))
    
    return Digest::SHA1.digest(outer)
  end
  
  def generate_signature(operation, timestamp)
    msg = "#{SERVICE_NAME}#{operation}#{timestamp}"
    hmac = hmac_sha1(@secret_key, msg)
    b64_hmac = Base64::encode64(hmac).chomp
    return b64_hmac
  end
  
  def default_params
    {
      :Service => SERVICE_NAME,
      :Version => SERVICE_VERSION,
      :AWSAccessKeyId => @key,
      :Operation => nil,
      :Signature => nil,
      :Timestamp => nil,
    }
  end
  
  def base_params(operation)
    params = default_params
    
    timestamp = generate_timestamp(Time.now)
    signature = generate_signature(operation, timestamp)
    
    params[:Operation] = operation
    params[:Signature] = signature
    params[:Timestamp] = timestamp
    params
  end
  
  
  def aws_call(operation, extra_params = {})
    params = base_params(operation)
    params.update(extra_params)
    param_string = (params.collect { |key,value| "#{key}=#{CGI::escape(value.to_s)}" }).join('&')
    
    url = URI.parse('http://mechanicalturk.amazonaws.com/onca/xml?' + param_string)
    
    REXML::Document.new(Net::HTTP.get(url))
  end
  
  def collect_errors(errors_node)
    errors = []
    errors_node.each do |error_node|
      errors << [error_node.elements['Code'].text, error_node.elements['Message'].text]
    end
    
    errors
  end
  
  def raise_if_error(xml, operation)
    errors = []
    
    # Check for request errors
    if error_nodes = xml.root.elements['OperationRequest/Errors']
      errors = errors + collect_errors(error_nodes)
    end
    
    # Check for operation errors
    if error_nodes = xml.root.elements["#{operation}Result/Request/Errors"]
      errors = errors + collect_errors(error_nodes)
    end
    
    if !errors.empty?
      RAILS_DEFAULT_LOGGER.error("Error running turk operation: #{operation}")
      for error in errors
        RAILS_DEFAULT_LOGGER.error("\t#{error[0]}, \"#{error[1]}\"")
      end
      
      raise TurkApiException.new(errors), "Error running operation: #{operation}"
    end
  end
  
end