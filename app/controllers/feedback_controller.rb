# Allows users to send us feedback
class FeedbackController < ApplicationController
  layout "public"

  def index
    # The user is requesting the form  
    if request.get?
      return
    end
    
    # The user submitted a feedback form
    user = params[:user]
    email = params[:email]
    feedback = params[:feedback]
    type = params[:type]
    
    if feedback.nil? or feedback.empty?
      feedback = "No feedback provided"
    end
    
    if user.nil? or user.empty?
      user = "Anonymous"
    end
    
    if email.nil? or email.empty?
      email = "No email provided"
    end
    
    FeedbackMailer.deliver_notify_feedback(type, feedback, user, email)
    
    # Tell them the message was sent
    render :action => 'feedback_success'
  end
  
  def report_problem
    return if request.get?
    
    FeedbackMailer.deliver_problem_report(params[:type], params[:id], params[:reason], params[:notes], logged_in_fan)
    render :nothing => true
  end

end
