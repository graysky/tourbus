class TurkApiException < RuntimeError
  attr :errors
  def initialize(errors)
    @errors = errors
  end
end

class TurkApiAssignment
  attr :id
  attr :hit_id
  attr :worker_id
  attr :status
  attr :response_time
  attr :answer
end
