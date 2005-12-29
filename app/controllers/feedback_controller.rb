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
    
    if user.nil? or user.empty?
      user = "Anonymous"
    end
    
    if email.nil? or email.empty?
      email = "No email provided"
    end
    
    FeedbackMailer.deliver_notify_feedback(feedback, user, email)
    
    # Tell them the message was sent
    render :action => 'feedback_success'
  end

end
