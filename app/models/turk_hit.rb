# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  turk_site_id        :integer(11)   
#  submission_time     :datetime      
#  response_time       :datetime      
#  status              :integer(11)   default(1)
#  amount_paid         :integer(11)   
#  turk_worker_id      :integer(11)   
#  aws_hit_id          :string(255)   
#  turk_submission_id  :integer(11)   
#  turk_hit_submission_:integer(11)   
#

class TurkHit < ActiveRecord::Base
  belongs_to :turk_site
  belongs_to :turk_worker
  belongs_to :turk_hit_submission
  
  STATUS_OUTSTANDING = 1
  STATUS_REVIEWING = 2
  STATUS_REJECTED = 3
  STATUS_ACCEPTED = 4
  
  PURPOSE_COMPLETE = 1
  PURPOSE_UPDATE = 2
  PURPOSE_REVIEW = 3
  
  # Set the status of this HIT to be REVIEWING, along with associated bookkeeping
  def set_reviewing(assignment)
    self.status = STATUS_REVIEWING
    self.response_time = assignment.response_time
    
    submission = TurkHitSubmission.find_by_token(assignment.answer)
    self.turk_hit_submission = submission
    
    worker = TurkWorker.find_by_aws_worker_id(assignment.worker_id)
    raise "Missing worker" if worker.nil?
    
    self.turk_worker = worker
    
    self.aws_assignment_id = assignment.id
      
    self.save!
  end
  
  # Approve all assignments for this HIT.
  # TODO Will need revisiting when we have review hits
  def set_approved
    transaction do
      site = self.turk_site
      amount = site.price_override || site.turk_hit_type.price
      
      self.status = STATUS_ACCEPTED
      self.amount_paid = amount
      self.turk_worker.reward_paid += amount
      self.turk_worker.completed_hits += 1
      
      site.last_approved_hit = self
      puts site.last_approved_hit
      site.save!
      
      puts site.last_approved_hit
      
      self.save!
      self.turk_worker.save!
    end
  end
  
  def set_rejected
    transaction do
      self.status = STATUS_REJECTED
      self.turk_worker.rejected_hits += 1
      
      self.save!
      self.turk_worker.save!
    end
  end
end
