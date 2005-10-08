# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def states_for_select
    STATES
  end
  
  private
    STATES = %w{ AK AL AR AZ CA CO CT DE FL GA HI IA ID IL IN KS KY LA MA MD ME
                 MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN
                 TX UT VT VA WA WI WV WY }
end
