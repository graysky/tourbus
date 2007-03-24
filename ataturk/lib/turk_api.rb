require 'net/http'
require 'digest/sha1'
require 'base64'
require 'builder'

class TurkApiException < RuntimeError
  attr_accessor :errors
  def initialize(errors)
    @errors = errors
  end
end

class TurkApiAssignment
  attr_accessor :id
  attr_accessor :hit_id
  attr_accessor :worker_id
  attr_accessor :status
  attr_accessor :response_time
  attr_accessor :answer
  attr_accessor :raw_answer
  
  def answer
    return @raw_answer if @raw_answer
    
    doc = REXML::Document.new(@answer)
    node = doc.root.elements["Answer/FreeText"]
    node.nil? ? nil : node.text.strip
  end
end

#########################################
# Turk API methods
#########################################
class TurkApi
  # Override defaults in environment.rb...
  AWS_ACCESS_KEY_ID = '1Y4C0G77T4XXBQ64AMR2'
  AWS_SECRET_ACCESS_KEY = 'm9byJX7btKLVrUOzlVpkWpoqnNXQW2Q2lmZMVeHq'
  SERVICE_NAME = 'AWSMechanicalTurkRequester'
  SERVICE_VERSION = '2006-10-31'
  QUESTION_FORM_SCHEMA = "http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2005-10-01/QuestionForm.xsd"
  TEST_QUALIFICATION = 'XZQZPCCRKAW0KEXRJS8Z' # only gary's account is qualified
  
  attr :key
  attr :secret_key
  attr :debug
  
  def initialize(debug = false, key = AWS_ACCESS_KEY_ID, secret_key = AWS_SECRET_ACCESS_KEY)
    @debug = debug
    @key = key
    @secret_key = secret_key
    @logger = TURK_LOGGER
  end
      
  # Get the current account balance
  def get_account_balance
    op = "GetAccountBalance"
    res = "#{op}Result"
    xml = aws_call(op)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}/AvailableBalance"]
      return result_node.elements['FormattedPrice'].text
    end
    
    raise "Unexpected error: no result found"
  end
  
  # Print the HIT data structure for the given id
  def get_hit(id)
    op = "GetHIT"
    res = "HIT"
    
    params = { :HITId => id }
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    puts xml.to_s
  end
  
  # Expire a HIT immediately
  def expire_hit(id)
    op = "ForceExpireHIT"
    res = "ForceExpireHITResult"
    
    params = { :HITId => id }
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}"]
      return true
    end
    
    raise "Unexpected error: no result found"
  end
  
  # Disable a HIT immediately
  def disable_hit(id)
    op = "DisableHIT"
    res = "DisableHITResult"
    
    params = { :HITId => id }
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}"]
      return true
    end
    
    raise "Unexpected error: no result found"
  end
  
  # Dispose of a HIT once we are done
  def dispose_hit(id)
    op = "DisposeHIT"
    res = "#{op}Result"
    
    params = { :HITId => id }
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}"]
      return true
    end
    
    raise "Unexpected error: no result found"
  end
  
  # Create a new HIT
  def create_hit(site)
    op = "CreateHIT"
    res = "HIT"
    
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
            xml.NumberOfLinesSuggestion("1")
          end
        end
      end
    end
   
    params[:Question] = question
   
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}/HITId"]
      return result_node.text
    end
    
    raise "Unexpected error while creating a HIT: no result found"
  end
  
  # Get the TurkApiAssignment entered by a worker as an answer to the given HIT
  def get_hit_assignment(hit_id)
    op = "GetAssignmentsForHIT"
    res = "#{op}Result"
    
    params = { :HITId => hit_id, :AssignmentStatus => 'Submitted' }
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if node = xml.root.elements["#{res}/Assignment"]
      a = TurkApiAssignment.new
      a.id = node.elements['AssignmentId'].text
      a.hit_id = hit_id
      a.worker_id = node.elements['WorkerId'].text
      a.status = node.elements['AssignmentStatus'].text
      a.response_time = node.elements['SubmitTime'].text
      a.answer = node.elements['Answer'].text
      
      return a
    end
    
    raise "Unexpected error: no result found"
  end
  
  def get_reviewable_hits
    op = "GetReviewableHITs"
    res = "#{op}Result"
    page = 1
    page_size = 100
    hits = []
    
    while(true)
      params = { :PageSize => page_size, :PageNumber => page }
      xml = aws_call(op, params)
      raise_if_error(xml, op, res)
     
      if node = xml.root.elements["#{res}"]
        
        node.each_element("HIT") do |hit|
          hits << hit.elements["HITId"].text
        end
        
        total = node.elements['TotalNumResults'].text.to_i
        if (total == page_size)
          page += 1
        else
          break
        end
      end
    end
    
    hits
  end
  
  # Approve the given assignment and pay the worker
  def approve_assignment(id, feedback = nil)
    op = "ApproveAssignment"
    res = "#{op}Result"
    
    params = { :AssignmentId => id }
    params[:RequesterFeedback] = feedback if feedback
    
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}"]
      return true
    end
    
    raise "Unexpected error: no result found"
  end
  
  # Reject the assignment
  def reject_assignment(id, feedback = nil)
    op = "RejectAssignment"
    res = "#{op}Result"
    
    params = { :AssignmentId => id }
    params[:RequesterFeedback] = feedback if feedback
    
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}"]
      return true
    end
    
    raise "Unexpected error: no result found"
  end
  
  # Extend a previously-rejected HIT
  def extend_hit(id)
    op = "ExtendHIT"
    res = "#{op}Result"
    
    params = { :HITId => id }
    xml = aws_call(op, params)
    raise_if_error(xml, op, res)
    
    if result_node = xml.root.elements["#{res}"]
      return true
    end
    
    raise "Unexpected error: no result found"
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
      :Validate => @debug
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
    @logger.debug(url)
    REXML::Document.new(Net::HTTP.get(url))
  end
  
  def collect_errors(errors_node)
    errors = []
    errors_node.each do |error_node|
      errors << [error_node.elements['Code'].text, error_node.elements['Message'].text]
    end
    
    errors
  end
  
  def raise_if_error(xml, operation, res)
    errors = []
    
    # Check for request errors
    if error_nodes = xml.root.elements['OperationRequest/Errors']
      errors = errors + collect_errors(error_nodes)
    end
    
    # Check for operation errors
    if error_nodes = xml.root.elements["#{res}/Request/Errors"]
      errors = errors + collect_errors(error_nodes)
    end
    
    if !errors.empty?
      @logger.error("Error running turk operation: #{operation}")
      for error in errors
        @logger.error("\t#{error[0]}, \"#{error[1]}\"")
      end
      
      raise TurkApiException.new(errors), "Error running operation: #{operation}"
    end
  end
  
end